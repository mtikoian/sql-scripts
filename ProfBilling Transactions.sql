select
 tdl.ORIG_SERVICE_DATE as 'Service Date'
,tdl.POST_DATE as 'Post Date'
,det.DETAIL_TYPE as 'Detail Type ID'
,det.NAME as 'Detail Type'
,eap.PROC_CODE as 'Procedure Code'
,eap.PROC_NAME as 'Procedure'
,eap.GL_NUM_CREDIT as 'Procedure GL Credit'
,eap.GL_NUM_DEBIT as 'Procedure GL Debit'
,eap_match.PROC_CODE as 'Procedure Code - Matched'
,eap_match.PROC_NAME as 'Procedure - Matched'
,tdl.DEPT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department'
,dep.SPECIALTY as 'Department Specialty'
,dep.GL_PREFIX as 'Department GL'
,tdl.LOC_ID as 'Location ID'
,loc.LOC_NAME as 'Location'
,loc.GL_PREFIX as 'Location GL'
,sa.RPT_GRP_TEN as 'Region ID'
,upper(sa.NAME) as 'Region'
,ser_bill.PROV_ID as 'Billing Provider ID'
,ser_bill.PROV_NAME as 'Billing Provider'
,ser_perf.PROV_ID as 'Service Provider ID'
,ser_perf.PROV_NAME as 'Service Provider'
,orig_fc.FINANCIAL_CLASS_NAME as 'Original FC'
,cur_fc.FINANCIAL_CLASS_NAME as 'Current FC'
,tdl.PATIENT_AMOUNT as 'Patient Amount'
,tdl.INSURANCE_AMOUNT as 'Insurance Amount'
,tdl.AMOUNT as 'Amount'

from CLARITY.dbo.CLARITY_TDL_TRAN tdl
left join ZC_DETAIL_TYPE det on det.DETAIL_TYPE = tdl.DETAIL_TYPE
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_EAP eap_match on eap_match.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = tdl.PERFORMING_PROV_ID
left join CLARITY_FC orig_fc on orig_fc.FINANCIAL_CLASS = tdl.ORIGINAL_FIN_CLASS
left join CLARITY_FC cur_fc on cur_fc.FINANCIAL_CLASS = tdl.CUR_FIN_CLASS

where tdl.POST_DATE >= '5/1/2018'
and tdl.POST_DATE <= '5/31/2018'
and tdl.DETAIL_TYPE <= 33
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)