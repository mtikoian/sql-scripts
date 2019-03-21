select 
 loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,date.YEAR_MONTH
,sum(case when arpb_tx.VOID_DATE = arpb_tx.POST_DATE then 0 else arpb_tx.AMOUNT * -1 end) as PAYMENTS

from Clarity.dbo.ARPB_TRANSACTIONS arpb_tx
left join Clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join Clarity.dbo.CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join Clarity.dbo.CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join Clarity.dbo.CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID

where arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')
and dep.DEPARTMENT_ID not in ('19000001')
and loc.LOC_ID not in (
'197100', 
'197000', 
'19106', 
'19108', 
'19000', 
'193300', 
'193200', 
'193500', 
'196100', 
'196000', 
'19137', 
'195000', 
'195100', 
'195100', 
'195400', 
'195400', 
'194000'
)

GROUP BY
 loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,date.YEAR_MONTH


ORDER BY
 loc.LOC_ID
,loc.LOC_NAME
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,date.YEAR_MONTH