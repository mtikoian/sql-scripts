declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-3') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-3');

select 
 sa.SERV_AREA_NAME as 'SERVICE AREA'
,ser.PROV_NAME as 'BILLING PROVIDER'
,cast(arpb_tx.POST_DATE as date) as 'POST DATE'
,cast(arpb_tx.VOID_DATE as date) as 'VOID DATE'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'
,sum(arpb_tx.AMOUNT) as CHARGES

from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = arpb_tx.SERVICE_AREA_ID
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID

where arpb_tx.SERVICE_AREA_ID = 612
and arpb_tx.POST_DATE >= @start_date
and arpb_tx.POST_DATE <= @end_date
and arpb_tx.TX_TYPE_C = 1
--and arpb_tx.VOID_DATE is null
and arpb_tx.BILLING_PROV_ID = '1691029'
and arpb_tx.AMOUNT <> 0

group by 
 sa.SERV_AREA_NAME
,ser.PROV_NAME
,cast(arpb_tx.POST_DATE as date)
,cast(arpb_tx.VOID_DATE as date)
,eap.PROC_CODE
,eap.PROC_NAME

order by 
 sa.SERV_AREA_NAME
,ser.PROV_NAME
,cast(arpb_tx.POST_DATE as date)
,cast(arpb_tx.VOID_DATE as date)
,eap.PROC_CODE
,eap.PROC_NAME