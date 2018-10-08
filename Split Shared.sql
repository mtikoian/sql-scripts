declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');

with shared as
(
select 
 tdl.TX_ID
,tdl.ORIG_SERVICE_DATE
,tdl.POST_DATE
,ser.PROV_NAME
,upper(sa.NAME) as REGION
,tdl.DEPT_ID
,dep.DEPARTMENT_NAME
,pos.POS_ID
,pos.POS_NAME
,pos.POS_TYPE
,tdl.INT_PAT_ID
,pat.PAT_NAME
,eap.PROC_CODE
,eap.PROC_NAME
,tdl.AMOUNT
from CLARITY_TDL_TRAN tdl 
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_POS pos on pos.POS_ID = tdl.POS_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where eap.PROC_CODE in ('APPSS15','APPSS30','APPSS45','APPSS60','APPSS180','APPNB15','APPNB45','APPNB60','APPNB180','APPNB30')
and tdl.DETAIL_TYPE in (1)
and tdl.ORIG_SERVICE_DATE >= @start_date
and tdl.ORIG_SERVICE_DATE <= @end_date
)

select
 shared.TX_ID as 'CHARGE ETR'
,cast(shared.ORIG_SERVICE_DATE as date) as 'SERVICE DATE'
,cast(shared.POST_DATE as date) as 'POST DATE'
,shared.PROV_NAME as 'BILLING PROVIDER'
,shared.REGION as 'REGION'
,shared.DEPARTMENT_NAME as 'DEPARTMENT'
,shared.POS_NAME as 'POS'
,shared.POS_TYPE as 'POS TYPE'
,shared.INT_PAT_ID as 'PATIENT ID'
,shared.PAT_NAME as 'PATIENT'
,shared.PROC_CODE as 'SHARED CODE'
,shared.PROC_NAME as 'SHARED DESC'
,shared.AMOUNT as 'SHARED AMOUNT'
,tdl.TX_ID as 'MATCHED CHARGE ETR'
,ser.PROV_NAME as 'MATCHED BILLING PROVIDER'
,eap.PROC_CODE as 'MATCHED PROCEDURE CODE'
,eap.PROC_NAME as 'MATCHED PROCEDURE DESC'
,tdl.AMOUNT as 'MATCHED AMOUNT'
,tdl.RVU_WORK as 'MATCHED wRVU'
from shared
left join CLARITY_TDL_TRAN tdl on tdl.ORIG_SERVICE_DATE = shared.ORIG_SERVICE_DATE and tdl.DEPT_ID = shared.DEPT_ID and tdl.INT_PAT_ID = shared.INT_PAT_ID and tdl.TX_ID <> shared.TX_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID

where tdl.DETAIL_TYPE in (1)
and eap.PROC_CODE not in ('APPSS15','APPSS30','APPSS45','APPSS60','APPSS180','APPNB15','APPNB45','APPNB60','APPNB180','APPNB30')
and tdl.ORIG_SERVICE_DATE >= @start_date
and tdl.ORIG_SERVICE_DATE <= @end_date

order by shared.INT_PAT_ID, shared.ORIG_SERVICE_DATE