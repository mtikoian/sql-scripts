declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-3') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');


with charges as
(
select 
 sa.SERV_AREA_NAME
,date.YEAR_MONTH_STR
,ser.PROV_NAME
,arpb_tx.TX_ID
,eap.PROC_CODE
,eap.PROC_NAME
,arpb_tx.AMOUNT as CHARGES

from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = arpb_tx.SERVICE_AREA_ID
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.SERVICE_DATE

where arpb_tx.SERVICE_AREA_ID = 612
and arpb_tx.POST_DATE >= @start_date
and arpb_tx.POST_DATE <= @end_date
and arpb_tx.TX_TYPE_C = 1
--and arpb_tx.VOID_DATE is null
and arpb_tx.BILLING_PROV_ID = '1691029'
and arpb_tx.AMOUNT <> 0
and eap.PROC_CODE in 
 /* VACCINE */	('90698','90670','90680','90744','90633','90696','90710','90734','90621','90651','90685','90686','90707','90715'
 /* ADMIN */    ,'90460','90461','90471','90472')
),

payments as
(
select 
 tdl.TX_ID
,sum(tdl.AMOUNT)*-1 as PAYMENTS
from charges
left join CLARITY_TDL_TRAN tdl on tdl.TX_ID = charges.TX_ID and tdl.DETAIL_TYPE = 20 -- PAYMENTS
group by tdl.TX_ID
)

select 
 YEAR_MONTH_STR as 'CHG POST MONTH'
,SERV_AREA_NAME as 'SERVICE AREA'
,PROV_NAME as 'BILLING PROVIDER'
,PROC_CODE as 'PROCEDURE CODE'
,PROC_NAME as 'PROCEDURE DESC'
,sum(CHARGES) as CHARGES
,coalesce(sum(PAYMENTS),0) as PAYMENTS
from charges
left join payments on payments.TX_ID = charges.TX_ID

group by 
 YEAR_MONTH_STR
,SERV_AREA_NAME
,PROV_NAME
,PROC_CODE
,PROC_NAME