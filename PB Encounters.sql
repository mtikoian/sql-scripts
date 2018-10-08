--declare @start_date as date = EPIC_UTIL.EFN_DIN('{Start Date}')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('{End Date}')

declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-2')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-2')

select 

 tdl.tx_id as Encounter_Record_Number
,max(isnull(convert(varchar, patient.pat_mrn_id),'')) as Medical_Record_Number
,max(isnull(convert(varchar,tdl.loc_id),'')) as Location_Code
,max(case when loc.gl_prefix = '6010' and dep.gl_prefix = '800000' then '6051'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '405000' then '6710'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '410365' then '6760'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '440000' then '6770'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '468000' then '6760'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '471351' then '6770'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '430370' then '6752'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '642000' then '6770'
	  when loc.gl_prefix = '6734' and dep.gl_prefix = '792396' then '6760'
 	  when loc.gl_prefix = '6749' and dep.gl_prefix = '427351' then '6734'
	  when loc.gl_prefix = '6734' and dep.department_id = '18105107' then '6770'
	  when loc.gl_prefix = '6734' and dep.department_id = '18101151' then '6760'
	  when loc.gl_prefix = '6734' and dep.department_id = '18103116' then '6710'
	  when loc.gl_prefix = '6734' and dep.department_id = '18102102' then '6740'
	  else isnull(cast(loc.gl_prefix as varchar),'') end) as Entity_Code
,max(isnull(convert(varchar, tdl.pat_type_c),'')) as Patient_Type_Code 
,max(upper(isnull(patient.pat_first_name,''))) as First_Name
,max(upper(isnull(patient.pat_last_name,''))) as Last_Name
,max(upper(isnull(patient.pat_middle_name,''))) as Middle_Name
,max(isnull(convert(varchar,patient.religion_c),'')) as Religion_Code
,max(isnull(convert(varchar, patient.sex_c),'')) as Gender_Code
,max(isnull(convert(varchar(10), patient.birth_date, 112),''))  as Date_of_Birth
,max(isnull(convert(varchar,case when pr.PATIENT_RACE_C = 1 then 'WHITE'
	  when pr.PATIENT_RACE_C = 2 then 'BLACK'
	  when pr.PATIENT_RACE_C = 3 then 'NATIVE'
	  when pr.PATIENT_RACE_C = 4 then 'ASIAN'
	  when pr.PATIENT_RACE_C = 5 then 'HAWAIIAN'
	  when pr.PATIENT_RACE_C = 6 then 'OTHER'
	  when pr.PATIENT_RACE_C in (7,8) then 'UNKNOWN'
	  when pr.PATIENT_RACE_C = 9 then 'OTHER'
	  when pr.PATIENT_RACE_C = 10 then 'HISPANIC'
	  when pr.PATIENT_RACE_C = 11 then 'MULTIRACIAL'
	  else 'UNKNOWN' end),'')) as Race_Code
,max(isnull(convert(varchar, case when patient.MARITAL_STATUS_C = 1 then 'SINGLE'
	  when patient.MARITAL_STATUS_C = 2 then 'MARRIED'
	  when patient.MARITAL_STATUS_C = 3 then 'SEPARATED'
	  when patient.MARITAL_STATUS_C = 4 then 'DIVORCED'
	  when patient.MARITAL_STATUS_C = 5 then 'WIDOWED'
	  when patient.MARITAL_STATUS_C = 6 then 'UNKNOWN'
	  when patient.MARITAL_STATUS_C = 7 then 'PARTNER'
	  when patient.MARITAL_STATUS_C = 100 then 'OTHER'
	  else 'UNKNOWN' end),'')) as Marital_Status_Code
,max(isnull(left(convert(varchar, patient.ZIP),5),'')) as Zip_Code 
,max(isnull(patient.ADD_LINE_1,'')  + ' ' + isnull(patient.ADD_LINE_2,''))as Street_Address_1
,max(isnull(patient.City,'')) as City
,max(isnull(state.Name,'')) as State
,max(isnull(county.Name,'')) as County
,max(isnull(convert(varchar, patient.EMPLOYER_ID),'')) as Employer_Code
,max(isnull(convert(varchar(18),arpb_tx.ACCOUNT_ID),'')) as Guarantor_Code
,max(isnull(convert(varchar, guar_acc.EMPLOYER_ID),'')) as Guarantor_Employer_Code
,max(isnull(convert(varchar, tdl.original_plan_id),'')) as Insurance_Plan_Code
,max(isnull(convert(varchar(10), arpb_tx.SERVICE_DATE, 112),''))  as Admit_Date
,max(isnull(convert(varchar(10), arpb_tx.SERVICE_DATE, 112),'')) as Discharge_Date
,max(isnull(convert(varchar, arpb_tx.PRIMARY_DX_ID),'')) as Primary_DX_ID
,max(isnull(convert(varchar, vacd_9.dx_code),'')) as Primary_ICD9_DX_Code 
,max(isnull(convert(varchar, arpb_tx.billing_prov_id),'')) as Attend_Physician_Code
,max(isnull(convert(varchar, vacd_10.dx_code),'')) as Primary_ICD10_DX_Code 
,max(isnull(convert(varchar, arpb_tx.SERV_PROVIDER_ID),'')) as Principal_Performing_Physician_Code
,max(isnull(convert(varchar, atm.REFERRAL_PROV_ID),'')) as Refer_Physician_Code 
,max(isnull(convert(varchar, patient.CUR_PCP_PROV_ID),''))  as Primary_Care_Physician_Code
,min(isnull(convert(varchar(10), ats_bill.bc_hx_date, 112),''))  as First_Bill_Date
,max(isnull(convert(varchar(10), ats_bill.bc_hx_date, 112),''))  as Final_Bill_Date
,max(isnull(convert(varchar, arpb_tx.outstanding_amt),'')) as Account_Balance
--Historical_Expected_Payment
,max(isnull(convert(varchar, atm.EXT_CUR_AGENCY_ID),'')) as Collection_Agency
,max(isnull(atm.BAD_DEBT_CHG_YN,'')) as Collection_Status  -- 1 = YES
,min(isnull(convert(varchar(10), ats_claim.bc_hx_date, 112),''))  as First_Claim_Date
,max(isnull(convert(varchar(10), ats_claim.bc_hx_date, 112),''))  as Final_Claim_Date
,max(isnull(convert(varchar, arpb_tx.pat_enc_csn_id),'')) as Primary_CSN
,max(isnull(convert(varchar, arpb_tx.service_area_id),'')) as Service_Area
,max(isnull(convert(varchar, arpb_tx.pos_id),'')) as Place_of_Service_Code
,max(isnull(ZC_GUAR_REL_TO_PAT.NAME,'')) as Guarantor_Relationship
,'' as Last_Insurance_Payment
,'' as Last_Patient_Payment
,max(isnull(convert(varchar, case when arpb_visits.pb_total_balance = 0 then '1' else '0' end),'')) as Settled_Account_Flag
,max(isnull(convert(varchar, cov.SUBSCR_EMPLOYER_ID),'')) as Subscriber_Employer
,max(isnull(sub1.abbr,'')) as Subscriber_Relationship
,max(isnull(convert(varchar, cov.group_num),'')) as Insurance_Plan_Group_Number
,max(isnull(cov.group_name,'')) as Insurance_Plan_Group_Name
,max(isnull(convert(varchar, cov.SUBSCR_NUM),'')) as Subscriber_Number
,max(isnull(convert(varchar, tdl.cur_fin_class),'')) as Current_Financial_Class
,max(isnull(convert(varchar, tdl.cur_plan_id),'')) as Current_Insurance_Plan
,max(isnull(convert(varchar, arpb_visits.pb_visit_num),'')) as Visit_Number
,max(isnull(convert(varchar, tdl.tx_num),'')) as tx_num
,max(isnull(convert(varchar, sex.abbr),'') + isnull(convert(varchar(10), patient.birth_date, 112),'') + patient.ssn + isnull(left(patient.pat_first_name,3),''))  as 'B4ID'
,max(isnull(convert(varchar,'Epic'),'')) as Source_System

from clarity_tdl_tran tdl
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id and arpb_tx.tx_type_c = 1
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join patient on patient.pat_id = tdl.int_pat_id
left join zc_state state on patient.state_c = state.state_c
left join zc_county county on patient.county_c = county.county_c
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join arpb_visits on arpb_visits.pb_visit_id = tdl.hsp_account_id
left join acct_guar_pat_info on arpb_tx.account_id = acct_guar_pat_info.ACCOUNT_ID and arpb_tx.PATIENT_ID = acct_guar_pat_info.pat_id
left join ZC_GUAR_REL_TO_PAT on acct_guar_pat_info.GUAR_REL_TO_PAT_C = ZC_GUAR_REL_TO_PAT.GUAR_REL_TO_PAT_C
left join ACCOUNT guar_acc on arpb_tx.ACCOUNT_ID = guar_acc.ACCOUNT_ID
left join patient_race pr on patient.pat_id = pr.pat_id and pr.line = (select max(prl.line) from patient_race prl where prl.pat_id=pr.pat_id and pr.PAT_ID is not null)
left join arpb_tx_moderate atm on atm.tx_id = arpb_tx.tx_id
left join coverage cov on cov.coverage_id = tdl.original_cvg_id
left join coverage_mem_list mem1 on mem1.coverage_id = tdl.original_cvg_id
left join zc_mem_rel_to_sub sub1 on sub1.MEM_REL_TO_SUB_C = mem1.MEM_REL_TO_SUB_C
left join zc_sex sex on sex.rcpt_mem_sex_c = patient.sex_c

--DX
left join v_arpb_coding_dx vacd_9 on vacd_9.tx_id = arpb_tx.tx_id and vacd_9.line = 1 and vacd_9.source_key = 3 and vacd_9.dx_code_set_c = 1
left join v_arpb_coding_dx vacd_10 on vacd_10.tx_id = arpb_tx.tx_id and vacd_10.line = 1 and vacd_10.source_key = 3 and vacd_10.dx_code_set_c = 2
left join arpb_tx_stmclaimhx ats_bill on ats_bill.tx_id = arpb_tx.tx_id and ats_bill.bc_hx_type_c = 2	
left join arpb_tx_stmclaimhx ats_claim on ats_claim.tx_id = arpb_tx.tx_id and ats_claim.bc_hx_type_c = 1

where 
	tdl.orig_service_date >=  @start_date 
	and tdl.orig_service_date <= @end_date 
	and tdl.detail_type in (1,10)  -- Only Charges
	and tdl.serv_area_id in (11,13,16,17,18,19)

group by tdl.tx_id
order by tdl.tx_id