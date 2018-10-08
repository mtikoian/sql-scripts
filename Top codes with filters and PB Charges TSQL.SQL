/* ****************************************
*	Author: Dann Hekman
*	PQA: 
*	Query: Estimates Template Builder
*	Goal:
*		Identify common historical cases and professional charges that
*		could be used together in estimate templates
*	Structure:
*		This query is broken into four discrete phases. 
*			First: We create temporary tables of encounters in the time range.
*				These tables exist as pre-filtered versions of HSP_ACCOUNT and 
*				related tables to improve performance.
*			Second: We construct a list of the top 100 Technical CPT, ICD Px, DRG,
*				and non-E&M Professional Charge codes. Change this number by 
*				changing the select statements in this section. Save to @Base
*			Third: Join our Base table (Part 2) with our existing HARs (Part 1) to 
*				calculate which codes appear with which other codes. Save to 
*				@Results
*			Fourth: Join Base and results to print the final output for the 
*				spreadsheet. This is where the threshold is respected and 
*				formatting changes should be made.
*	How to Use:
*		Set parameters and execute query. 
*	Parameters:
*		@start				- (REQ) - Start date for Search (HAR Discharge Date)
*		@end				- (REQ) - End date for Search (HAR Discharge Date)
*		@cutoff_percent		- (REQ) - How often should a secondary ICD or CPT code appear (relative to the Primary ICD Prevalence)
*										to be included in the template?
*		@Loc				- (OPT) - Optional Filter on location. Set to NULL to include all locations
*		@iit_list			- (OPT) - Include if you want to include DRGs in this search. 
**************************************** */
/*
Use in case something goes wrong later on.
Drop Table #Base_List
Drop Table #Result_List 
Drop Table #temp_hsp_account
Drop Table #temp_hsp_acct_px_list 
Drop Table #temp_code_int_comb_ln 
Drop Table #temp_pb_chg_list
;
*/


Use Clarity
--Date Parameters
DECLARE @start as datetime = '2017-09-01 00:00:00'
DECLARE @end   as datetime = '2017-12-31 23:59:59' 

--Functional Parameters
Declare @cutoff_percent as int = 40
Declare @Loc as float = NULL
----IIT List from SSD-2031
------Enter pipe-delimited list of internal IIT IDs based
------on SSD-2031 with leading and trailing pipes
Declare @iit_list as varchar(30) = '|124|165|99|'  --'|135|130|42|' 

--Special Parameters
----Special PB Code
------Use this if you have a professional surgical code that isn't in the top
------100 most common PB charges, but you want to build a template for it. 
------e.g. for tertiary care that has a high OOP portion or patients travel
------out of network to get this service at your organization. 
Declare @special_pb as varchar(18) = NULL

--Tables used for the multi-phased search
Create Table #Base_List (src_code_type varchar(3),src_code varchar(10), Loc bigint, AcctCls varchar(30), Cnt float)
Create Table #Result_List (src_code_type varchar(3), src_code varchar(20), Loc bigint, AcctCls varchar(30), Code varchar(20), Code_Type varchar(5), Cnt float)
Declare @status_string as varchar(255)

--Subset tables cached off for performance
Create Table #temp_hsp_account (HSP_ACCOUNT_ID numeric(18,0), ACCT_CLASS_HA_C varchar(66), LOC_ID numeric(18,0), 
									FINAL_DRG_ID varchar(20), BILL_DRG_IDTYPE_ID numeric(18,0), DISCH_DATE_TIME datetime)
Create Table #temp_hsp_acct_px_list (HSP_ACCOUNT_ID numeric(18,0), FINAL_ICD_PX_ID varchar(20))
Create Table #temp_code_int_comb_ln (HSP_ACCOUNT_ID numeric(18,0), CODE_INT_CPT varchar(20))
Create Table #temp_pb_chg_list (HSP_ACCOUNT_ID numeric(18,0), PROC_CODE varchar(40))
;



set @status_string = 'Begin  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait

/* ******************************************************************
*				Cache off Temp Tables for Performance				*
******************************************************************* */
---------------------    Main HAR List    ---------------------------
Insert into #temp_hsp_account(HSP_ACCOUNT_ID, ACCT_CLASS_HA_C, LOC_ID, 
							  FINAL_DRG_ID, BILL_DRG_IDTYPE_ID, DISCH_DATE_TIME) 
	select   har.HSP_ACCOUNT_ID
			,ACCT_CLASS_HA_C
			,LOC_ID
			,FINAL_DRG_ID
			,BILL_DRG_IDTYPE_ID
			,DISCH_DATE_TIME
	From HSP_ACCOUNT har
	Inner Join HSP_ACCT_SBO sbo	
		on har.HSP_ACCOUNT_ID = sbo.HSP_ACCOUNT_ID
		and coalesce(SBO_HAR_TYPE_C,0) = 0
	Where DISCH_DATE_TIME BETWEEN @start and @end 
		and ((@Loc is NULL and LOC_ID is not null) or (@Loc = LOC_ID))
	
---------------------    ICD Px List    ---------------------------		
Insert into #temp_hsp_acct_px_list (HSP_ACCOUNT_ID, FINAL_ICD_PX_ID)
	select distinct  har.HSP_ACCOUNT_ID
					,icd.FINAL_ICD_PX_ID
	From #temp_hsp_account har
	inner join HSP_ACCT_PX_LIST icd 
		on har.HSP_ACCOUNT_ID = icd.HSP_ACCOUNT_ID 
	Where FINAL_ICD_PX_ID is not null
	
---------------------    CPT List    ---------------------------	
Insert into #temp_code_int_comb_ln (HSP_ACCOUNT_ID, CODE_INT_CPT)
	select distinct  har.HSP_ACCOUNT_ID
					,cpt.CODE_INT_CPT
	From #temp_hsp_account har
	Inner Join HSP_ACCOUNT 
		on har.HSP_ACCOUNT_ID = HSP_ACCOUNT.HSP_ACCOUNT_ID
		and RECUR_PARENT_ID is null --Exclude Recurring accounts for CPTs
		--Therapy Series tend to bloat this table and are problematic for many estimates.
		--Address therapy series templates with a group of SMEs rather than with this tool
	Inner Join CODE_INT_COMB_LN cpt 
		on har.HSP_ACCOUNT_ID = cpt.HSP_ACCOUNT_ID 
		and cpt.CODE_INT_CPT is not null
		and cpt.CODE_INT_CPT not like '[78J]____'	--Exclude Labs and Meds. Not good anchor codes
		and cpt.CODE_INT_CPT not like '3641[56]' 	--Exclude Lab Draw Charges. Also not good Anchor Codes
		and cpt.CODE_INT_CPT not like '99___' 		--Exclude Physician Level codes. Leaving those for PB Anchors
		
		
---------------------    PB Charge List  ---------------------
Insert into #temp_pb_chg_list (HSP_ACCOUNT_ID, PROC_CODE)
	select distinct  har.HSP_ACCOUNT_ID
					,eap.PROC_CODE
	From #temp_hsp_account har
	Inner Join HSP_ACCT_PAT_CSN csn
		on har.HSP_ACCOUNT_ID = csn.HSP_ACCOUNT_ID
	Inner Join ARPB_TRANSACTIONS etr
		on etr.PAT_ENC_CSN_ID = csn.PAT_ENC_CSN_ID
		and etr.SERVICE_DATE BETWEEN @start and @end 
	Inner Join CLARITY_EAP eap
		on etr.PROC_ID = eap.PROC_ID
		and eap.PROC_CODE not like '[78J]____'	--Exclude Labs and Meds. Not good anchor codes
		and eap.PROC_CODE not like '3641[56]' 	--Exclude Lab Draw Charges. Also not good Anchor Codes
		and eap.PROC_CODE like '[a-z0-9][0-9][0-9][0-9][0-9]'
		
	Where (@special_pb is null or eap.PROC_CODE = @special_pb)
	

set @status_string = 'End Building Temp Tables  ' raiserror(@status_string,0,1) with nowait
set @status_string = 'Begin Building Base List  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait
/* ******************************************************************
*	Build the Base Table of the most frequently used Anchor Codes	*
******************************************************************* */

---------------------ICD Procedure Codes---------------------------
Insert into #Base_List (src_code_type, src_code, Loc, AcctCls, Cnt)
Select Top 100
		 'ICD'					as 'src_code_type'
		,px.FINAL_ICD_PX_ID		as 'src_code'
		,har.LOC_ID				as 'Loc'
		,har.ACCT_CLASS_HA_C	as 'AcctCls'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From #temp_hsp_account har
Inner Join #temp_hsp_acct_px_list px
	on har.HSP_ACCOUNT_ID = px.HSP_ACCOUNT_ID
	
Group by px.FINAL_ICD_PX_ID
		,har.LOC_ID
		,har.ACCT_CLASS_HA_C	
Order by [Cnt] desc

-----------------------------DRG Codes----------------------------
Insert into #Base_List (src_code_type, src_code, Loc, AcctCls, Cnt)
Select Top 100
		 'DRG'					as 'src_code_type'
		,har.FINAL_DRG_ID		as 'src_code'
		,har.LOC_ID				as 'Loc'
		,har.ACCT_CLASS_HA_C	as 'AcctCls'
		,count(HSP_ACCOUNT_ID) 	as 'Cnt'

From #temp_hsp_account har
Where har.FINAL_DRG_ID is not null
	and @iit_list like '%|' + cast(har.BILL_DRG_IDTYPE_ID as varchar(30)) +'|%'   
	
Group by har.FINAL_DRG_ID
		,har.LOC_ID		
		,har.ACCT_CLASS_HA_C	
Order by [Cnt] desc


-----------------------------CPT Codes----------------------------
Insert into #Base_List (src_code_type, src_code, Loc, AcctCls, Cnt)
Select Top 100
		 'CPT'					as 'src_code_type'
		,cpt.CODE_INT_CPT		as 'src_code'
		,har.LOC_ID				as 'Loc'
		,har.ACCT_CLASS_HA_C	as 'AcctCls'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From #temp_hsp_account har
Inner Join #temp_code_int_comb_ln cpt
	on har.HSP_ACCOUNT_ID = cpt.HSP_ACCOUNT_ID
	
Where cpt.CODE_INT_CPT is not null

Group by cpt.CODE_INT_CPT
		,har.LOC_ID
		,har.ACCT_CLASS_HA_C	
Order by [Cnt] desc

-----------------------------PB Charge Codes----------------------------
Insert into #Base_List (src_code_type, src_code, Loc, AcctCls, Cnt)
Select Top 100
		 'PB'					as 'src_code_type'
		,eap.PROC_CODE			as 'src_code'
		,har.LOC_ID				as 'Loc'
		,har.ACCT_CLASS_HA_C	as 'AcctCls'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From ARPB_TRANSACTIONS etr
Inner Join HSP_ACCT_PAT_CSN csn
	on etr.PAT_ENC_CSN_ID = csn.PAT_ENC_CSN_ID
Inner Join #temp_hsp_account har
	on csn.HSP_ACCOUNT_ID = har.HSP_ACCOUNT_ID
Inner Join CLARITY_EAP eap
	on etr.PROC_ID = eap.PROC_ID
	and eap.PROC_CODE not like '[78J]____'   --No Lab or J codes
	and eap.PROC_CODE not like '3641[56]'    --No Lab Draws

Group by eap.PROC_CODE
		,har.LOC_ID
		,har.ACCT_CLASS_HA_C	
Order by [Cnt] desc

/* ******************************************************************************
*	Build the Results table for all Companion Codes, one linked type at a time	*
******************************************************************************* */
set @status_string = 'End Building Base List  ' raiserror(@status_string,0,1) with nowait
set @status_string = 'Begin Building ICD Pair List  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait
--------------------------------Non-Primary ICD Procedure Codes---------------------------
Insert into #Result_List (src_code_type, src_code, Loc, AcctCls, Code, Code_Type, Cnt)
Select   base.src_code_type		as 'src_code_type'
		,base.src_code			as 'src_code'
		,har.LOC_ID				as 'Loc'
		,base.AcctCls			as 'AcctCls'
		,sICD.FINAL_ICD_PX_ID	as 'Code'
		,'ICDPX'				as 'Code_Type'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From #Base_List base
Left outer Join #temp_hsp_acct_px_list pICD
	on base.src_code=pICD.FINAL_ICD_PX_ID
Left Outer Join #temp_code_int_comb_ln pCPT
	on base.src_code = pCPT.CODE_INT_CPT
	and base.src_code_type = 'CPT'
Left Outer Join #temp_pb_chg_list pETR
	on base.src_code = pETR.PROC_CODE
	and base.src_code_type = 'PB'
Inner Join #temp_hsp_account har
	on  (har.HSP_ACCOUNT_ID = coalesce(pCPT.HSP_ACCOUNT_ID, pICD.HSP_ACCOUNT_ID, pETR.HSP_ACCOUNT_ID)
									or base.src_code = har.FINAL_DRG_ID)
	and har.LOC_ID = base.Loc
	and har.ACCT_CLASS_HA_C = base.AcctCls
Inner Join #temp_hsp_acct_px_list sICD
	on sICD.HSP_ACCOUNT_ID = har.HSP_ACCOUNT_ID
	and sICD.FINAL_ICD_PX_ID <> base.src_code --don't pair ICD Codes with self

Group By  base.src_code
		 ,base.src_code_type
		 ,har.LOC_ID
		 ,base.AcctCls	
		 ,sICD.FINAL_ICD_PX_ID	
--End Adding ICD PX Codes to the list of Results


set @status_string = 'End Building ICD Pair List  ' raiserror(@status_string,0,1) with nowait
set @status_string = 'Begin Building DRG Pair List  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait
--------------------------------DRG Codes---------------------------
Insert into #Result_List (src_code_type, src_code, Loc, AcctCls, Code, Code_Type, Cnt)
Select   base.src_code_type		as 'src_code_type'
		,base.src_code			as 'src_code'
		,har.LOC_ID				as 'Loc'
		,base.AcctCls			as 'AcctCls'
		,har.FINAL_DRG_ID		as 'Code'
		,'DRG'					as 'Code_Type'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From #Base_List base
Left Outer Join #temp_hsp_acct_px_list pICD
	on base.src_code=pICD.FINAL_ICD_PX_ID
Left Outer Join #temp_code_int_comb_ln pCPT
	on base.src_code = pCPT.CODE_INT_CPT
	and base.src_code_type = 'CPT'
Left Outer Join #temp_pb_chg_list pETR
	on base.src_code = pETR.PROC_CODE
	and base.src_code_type = 'PB'
Inner Join #temp_hsp_account har
	on  har.HSP_ACCOUNT_ID = coalesce(pICD.HSP_ACCOUNT_ID, pCPT.HSP_ACCOUNT_ID, pETR.HSP_ACCOUNT_ID)
	and har.LOC_ID = base.Loc
	and har.ACCT_CLASS_HA_C = base.AcctCls
	and @iit_list like '%|' + cast(har.BILL_DRG_IDTYPE_ID as varchar(30)) +'|%'  

Group By  base.src_code	
		 ,base.src_code_type
		 ,har.LOC_ID
		 ,base.AcctCls	
		 ,har.FINAL_DRG_ID	
--End Adding DRG Codes to the list of Results


set @status_string = 'End Building DRG Pair List  '  raiserror(@status_string,0,1) with nowait
set @status_string = 'Begin Building HB CPT Pair List  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait
--------------------------------CPT Codes---------------------------
Insert into #Result_List (src_code_type, src_code, Loc, AcctCls, Code, Code_Type, Cnt)
Select   base.src_code_type		as 'src_code_type'
		,base.src_code			as 'src_code'
		,har.LOC_ID			as 'Loc'
		,base.AcctCls		as 'AcctCls'
		,cpt.code_int_cpt		as 'Code'
		,'CPT'				as 'Code_Type'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From #Base_List base
Left Outer Join #temp_hsp_acct_px_list pICD
	on base.src_code=pICD.FINAL_ICD_PX_ID
Left Outer Join #temp_code_int_comb_ln pCPT
	on base.src_code = pCPT.CODE_INT_CPT
	and base.src_code_type = 'CPT'
Left Outer Join #temp_pb_chg_list pETR
	on base.src_code = pETR.PROC_CODE
	and base.src_code_type = 'PB'
Inner Join #temp_hsp_account har
	on (har.HSP_ACCOUNT_ID = coalesce(pICD.HSP_ACCOUNT_ID, pCPT.HSP_ACCOUNT_ID, pETR.HSP_ACCOUNT_ID) or base.src_code = har.FINAL_DRG_ID)
	and har.DISCH_DATE_TIME BETWEEN @start and @end
	and har.LOC_ID = base.Loc
	and har.ACCT_CLASS_HA_C = base.AcctCls
Inner Join #temp_code_int_comb_ln cpt
	on cpt.HSP_ACCOUNT_ID = har.HSP_ACCOUNT_ID
	and not (base.src_code_type='CPT' and cpt.code_int_cpt = base.src_code) --don't match CPT with self

Group By  base.src_code	
		 ,base.src_code_type
		 ,har.LOC_ID
		 ,base.AcctCls	
		 ,cpt.code_int_cpt
--End Adding CPT Codes to the list of Results


set @status_string = 'End Building HB CPT Pair List  ' raiserror(@status_string,0,1) with nowait
set @status_string = 'Begin Building PB Charge Pair List  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait
--------------------------------PB Charge Codes---------------------------
Insert into #Result_List (src_code_type, src_code, Loc, AcctCls, Code, Code_Type, Cnt)
Select   base.src_code_type	as 'src_code_type'
		,base.src_code		as 'src_code'
		,har.LOC_ID			as 'Loc'
		,base.AcctCls		as 'AcctCls'
		,eap.PROC_CODE		as 'Code'
		,'PB'				as 'Code_Type'
		,count(distinct har.HSP_ACCOUNT_ID) as 'Cnt'

From #Base_List base 
Left Outer Join #temp_hsp_acct_px_list pICD
	on base.src_code=pICD.FINAL_ICD_PX_ID
Left Outer Join #temp_code_int_comb_ln pCPT
	on base.src_code = pCPT.CODE_INT_CPT
	and base.src_code_type = 'CPT'
Left Outer Join #temp_pb_chg_list pETR
	on base.src_code = pETR.PROC_CODE
	and base.src_code_type = 'PB'
Inner Join #temp_hsp_account har
	on (har.HSP_ACCOUNT_ID = coalesce(pICD.HSP_ACCOUNT_ID, pCPT.HSP_ACCOUNT_ID, pETR.HSP_ACCOUNT_ID) or base.src_code = har.FINAL_DRG_ID)
	and har.DISCH_DATE_TIME BETWEEN @start and @end
	and har.LOC_ID = base.Loc
	and har.ACCT_CLASS_HA_C = base.AcctCls
Inner Join HSP_ACCT_SBO sbo
	on har.HSP_ACCOUNT_ID = sbo.HSP_ACCOUNT_ID
	and coalesce(SBO_HAR_TYPE_C,0) = 0
Inner Join HSP_ACCT_PAT_CSN csn
	on har.HSP_ACCOUNT_ID = csn.HSP_ACCOUNT_ID
Inner Join ARPB_TRANSACTIONS etr
	on etr.PAT_ENC_CSN_ID = csn.PAT_ENC_CSN_ID
Inner Join CLARITY_EAP eap
	on eap.PROC_ID = etr.PROC_ID
	and not (base.src_code_type='PB' ) --don't match CPT with self
	and eap.PROC_CODE not like '[78J]____'   --No Lab or J codes
	and eap.PROC_CODE not like '3641[56]'    --No Lab Draws

Group By  base.src_code
		 ,base.src_code_type
		 ,har.LOC_ID
		 ,base.AcctCls	
		 ,eap.PROC_CODE
--End Adding PB CPT Codes to the list of Results


set @status_string = 'End Building PB Charge Pair List  ' raiserror(@status_string,0,1) with nowait
set @status_string = 'Begin Building Final Results  ' + convert(varchar(255),sysdatetime()) raiserror(@status_string,0,1) with nowait
/* ******************************************************************************
*	Write out the Results of the query joining Anchor Codes to Other Codes		*
******************************************************************************* */
Select	 base.Cnt				as 'Num Encounters'
		,base.src_code_type		as 'Anchor Type'
		,case
			when base.src_code_type = 'DRG'   then base_drg.DRG_NUMBER
			when base.src_code_type = 'ICD'   then base_icd.PROC_MASTER_NM
			when base.src_code_type = 'PB'    then base_cpt.PROC_CODE
			when base.src_code_type = 'CPT'   then base_cpt.PROC_CODE
			else NULL
		end						as 'Anchor Code'
		,case
			when base.src_code_type = 'DRG'   then base_drg.DRG_NAME
			when base.src_code_type = 'ICD'   then base_icd.PROCEDURE_NAME
			when base.src_code_type = 'PB'    then base_cpt.PROC_NAME
			when base.src_code_type = 'CPT'   then base_cpt.PROC_NAME
			else NULL
		end						as 'Anchor Description'
		,base.Loc				as 'Location'
		,zcls.TITLE				as 'AcctCls'
		,res.Code_Type			as 'Code Type'
		,case 
			when res.Code_Type = 'ICDPX' then icd.PROC_MASTER_NM
			when res.Code_Type = 'DRG'   then drg.DRG_NUMBER
			else res.Code end	as 'Filter Code to Include'
		,case
			when res.Code_Type = 'DRG'   then drg.DRG_NAME
			when res.Code_Type = 'ICDPX' then icd.ICD_PX_NAME
			when res.Code_Type = 'PB'    then cpt.PROC_NAME
			when res.Code_Type = 'CPT'   then cpt.PROC_NAME
			else NULL
		end						as 'Code Description'
		,cast(round(res.Cnt/base.Cnt,3) as numeric(10,3))		as 'Prevalence'
		,res.Cnt				as 'Prevalence Cnt'
		
From #Base_List base
Inner Join ZC_ACCT_CLASS_HA zcls
	on zcls.ACCT_CLASS_HA_C = base.AcctCls
--Join with Results
Left outer Join #Result_List res
	on base.src_code = res.src_code
	and base.src_code_type = res.src_code_type
	and base.Loc=res.Loc
	and base.AcctCls = res.AcctCls
	and (res.Cnt/base.Cnt)*100 >= @cutoff_percent

--Join with Base Types
Left Outer Join CL_ICD_PX base_icd
	on base.src_code = base_icd.ICD_PX_ID
Left Outer Join CLARITY_DRG base_drg
	on base.src_code = base_drg.DRG_ID
Left Outer Join CLARITY_EAP base_cpt
	on base.src_code = base_cpt.PROC_CODE

--Join with paired codes
Left Outer Join CLARITY_DRG drg
	on res.Code = drg.DRG_ID
	and res.Code_Type = 'DRG'
Left Outer Join CL_ICD_PX icd
	on res.Code = convert(varchar(20),icd.ICD_PX_ID)
	and res.Code_Type = 'ICDPX'
Left Outer Join CLARITY_EAP cpt
	on res.Code = cpt.PROC_CODE
	and res.Code_Type in ('PB','CPT')
	
Where base.Cnt >= 2 
		and (@special_pb is null or base.src_code = @special_pb)
Order by base.Cnt desc

--/*
Drop Table #Base_List
Drop Table #Result_List 
Drop Table #temp_hsp_account
Drop Table #temp_hsp_acct_px_list 
Drop Table #temp_code_int_comb_ln 
Drop Table #temp_pb_chg_list
--*/
