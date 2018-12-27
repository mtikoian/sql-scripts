declare @end_date as date = EPIC_UTIL.EFN_DIN('me');

with goals as 
(
select 
 distinct
 goals.DEPARTMENT_ID
,goals.MONTH_YEAR
,goals.MONTHLY_GOAL
from ClarityCHPUtil.rpt.PB_FRONT_DESK_GOALS goals
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = goals.DEPARTMENT_ID
left join DATE_DIMENSION date on date.YEAR_MONTH = goals.MONTH_YEAR
where date.MONTH_NUMBER <= month(getdate())
and date.YEAR <= year(getdate())
-- and goals.DEPARTMENT_ID = 19151112
),

payments as
(
select
 arpb_tx.DEPARTMENT_ID
,date.YEAR_MONTH_STR
,date.YEAR_MONTH
,sum(case when arpb_tx.VOID_DATE = arpb_tx.POST_DATE then 0 else arpb_tx.AMOUNT * -1 end) as PAYMENT
from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
where arpb_tx.SERVICE_AREA_ID in (19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')
and arpb_tx.POST_DATE >= '10/1/2018'
--and arpb_tx.DEPARTMENT_ID = 19151112
group by
 arpb_tx.DEPARTMENT_ID
,date.YEAR_MONTH_STR
,date.YEAR_MONTH
)

select 
 goals.DEPARTMENT_ID as 'DEPARTMENT ID'
,dep.DEPARTMENT_NAME as DEPARTMENT
,loc.LOC_ID as 'LOCATION ID'
,loc.LOC_NAME as LOCATION
,sa.RPT_GRP_TEN as MARKET_ID
,upper(sa.NAME) as MARKET
,goals.MONTH_YEAR as 'YEAR MONTH'
,coalesce(payments.PAYMENT,0) as PAYMENT
,goals.MONTHLY_GOAL as 'MONTHLY GOALS'

from goals
left join payments on payments.DEPARTMENT_ID = goals.DEPARTMENT_ID and payments.YEAR_MONTH = goals.MONTH_YEAR
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = goals.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
order by goals.DEPARTMENT_ID
,goals.MONTH_YEAR