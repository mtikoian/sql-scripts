declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');

select 
 sa.SERV_AREA_NAME as 'SERVICE AREA'
,loc.LOC_NAME as 'LOCATION'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE DATE'
,cast(tdl.POST_DATE as date) as 'POST DATE'
,ser.PROV_NAME as 'BILLING PROVIDER'
,tdl.TX_ID as 'CHARGE ID'
,eap_chg.PROC_CODE as 'CHARGE CODE'
,eap_chg.PROC_NAME as 'CHARGE CODE DESC'
,tdl.ORIG_AMT as 'CHARGE AMT'
,tdl.MATCH_TRX_ID as 'PAYMENT ID'
,eap_pay.PROC_CODE as 'PAYMENT CODE'
,eap_pay.PROC_NAME as 'PAYMENT CODE DESC'
,tdl.AMOUNT as 'PAYMENT AMT'

from CLARITY_TDL_TRAN tdl 
left join CLARITY_SA sa on sa.SERV_AREA_ID = tdl.SERV_AREA_ID
left join CLARITY_EAP eap_chg on eap_chg.PROC_ID = tdl.PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_EAP eap_pay on eap_pay.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID

where tdl.SERV_AREA_ID = 310 
and tdl.DETAIL_TYPE in (20) -- MATCHED PAYMENTS
and tdl.POST_DATE >= @start_date
and tdl.POST_DATE <= @end_date
and tdl.AMOUNT <> 0

order by tdl.TX_ID