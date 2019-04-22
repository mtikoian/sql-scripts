select 
 ser.PROV_NAME as BILLING_PROVIDER
,sum(RVU_WORK) as RVU_WORK
,sum(PROCEDURE_QUANTITY) as PROCEDURE_QUANTITY
,count(*) as TOTAL_CHARGE_COUNT
,count(distinct PATIENT_ID) as DISTINCT_PATIENT_COUNT

from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID

where BILLING_PROV_ID in ('3052252', '1611785')
and arpb_tx.POST_DATE between '1/1/2018' and '12/31/2018'
and arpb_tx.VOID_DATE is null
and arpb_tx.TX_TYPE_C = 1

group by PROV_NAME
order by PROV_NAME
-------------------------------------------------------------------
