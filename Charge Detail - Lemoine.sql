DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

select
 acct.ACCOUNT_ID
,acct.ACCOUNT_NAME
,arpb_tx.SERVICE_DATE
,eap.PROC_CODE
,eap.PROC_NAME
,arpb_tx.AMOUNT
,sa.RPT_GRP_TEN as SERVICE_AREA_ID
,upper(sa.NAME) as SERVICE_AREA
,loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,ser_bill.PROV_ID as BILLING_PROVIDER_ID
,ser_bill.PROV_NAME as BILLING_PROVIDER
,ser_perf.PROV_ID as SERVICE_PROVIDER_ID
,ser_perf.PROV_NAME as SERVICE_PROVIDER
,arpb_tx.TX_ID as ETR_ID
,epm_orig.PAYOR_ID as ORIGINAL_PAYOR_ID
,epm_orig.PAYOR_NAME as ORIGINAL_PAYOR
,epm_curr.PAYOR_ID as CURRENT_PAYOR_ID
,epm_curr.PAYOR_NAME as CURRENT_PAYOR



from CLARITY_TDL_TRAN tdl
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = tdl.PERFORMING_PROV_ID
left join CLARITY_EPM epm_orig on epm_orig.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join CLARITY_EPP epp_orig on epp_orig.BENEFIT_PLAN_ID = tdl.ORIGINAL_PLAN_ID
left join CLARITY_EPM epm_curr on epm_curr.PAYOR_ID = tdl.CUR_PAYOR_ID
left join CLARITY_EPP epp_curr on epp_curr.BENEFIT_PLAN_ID = tdl.CUR_PLAN_ID

where tdl.DETAIL_TYPE =1 
and tdl.ORIG_SERVICE_DATE >= @start_date
and tdl.ORIG_SERVICE_DATE <= @end_date
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and arpb_tx.VOID_DATE is null -- EXCLUDE VOIDS
and tdl.AMOUNT <> 0

order by arpb_tx.TX_ID