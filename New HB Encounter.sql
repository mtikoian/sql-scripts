/* SQL provided by Strata, edits and additions by TSM
*/
 --Encounter
select distinct
 --Medical Record Number
	pt.PAT_MRN_ID as Medical_Record_Number --enterprise mrn starts with e
 --Encounter Record Number
	, convert(varchar(18),ha.HSP_ACCOUNT_ID) AS Encounter_Record_Number
 --Location Code 
	, convert(varchar(18),ha.loc_id)	 as Location_Code	--CLARITY_LOC

-- Parent Location needs added as Entity Code AR Entity, Parent loc EAF 8200

 --Entity Code
	, convert(varchar(15),clarity_loc.gl_prefix) as Entity_Code   --CLARITY_SA

 --Patient Type Code
	, ha.ACCT_CLASS_HA_C as Patient_Type_Code    -- ZC_ACCT_CLASS_HA
 --First Name, names in proper case Thomas...
	, pt.PAT_FIRST_NAME as First_Name
 --Last Name
	, pt.PAT_LAST_NAME as Last_Name
 --Middle IName
	, pt.PAT_MIDDLE_NAME as Middle_Name
 --Religion 
	, pt.RELIGION_C as Religion_Code   -- ZC_RELIGION

 --Gender Code
	, pt.SEX_C as Gender_Code  -- ZC_SEX  "M,F,U"
 --Date Of Birth
	, CONVERT(VARCHAR(8), pt.BIRTH_DATE, 112)  as Date_of_Birth --yymmdd
 --Race Code
, pr.PATIENT_RACE_C as Race_Code  --ZC_PAT_RACE, 1st selected, 
 --Marital Status Code
	, pt.MARITAL_STATUS_C as Marital_Status_Code --ZC_MARITAL_STATUS 1st selected, nancy provide lookupo table
	
 --Zip Code
	, pt.ZIP as Zip_Code  --5 digit
 --Street Address
	, Concat(pt.ADD_LINE_1, ' ', pt.ADD_LINE_2) as Street_Address --concatenate to 1 line
 --city , state, county
    ,pt.city as City
	,zc_state.abbr as State
	,zc_county.name as County

	
 
 --Employer Code
	, pt.EMPLOYER_ID as Employer_Code   --CLARITY_EEP
 --SSN
  --, pt.SSN
 --Guarantor Code
	, convert(varchar(18),ha.GUARANTOR_ID) as Guarantor_Code --join to table ACCOUNT
 --Guarantor Employer Code
	, guar_acc.EMPLOYER_ID as Guarantor_Employer_Code --CLARITY_EEP

	--they need the payors, not plans!!!
 --Insurance Plan 1 Code --if no payor in first one hard code to COB code to be provided.
	, convert(varchar(18),ha.PRIMARY_PLAN_ID) as Insurance_Plan_1_Code  --CLARITY_EPP  --When plan NULL then 'Self-Pay'
 --Insurance Plan 2 Code
	, convert(varchar(18),cov_sec.PLAN_ID) as Insurance_Plan_2_Code
 --Insurance Plan 3 Code
	, convert(varchar(18),cov_3rd.PLAN_ID) as Insurance_Plan_3_Code

		
	--add a self pay line 5 as 
	 --
 --Patient Mother ERN 
	, convert(varchar(18),ha.MOM_HSP_ACCT_ID) as Patient_Mother_ERN
 --Newborn Flag
	, case when ha.acct_class_ha_c = '107'  --newborn --verify if 107 is correct!
		then 'Y'
		else 'N'
	  end as Newborn_Flag
 --Birth Weight  -- ask if this should only be Newborn as I have it here. Are we interesting in Birth_Weight for a 7 year old?
	, case when ha.acct_class_ha_c = '107' --verify 
		then pt3.PED_BIRTH_WT_NUM * 28.3495 --given in ounces muliplier used for grams
	  end as Birth_Weight
 --Admit Date 
 	, CONVERT(VARCHAR(10), ha.ADM_DATE_TIME, 112) as Admit_Date --yymmdd
 --Admit Time
	, CONVERT(VARCHAR(5),ha.ADM_DATE_TIME,108) as Admit_Time --HH:MM military

 --Admit Type Code
	, ha.ADMISSION_TYPE_C AS Admit_Type_Code  --ZC_MC_ADM_TYPE --UB standard  if "4" prepend 'N' on admit source
 --Admit Source Code  
	, ha.ADMISSION_SOURCE_C as Admit_Source_Code  --ZC_MC_ADM_SOURCE  --UB standard

 --Admit Department Code
    , (select distinct convert(varchar(18),adt_adm.DEPARTMENT_ID) --CLARITY_DEP  --ZC_CAD_CTR --ZC_ADT_UNIT_TYPE for HOV
              from clarity_adt adt_adm
                 where adt_adm.EVENT_TYPE_C=1 --Admitted
                     and adt_adm.EVENT_SUBTYPE_C =1 --original
                     and adt_adm.PAT_ENC_CSN_ID=ha.PRIM_ENC_CSN_ID
					 and ha.PRIM_ENC_CSN_ID is not null
          ) as Admit_Department_Code

 --Admit Nurse Station Code 
	, (select distinct convert(varchar(18),adt_adm.DEPARTMENT_ID) --CLARITY_DEP  --ZC_CAD_CTR --ZC_ADT_UNIT_TYPE for HOV
              from clarity_adt adt_adm
                 where adt_adm.EVENT_TYPE_C=1 --Admitted
                     and adt_adm.EVENT_SUBTYPE_C =1 --original
                     and adt_adm.PAT_ENC_CSN_ID=ha.PRIM_ENC_CSN_ID
					 and ha.PRIM_ENC_CSN_ID is not null
						)as Admit_Nurse_Station_Code
 --Method of Arrival Code
	, ha.MEANS_OF_ARRV_C as Method_of_Arrival_Code   -- ZC_ARRIV_MEANS
 

 --Admit ICD9 DX Code  --ZC_EDG_CODE_SET
 	, (SELECT edg_adm.REF_BILL_CODE  -- CLARITY_EDG
		from HSP_ACCT_ADMIT_DX haad
			inner join CLARITY_EDG edg_adm
				on haad.ADMIT_DX_ID=edg_adm.DX_ID
		where haad.LINE=1 
			and haad.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
			and edg_adm.REF_BILL_CODE_SET_C = '1'  --ICD-9-CM
       ) as Admit_ICD9_DX_Code 


 --Admit ICD10 DX Code  --ZC_EDG_CODE_SET
 	, (SELECT edg_adm.REF_BILL_CODE  -- CLARITY_EDG
		from HSP_ACCT_ADMIT_DX haad
			inner join CLARITY_EDG edg_adm
				on haad.ADMIT_DX_ID=edg_adm.DX_ID
		where haad.LINE=1 
			and haad.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
			and edg_adm.REF_BILL_CODE_SET_C = '2'  --ICD-9-CM
       ) as Admit_ICD10_DX_Code 
 --Primary ICD9 DX Code 
	, (SELECT edg_1.REF_BILL_CODE -- CLARITY_EDG --ZC_EDG_CODE_SET
		from HSP_ACCT_DX_LIST hadl_1
			inner join CLARITY_EDG edg_1
				on hadl_1.DX_ID=edg_1.DX_ID
		where hadl_1.LINE=1 
			and hadl_1.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
			and edg_1.REF_BILL_CODE_SET_C = '1'  --ICD-9-CM
       ) as Primary_ICD9_DX_Code 
 --Primary ICD10 DX Code
 	, (SELECT edg_10.REF_BILL_CODE -- CLARITY_EDG --ZC_EDG_CODE_SET
		from HSP_ACCT_DX_LIST hadl_10
			inner join CLARITY_EDG edg_10
				on hadl_10.DX_ID=edg_10.DX_ID
		where hadl_10.LINE=1 
			and hadl_10.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
			and edg_10.REF_BILL_CODE_SET_C = '2'  --ICD-10-CM
       ) as Primary_ICD10_DX_Code 
 --Primary ICD9 PX Code
    , (SELECT cip_1.REF_BILL_CODE              --CL_ICD_PX
		from HSP_ACCT_PX_LIST hapl_1
			left outer join CL_ICD_PX cip_1
				on hapl_1.FINAL_ICD_PX_ID=cip_1.ICD_PX_ID
        where hapl_1.LINE=1 
			and hapl_1.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
			and cip_1.CODE_SET_C = '1' --ICD-9-CM Volume 3
	   ) as Primary_ICD9_PX_Code
 --Primary ICD10 PX Code
     , (SELECT cip_10.REF_BILL_CODE    --CL_ICD_PX  --ZC_HCD_CODE_SET
		from HSP_ACCT_PX_LIST hapl_10
			left outer join CL_ICD_PX cip_10
				on hapl_10.FINAL_ICD_PX_ID=cip_10.ICD_PX_ID
        where hapl_10.LINE=1 
			and hapl_10.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
			and cip_10.CODE_SET_C = '2' --ICD-10-PCS  --Ask about this
	   ) as Primary_ICD10_PX_Code
 --MS DRG Code  --currently we only have MS DRG and do not foresee anything else, however, we need type to indicate version
	, (select cdmi.MPI_ID
		from hsp_account ha_ms_drg 
			inner join CLARITY_DRG_MPI_ID cdmi
				on ha_ms_drg.FINAL_DRG_ID=cdmi.DRG_ID
					and ha_ms_drg.BILL_DRG_IDTYPE_ID=cdmi.MPI_ID_TYPE
		where ha_ms_drg.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
			and ha.HSP_ACCOUNT_ID is not null
	  ) as MS_DRG_Code  --CLARITY_DRG  --V_ZZLOV_DRG_TYPES --CLARITY_DRG_MPI_ID
--	, ha.BILL_DRG_IDTYPE_ID as DRG_Type --V_ZZLOV_DRG_TYPES 

 --AP DRG Schema --??? Not in our choices
 --AP DRG Code --??? Not in our choices
 --APR DRG Schema --??? Not in our choices
 --APR DRG Code --??? Not in our choices
 --APR ROM
	, ha.BILL_DRG_ROM as ROM  --ZC_SOI_ROM  --do we currently have these?
 --APR SOI
	, ha.BILL_DRG_PS as SOI    --ZC_SOI_ROM
 --Clinical Service Code
	, ha.PRIM_SVC_HA_C  as Clinical_Service_Code--ZC_PRIM_SVC_HA 
 --CMG Code
	, ha.CASE_MIX_GRP_CODE as CMG
 --Admit Physician Code
	, ha.ADM_PROV_ID as Admit_Physician_Code --CLARITY_SER
 --Attend Physician Code
	, ha.ATTENDING_PROV_ID as Attend_Physician_Code  --CLARITY_SER
 --Consult Physician 1 Code   --waiting for table
	, (select haop_1.OTHER_PROV_ID
		from HSP_ACCT_OTHR_PROV haop_1
		where haop_1.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
			and ha.HSP_ACCOUNT_ID is not null
			and haop_1.line = '1'
			and haop_1.OTH_PRV_ROLE_C = '6'--consulting
	   ) as Consult_Physician_1_Code
 --Consult Physician 2 Code   
		, (select haop_2.OTHER_PROV_ID
		from HSP_ACCT_OTHR_PROV haop_2
		where haop_2.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
			and ha.HSP_ACCOUNT_ID is not null
			and haop_2.line = '1'
			and haop_2.OTH_PRV_ROLE_C = '6' --consulting
	   ) as Consult_Physician_2_Code
 --Consult Physician 3 Code
 	, (select haop_3.OTHER_PROV_ID
		from HSP_ACCT_OTHR_PROV haop_3
		where haop_3.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
			and ha.HSP_ACCOUNT_ID is not null
			and haop_3.line = '3'
			and haop_3.OTH_PRV_ROLE_C = '6' --consulting
	   ) as Consult_Physician_3_Code
 --Principal Performing Physician Code
	, (SELECT hapl_1.PROC_PERF_PROV_ID         --CLARITY_SER         --CL_ICD_PX
		from HSP_ACCT_PX_LIST hapl_1
			left outer join CL_ICD_PX cip_1
				on hapl_1.FINAL_ICD_PX_ID=cip_1.ICD_PX_ID
        where hapl_1.LINE=1 
			and hapl_1.HSP_ACCOUNT_ID=ha.HSP_ACCOUNT_ID
            and ha.HSP_ACCOUNT_ID is not null
        ) as Primary_Performing_Physician_Code
 --Refer Physician Code
	, ha.REFERRING_PROV_ID as Refer_Physician_Code --CLARITY_SER
 --Primary Care Physician Code
	, pt.CUR_PCP_PROV_ID  as Primary_Care_Physician_Code --CLARITY_SER
 --Discharge Date 
	, CONVERT(VARCHAR(8), ha.DISCH_DATE_TIME, 112) as Discharge_Date
 --Discharge time
	, CONVERT(VARCHAR(5),ha.DISCH_DATE_TIME,108) as Discharge_Time
 --Discharge Unit Code
	, CONVERT(varchar(18),ha.DISCH_DEPT_ID) as Discharge_Department_Code   --CLARITY_DEP --ZC_CAD_CTR --ZC_ADT_UNIT_TYPE for HOV
 --Discharge Nurse Station ----Nurse Stations same as Departments--
    , CONVERT(varchar(18),ha.DISCH_DEPT_ID) as Discharge_Nurse_station_Code 
 --Discharge Status Code
	, ha.PATIENT_STATUS_C  as Discharge_Status_Code   --ZC_MC_PAT_STATUS  ???
 --Bill Status Code
	, ha.ACCT_BILLSTS_HA_C as Bill_Status_Code
 --Final Bill Date
	, CONVERT(VARCHAR(8), ha.ACCT_BILLED_DATE, 112) as Final_Bill_Date
 --Account Balance
	, ha.TOT_ACCT_BAL as Account_Balance
 --Historical Expected Payment
	--, ha.DRG_EXPECTED_REIMB 
	, (Select  sum(a.AllowedAmt)

		from (select (select top 1 hbnah_max.EXPECT_ALLOWED_AMT
		from HSP_BKT_NAA_ADJ_HX hbnah_max
		where hbnah_max.BUCKET_ID=hb.BUCKET_ID
			and hb.BUCKET_ID is not null
			and hbnah_max.expect_allowed_amt is not null
		group by hbnah_max.BUCKET_ID
			, hbnah_max.EXPECT_ALLOWED_AMT
			, hbnah_max.ACTION_INSTANT_DTTM
		order by hbnah_max.ACTION_INSTANT_DTTM desc
	   ) as AllowedAmt		






from HSP_ACCOUNT ha_1	

		
	inner join HSP_CLAIM_DETAIL2 hcd2		
		on ha_1.HSP_ACCOUNT_ID=hcd2.HOSPITAL_ACCT_ID	
	left outer join zc_fin_class zfc		
		on ha_1.ACCT_FIN_CLASS_C=zfc.FIN_CLASS_C	
	inner join clarity_epp epp		
		on ha_1.PRIMARY_PLAN_ID=epp.benefit_plan_id	
	inner join patient pt		
		on ha_1.pat_id=pt.pat_id
			
	inner join HSP_BUCKET hb		
		on ha_1.HSP_ACCOUNT_ID=hb.HSP_ACCOUNT_ID	
		left outer join HSP_BKT_NAA_ADJ_HX hbnah	
			on hb.BUCKET_ID=hbnah.BUCKET_ID
		left outer join ZC_CLAIM_FORM_TYPE zcft	
			on hb.CLAIM_FORM_TYPE_C=zcft.CLAIM_FORM_TYPE_C
		left outer join ZC_BKT_STS_HA zbsh	
			on hb.BKT_STS_HA_C=zbsh.BKT_STS_HA_C
		left outer join ZC_INS_DATA_SRC_HX zidsh	
			on hb.INS_DATA_SRC_C=zidsh.INS_DATA_SRC_HX_C
		left outer join HSP_BKT_XPTRBMT_HX hbxh	
			on hb.BUCKET_ID=hbxh.BUCKET_ID

		
    

	
where hbnah.EXPECT_ALLOWED_AMT	is not null		
	and  hb.BKT_STS_HA_C <> '8'	 --HSP_BUCKET not rejected	
	and hb.CLAIM_FORM_TYPE_C is not null		
	and ha_1.hsp_account_id =ha.HSP_ACCOUNT_ID
		and ha.HSP_ACCOUNT_ID is not null
		
union                                                 --union operator-----------------------------------------------------

select (select top 1 hbxh_max.XR_HX_XPCTD_AMT		
		from HSP_BKT_XPTRBMT_HX hbxh_max	
		where hbxh_max.BUCKET_ID=hbxh.BUCKET_ID	
			and hbxh.BUCKET_ID is not null
			and hbxh_max.xr_hx_xpctd_amt is not null
		group by hbxh_max.BUCKET_ID	
			, hbxh_max.XR_HX_XPCTD_AMT
			, hbxh_max.xr_hx_update_dt
		order by hbxh_max.xr_hx_update_dt desc	
	   ) as AllowedAmt		
	
			
from HSP_ACCOUNT ha_2			
	inner join HSP_CLAIM_DETAIL2 hcd2		
		on ha_2.HSP_ACCOUNT_ID=hcd2.HOSPITAL_ACCT_ID	
	left outer join zc_fin_class zfc		
		on ha_2.ACCT_FIN_CLASS_C=zfc.FIN_CLASS_C	
	inner join clarity_epp epp		
		on ha_2.PRIMARY_PLAN_ID=epp.benefit_plan_id	
	inner join patient pt		
		on ha_2.pat_id=pt.pat_id
			
	inner join HSP_BUCKET hb		
		on ha_2.HSP_ACCOUNT_ID=hb.HSP_ACCOUNT_ID	
		left outer join HSP_BKT_NAA_ADJ_HX hbnah	
			on hb.BUCKET_ID=hbnah.BUCKET_ID
		left outer join ZC_CLAIM_FORM_TYPE zcft	
			on hb.CLAIM_FORM_TYPE_C=zcft.CLAIM_FORM_TYPE_C
		left outer join ZC_BKT_STS_HA zbsh	
			on hb.BKT_STS_HA_C=zbsh.BKT_STS_HA_C
		left outer join ZC_INS_DATA_SRC_HX zidsh	
			on hb.INS_DATA_SRC_C=zidsh.INS_DATA_SRC_HX_C
		left outer join HSP_BKT_XPTRBMT_HX hbxh	
			on hb.BUCKET_ID=hbxh.BUCKET_ID
where hbxh.XR_HX_XPCTD_AMT is not null	
	and  hb.BKT_STS_HA_C <> '8'	-- not rejected		
	and hb.CLAIM_FORM_TYPE_C is not null	
	and ha_2.hsp_account_id = ha.hsp_account_id
		and ha.hsp_account_id is not null
		
) a			
	   ) as  Historical_Expected_Payment

 --Additional Fields--Potential UDIs
	--AcctBaseClass
 	, ha.ACCT_BASECLS_HA_C  as Acct_Class -- ZC_ACCT_BASECLS_HA
	
	
	
	--EncounterType
	, (select pe_enc_type.enc_type_c --ZC_DISP_ENC_TYPE
		from pat_enc pe_enc_type
		where pe_enc_type.pat_enc_csn_id=ha.PRIM_ENC_CSN_ID
			and ha.PRIM_ENC_CSN_ID is not null
	   ) as Encounter_Type_Code
	--, ha.TOT_ADJ as Tot_Adj
	--, ha.TOT_CHGS as Tot_Chgs
	--, ha.TOT_PMTS as Tot_Pmts

	/*, (select afi.FPL_STATUS_CODE_C  -- ZC_FPL_STATUS_CODE  --we offer free care after all other payors if FPL status qualifies
		from ACCOUNT_FPL_INFO afi 
		where afi.ACCOUNT_ID = ha.GUARANTOR_ID 
			and ha.guarantor_id is not null
			and afi.fpl_eff_date <= ha.DISCH_DATE_TIME
			and afi.FPL_EXP_DATE >= ha.DISCH_DATE_TIME
			and afi.line = (select max(afi_max.line)
							 from ACCOUNT_FPL_INFO afi_max
							 where afi_max.account_id=ha.GUARANTOR_ID
							 and ha.GUARANTOR_ID is not null
							)
		) as FedPovertyLevel_Status
*/

   --Account Status, strata looking into
  --Account Type, strata looking into
  --Bad_Debt_Date, bad dept write off date
  --coding status
    ,ha.CODING_STATUS_C as "Coding_Status"
  --collection agency
    , HSP_ACCT_CL_AG_HIS.AGNCY_HST_AGNCY_ID  as "Collection_Agency"


	--,HSP_ACCT_CL_AG_HIS.line --remove!!
	

  --Billed_DRG
     ,clarity_drg.DRG_NUMBER as Billed_DRG
  --Billed DRG Type
     , clarity_drg_mpi_id.mpi_id_type as Billed_DRG_Type




from HSP_ACCOUNT ha
left outer join clarity_loc
			on ha.loc_id = clarity_loc.loc_id
	left outer join HSP_ACCOUNT_3 ha3
		on ha.hsp_account_id=ha3.hsp_account_id
	left outer join HSP_ACCT_CVG_LIST hacl_sec --nice thing about hacl table is we know these are valid in filing order for the hsp account!
		on  ha.HSP_ACCOUNT_ID=hacl_sec.HSP_ACCOUNT_ID ----& don't need primary payor and plan as in HSP_ACCOUNT table and accessed above
			and hacl_sec.line = 2
	left outer join coverage cov_sec 
		on hacl_sec.COVERAGE_ID=cov_sec.COVERAGE_ID
	left outer join HSP_ACCT_CVG_LIST hacl_3rd  
		on  ha.HSP_ACCOUNT_ID=hacl_3rd.HSP_ACCOUNT_ID
			and hacl_sec.line = 3
	left outer join coverage cov_3rd
		on hacl_3rd.COVERAGE_ID=cov_3rd.COVERAGE_ID
	left outer join ACCOUNT guar_acc
		on ha.GUARANTOR_ID = guar_acc.ACCOUNT_ID
	left outer join patient pt
		on ha.pat_id=pt.pat_id
	left outer join zc_state
		    on pt.state_c = zc_state.state_c
    left outer join zc_county
	        on pt.county_c = zc_county.county_c
		left outer join patient_3 pt3
			on pt.pat_id=pt3.pat_id
		left outer join patient_race pr
			on pt.pat_id=pr.pat_id
				and pr.line = (select max(prl.line)   --most recent race answer given
								from patient_race prl
								where prl.pat_id=pr.pat_id
									and pr.PAT_ID is not null
							   )
	left outer join PAT_ENC_HSP peh
		on ha.PRIM_ENC_CSN_ID=peh.PAT_ENC_CSN_ID

		left outer join clarity_drg 
			on ha.FINAL_DRG_ID = CLARITY_DRG.DRG_ID
		left outer join clarity_drg_mpi_id on ha.final_drg_id = clarity_drg_mpi_id.drg_id
		 and ha.bill_drg_idtype_id = clarity_drg_mpi_id.mpi_id_type

	left outer join

(select  HSP_ACCOUNT_ID, AGNCY_HST_AGNCY_ID

from
(
SELECT  a.HSP_ACCOUNT_ID,a.AGNCY_HST_AGNCY_ID, a.LINE
 FROM HSP_ACCT_CL_AG_HIS a
inner join
 (
 SELECT HSP_ACCOUNT_ID, MAX(LINE) as MLINE
 FROM HSP_ACCT_CL_AG_HIS
 WHERE agnc_hst_chg_tp_c = 1 
 group by HSP_ACCOUNT_ID
 )b
 
 on a.HSP_ACCOUNT_ID = b.HSP_ACCOUNT_ID and a.LINE= b.MLINE
 )c

 )HSP_ACCT_CL_AG_HIS on ha.HSP_ACCOUNT_ID = HSP_ACCT_CL_AG_HIS.HSP_ACCOUNT_ID
	

/*
	left outer join (select AGNC_HST_CHG_TP_C,AGNCY_HST_AGNCY_ID,HSP_ACCOUNT_ID, line, max(line)  as mline 
	    from HSP_ACCT_CL_AG_HIS
		 group by AGNC_HST_CHG_TP_C,HSP_ACCOUNT_ID,AGNCY_HST_AGNCY_ID,line)
		  as HSP_ACCT_CL_AG_HIS on ha.hSP_ACCOUNT_ID = HSP_ACCT_CL_AG_HIS.HSP_ACCOUNT_ID 
		
	*/	 
		 
          



where convert (varchar,ha.ADM_DATE_TIME, 110) >=  '12-18-2015'  --  --just put some dates in to start
	and convert(varchar,ha.ADM_DATE_TIME,110) < '12-19-2015'  --
	and ha.SERV_AREA_ID in ('19')  --to start


	and ha.HSP_ACCOUNT_ID = 101153520216


order by  pt.PAT_MRN_ID, Encounter_Record_Number

	
