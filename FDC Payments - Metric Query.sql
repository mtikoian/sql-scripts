select distinct
GROUPING_ID (arpb_tx.DEPARTMENT_ID, arpb_tx.USER_ID) as GROUPING_ID
,arpb_tx.DEPARTMENT_ID
,arpb_tx.USER_ID
,date.MONTH_BEGIN_DT as DATE
,'1' as '1'
,sum(case when arpb_tx.VOID_DATE = arpb_tx.POST_DATE then 0 else arpb_tx.AMOUNT * -1 end) as PAYMENTS

from Clarity.dbo.ARPB_TRANSACTIONS arpb_tx
left join Clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join Clarity.dbo.CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID

where arpb_tx.SERVICE_AREA_ID in (19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')
and arpb_tx.POST_DATE >= '10/01/2018'
and arpb_tx.DEPARTMENT_ID not in (19000001)

GROUP BY GROUPING SETS ( arpb_tx.DEPARTMENT_ID, arpb_tx.USER_ID ),
  arpb_tx.DEPARTMENT_ID
,arpb_tx.USER_ID
,date.MONTH_BEGIN_DT



UNION ALL



SELECT DISTINCT
1 as GROUPING_ID
,arpb_tx.DEPARTMENT_ID
,NULL as USER_ID
,date.MONTH_BEGIN_DT as DATE
,'1' as '1'
,sum(case when arpb_tx.VOID_DATE = arpb_tx.POST_DATE then 0 else arpb_tx.AMOUNT * -1 end) as PAYMENTS

from Clarity.dbo.ARPB_TRANSACTIONS arpb_tx
left join Clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join Clarity.dbo.CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID

where arpb_tx.SERVICE_AREA_ID in (19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')
and arpb_tx.POST_DATE >= '10/01/2018'
and arpb_tx.DEPARTMENT_ID not in (19000001)

GROUP BY arpb_tx.DEPARTMENT_ID,
  date.MONTH_BEGIN_DT
