select 
 tdl.TX_ID as CHARGE_ID
,cast(tdl.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,cast(tdl.POST_DATE as date) as POST_DATE
,sa.RPT_GRP_TEN as REGION_ID
,upper(sa.NAME) as REGION
,loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,eap.PROC_CODE as CPT_CODE
,eap.PROC_NAME as CPT_DESCRIPTION
,ser_bill.PROV_NAME as BILLING_PROVIDER
,ser_perf.PROV_NAME as SERVICE_PROVIDER
,tdl.AMOUNT as CHARGE_AMT
,tdl.PROCEDURE_QUANTITY as UNITS

from clarity_tdl_tran tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_id
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = tdl.PERFORMING_PROV_ID
where tdl.proc_id in 
(30779
,23656
,23658
,23660
,23662
,23664) 

and tdl.detail_type = 1
and orig_service_Date >= '1/1/2018'
and arpb_tx.VOID_DATE is null
and loc.RPT_GRP_TEN in (1,11,13,16,17,18,19)

order by tdl.TX_ID
