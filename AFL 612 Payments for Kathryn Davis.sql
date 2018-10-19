declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-3') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');

select 
 SERV_AREA_NAME as 'SERVICE AREA'
,ser.PROV_NAME as 'BILLING PROVIDER'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'
,sum(tdl.AMOUNT) * -1 as 'PAYMENT AMOUNT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = tdl.SERV_AREA_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID


where tdl.SERV_AREA_ID = 612
and tdl.POST_DATE >= @start_date
and tdl.POST_DATE <= @end_date
and tdl.DETAIL_TYPE in (20) -- CHARGE MATCHED TO PAYMENTS
and tdl.BILLING_PROVIDER_ID = '1691029'
and tdl.AMOUNT <> 0
and eap.PROC_CODE in 
 /* VACCINE */	('90698','90670','90680','90744','90633','90696','90710','90734','90621','90651','90685','90686','90707','90715'
 /* ADMIN */    ,'90460','90461','90471','90472')

group by 
 SERV_AREA_NAME
,ser.PROV_NAME
,eap.PROC_CODE
,eap.PROC_NAME

order by 
 SERV_AREA_NAME
,ser.PROV_NAME
,eap.PROC_CODE
,eap.PROC_NAME