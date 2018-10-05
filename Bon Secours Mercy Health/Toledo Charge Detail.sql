select
 tdl.TX_ID as CHARGE_ETR
,cast(tdl.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,cast(tdl.POST_DATE as date) as POST_DATE
,sa.RPT_GRP_TEN as REGION_ID
,upper(sa.NAME) as REGION_NAME
,loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,eap.PROC_CODE
,eap.PROC_NAME
,ser_bill.PROV_ID as BILL_PROV_ID
,ser_bill.PROV_NAME as BILL_PROV_NAME
,ser_perf.PROV_ID as SERV_PROV_ID
,ser_perf.PROV_NAME as SERV_PROV_NAME
,tdl.AMOUNT

from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = tdl.PERFORMING_PROV_ID

where 
tdl.ORIG_SERVICE_DATE >= '3/1/2018'
and tdl.ORIG_SERVICE_DATE <= '5/31/2018'
and tdl.DETAIL_TYPE in (1,10)
and sa.RPT_GRP_TEN = 18

order by tdl.TX_ID
