select 
 date.YEAR
,date.YEAR_MONTH
,date.CALENDAR_DT
,arpb_tx.TX_ID
,atm.CASH_ID
,eap.PROC_NAME
,arpb_tx.DEPARTMENT_ID
,csh.LOGIN_DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,src.NAME as CREDIT_SOURCE
,emp.NAME as 'USER'
,arpb_tx.AMOUNT * - 1 as PAYMENT
,atm.CASH_ID

from ARPB_TRANSACTIONS arpb_tx
left join ARPB_TX_MODERATE atm on atm.TX_ID = arpb_tx.TX_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_EMP emp on emp.USER_ID = arpb_tx.USER_ID
left join ZC_MTCH_DIST_SRC src on src.MTCH_TX_HX_DIST_C = arpb_tx.CREDIT_SRC_MODULE_C
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join HSP_CSH csh on csh.CSH_ID = atm.CASH_ID

where arpb_tx.POST_DATE >= '1/1/2017'
and arpb_tx.SERVICE_AREA_ID = 19 -- Mercy Health
and arpb_tx.TX_TYPE_C = 2 -- Payments
and eap.PROC_CODE in ('1000','1001','1002') -- Include Patient Payments, Co-Payments, Pre-Payments
and arpb_tx.CREDIT_SRC_MODULE_C in (6,12,20,37) -- Charge Entry (Fast Payments), My Chart Web, Check-in/Check-out, POS Payment Posting
--and arpb_tx.DEPARTMENT_ID not in (19000001) -- Exclude Billing Office
and arpb_tx.VOID_DATE is null -- Exclude Voids