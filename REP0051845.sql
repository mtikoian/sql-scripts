


select 
10 [HSPCODE]
,epm.PAYOR_NAME [InsurancePlan1]
,''
,0 [Expected Reimbursement]
,sbo.SBO_HAR_TYPE_C
,hsp.ACCT_ZERO_BAL_DT
/*
,case when tdl.DETAIL_TYPE in ('1','10') then tdl.INSURANCE_AMOUNT  end CurrentInsuranceBalance
,case when tdl.cur_payor_id is null and  tdl.detail_type = '2' then tdl.PATIENT_AMOUNT * -1.0 end [CurrentPatientBalance]
,case when tdl.DETAIL_TYPE in ('1','10') then tdl.AMOUNT end [TotalCharges]
,case when tdl.cur_payor_id is not null and tdl.detail_type = '2' then tdl.AMOUNT end [TotalInsurancePayments]
,case when tdl.cur_payor_id is null and  tdl.detail_type = '2' then tdl.amount * -1.0 end TotalPatientPayments
,case when tdl.detail_type in ('4','6','13','21','23','30','31') then tdl.AMOUNT end [TotalAdjustments]
*/
,sum(case when tdl.detail_type in (1) then arpb.PATIENT_AMT else 0 end) [CurrentPatientBalance]
,sum(case when tdl.detail_type in (1) then arpb.INSURANCE_AMT else 0 end) [CurrentInsuranceBalance]
,0 [Total Account Balance]
,max(arpb.CLAIM_DATE) [Final Bill Date]
,sum(case when tdl.DETAIL_TYPE in ('1','10') then tdl.AMOUNT end) [TotalCharges]
,'-' [Total Payments]
--,sum(case when tdl.cur_payor_id is not null and tdl.DETAIL_TYPE in ('2','5','11','20','22','32','33') then tdl.AMOUNT else 0 end) [TotalInsurancePayments]
,sum(case when (tdl.detail_type in (2,5,11,32,33) AND tdl.original_payor_id is not null) or (tdl.detail_type in (20,22) and tdl.match_payor_id is not null) then tdl.ACTIVE_AR_AMOUNT else 0 end) [TotalInsurancePayments]
--,sum(case when tdl.cur_payor_id is null and tdl.DETAIL_TYPE in ('2','5','11','20','22','32','33') then tdl.amount else 0 end) [TotalPatientPayments]
,sum(case when (tdl.detail_type in (2,5,11,32,33) AND tdl.original_payor_id is null) or (tdl.detail_type in (20,22) and tdl.match_payor_id is null) then tdl.ACTIVE_AR_AMOUNT else 0 end) [TotalPatientPayments]
,sum(case when tdl.DETAIL_TYPE in ('4','6','13','21','23','30','31') then tdl.AMOUNT end) [TotalAdjustments] --,'4','6','12','13','21','23','30','31') 

from CLARITY_TDL_TRAN tdl
inner join ARPB_TRANSACTIONS arpb on arpb.TX_ID = tdl.TX_ID
LEFT outer join PAT_ENC pe on pe.PAT_ENC_CSN_ID = tdl.PAT_ENC_CSN_ID
left outer join COVERAGE cvg on cvg.COVERAGE_ID = pe.COVERAGE_ID
left outer join CLARITY_EPM epm on epm.PAYOR_ID = cvg.PAYOR_ID
LEFT outer join PATIENT pat on pat.PAT_ID = pe.PAT_ID
LEFT outer join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID 
left outer join ZC_STATE zc_state on zc_state.STATE_C = acct.STATE_C
left outer join hsp_account hsp on hsp.hsp_account_id = tdl.hsp_account_id
LEFT outer join HSP_ACCT_SBO sbo on sbo.HSP_ACCOUNT_ID = tdl.HSP_ACCOUNT_ID

where cast(hsp.ACCT_ZERO_BAL_DT as date) between dateadd("d",1,CLARITY_REPORT.RELATIVE_START_DATE('{?StartDate}'))
	and dateadd("d",1,CLARITY_REPORT.RELATIVE_END_DATE('{?EndDate}'))
and sbo.SBO_HAR_TYPE_C in(2,0)
and tdl.SERV_AREA_ID=10
--and hsp_act.HSP_ACCOUNT_ID=35352935	

group by
tdl.PAT_ID
,sbo.SBO_HAR_TYPE_C
,tdl.HSP_ACCOUNT_ID
,pat.SSN 
,pat.PAT_LAST_NAME 
,pat.PAT_FIRST_NAME 
,pat.PAT_MIDDLE_NAME 
,acct.ACCOUNT_NAME
,acct.BIRTHDATE 
,acct.SSN 
,hsp.ACCT_ZERO_BAL_DT
,acct.BILLING_ADDRESS_1 
,acct.BILLING_ADDRESS_2 
,acct.CITY 
,zc_state.NAME 
,acct.ZIP 
,epm.PAYOR_NAME
,pat.pat_name