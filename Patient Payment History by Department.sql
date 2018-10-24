
select
 date.YEAR
,date.MONTH_NUMBER
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,upper(sa.NAME) as REGION
,eap.PROC_NAME
,sum(case when arpb_tx.VOID_DATE = arpb_tx.POST_DATE then 0 else arpb_tx.AMOUNT * -1 end) as PAYMENTS

from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where arpb_tx.SERVICE_AREA_ID in (19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')
and arpb_tx.POST_DATE >= '1/1/2017'

group by 
 date.YEAR
,date.MONTH_NUMBER
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,sa.RPT_GRP_TEN
,sa.NAME
,eap.PROC_NAME
