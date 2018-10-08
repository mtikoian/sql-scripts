select

 tdl.TX_ID as 'Charge Transaction'
,eap.PROC_CODE as 'Charge Code'
,eap.PROC_NAME as 'Charge Description'
,tdl.ACCOUNT_ID as 'Account ID'
,acct.ACCOUNT_NAME as 'Account Name'
,pat.PAT_MRN_ID as 'Patient MRN'
,pat.PAT_NAME as 'Patient Name'
,pat.BIRTH_Date as 'Patient DOB'
,tdl.AMOUNT as 'Charge Amount'
,ser_bill.PROV_ID as 'Billing Provider ID'
,ser_Bill.PROV_NAME as 'Billing Provider Name'
,ser_perf.PROV_ID as 'Service Provider ID'
,ser_perf.PROV_NAME as 'Service Provider Name'
,fc.FINANCIAL_CLASS_NAME as 'Original Financial Class'
,epm.PAYOR_NAME as 'Original Payor'
,tdl.MODIFIER_ONE as 'Modifier 1'
,tdl.MODIFIER_TWO as 'Modifier 2'
,tdl.MODIFIER_THREE as 'Modifier 3'
,tdl.MODIFIER_FOUR as 'Modifer 4'
,tdl.PROCEDURE_QUANTITY as 'Charge Quantity'
,tdl.ORIG_SERVICE_DATE as 'Date of Service'
,loc.RPT_GRP_TEN as 'Region ID'
,upper(sa.NAME) as 'Region'
,loc.LOC_ID as 'Location ID'
,loc.LOC_NAME as 'Location Name'
,loc.GL_PREFIX as 'Location GL'
,dep.DEPARTMENT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department Name'
,dep.GL_PREFIX as 'Department GL'
,pos.POS_ID as 'Place of Service ID'
,pos.POS_NAME as 'Place of Service Name'
,pos.POS_TYPE as 'Place of Service Type'
,tdl.POST_DATE as 'Transaction Post Date'
,edg1.DX_NAME as 'Diagnosis 1'
,edg1.CURRENT_ICD10_LIST as 'ICD10 1'
,edg2.DX_NAME as 'Diagnosis 2'
,edg2.CURRENT_ICD10_LIST as 'ICD10 2'
,edg3.DX_NAME as 'Diagnosis 3'
,edg3.CURRENT_ICD10_LIST as 'ICD10 3'
,edg4.DX_NAME as 'Diagnosis 4'
,edg4.CURRENT_ICD10_LIST as 'ICD10 4'
,edg5.DX_NAME as 'Diagnosis 5'
,edg5.CURRENT_ICD10_LIST as 'ICD10 5'
,edg6.DX_NAME as 'Diagnosis 6'
,edg6.CURRENT_ICD10_LIST as 'ICD10 6'
,acct.TOTAL_BALANCE as 'Account Total Balance'
,acct.INSURANCE_BALANCE as 'Account Insurance Balance'
,acct.PATIENT_BALANCE as 'Account Patient Balance'
,csd.FIRST_CLM_DATE as 'First Claim Date'
,csd.LAST_CLM_DATE as 'Last Claim Date'
,csd.FIRST_STM_DATE as 'First Statement Date'
,csd.LAST_STM_DATE as 'Last Statement Date'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = tdl.PERFORMING_PROV_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_EDG edg1 on edg1.DX_ID = tdl.DX_ONE_ID
left join CLARITY_EDG edg2 on edg2.DX_ID = tdl.DX_TWO_ID
left join CLARITY_EDG edg3 on edg3.DX_ID = tdl.DX_THREE_ID
left join CLARITY_EDG edg4 on edg4.DX_ID = tdl.DX_FOUR_ID
left join CLARITY_EDG edg5 on edg5.DX_ID = tdl.DX_FIVE_ID
left join CLARITY_EDG edg6 on edg6.DX_ID = tdl.DX_SIX_ID
left join PATIENT pat on pat.PAT_ID = tdl. INT_PAT_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = tdl.ORIGINAL_FIN_CLASS
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join CLAIM_STMNT_DATE csd on csd.TX_ID = tdl.TX_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_POS pos on pos.POS_ID = tdl.POS_ID

where tdl.DETAIL_TYPE in (1,10)
and tdl.ORIG_SERVICE_DATE >= '10/1/2011'
and tdl.ORIG_SERVICE_DATE <= '10/31/2017'
and (ser_perf.PROV_ID = '1613265' or ser_bill.PROV_ID = '1613265')
