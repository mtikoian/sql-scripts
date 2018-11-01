declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');

select 
 date.YEAR_MONTH
,SERV_AREA_NAME as 'SERVICE AREA'
,ser.PROV_NAME as 'BILLING PROVIDER'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'
,sum(tdl.AMOUNT) as 'CHARGE AMOUNT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = tdl.SERV_AREA_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.ORIG_SERVICE_DATE


where tdl.SERV_AREA_ID = 612
and tdl.ORIG_SERVICE_DATE >= @start_date
and tdl.ORIG_SERVICE_DATE <= @end_date
and tdl.DETAIL_TYPE in (1) -- CHARGE MATCHED TO PAYMENTS
--and tdl.BILLING_PROVIDER_ID = '1691029'
and tdl.AMOUNT <> 0
and eap.PROC_CODE not in 
 /* VACCINE */	('90698','90670','90680','90744','90633','90696','90710','90734','90621','90651','90685','90686','90707','90715'
 /* ADMIN */    ,'90460','90461','90471','90472')
and arpb_tx.VOID_DATE is null

group by 
 date.YEAR_MONTH
,SERV_AREA_NAME
,ser.PROV_NAME
,eap.PROC_CODE
,eap.PROC_NAME

order by 
 date.YEAR_MONTH
,SERV_AREA_NAME
,ser.PROV_NAME
,eap.PROC_CODE
,eap.PROC_NAME