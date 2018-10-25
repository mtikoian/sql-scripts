with dates as
(
select 
 *
from DATE_DIMENSION date
where date.YEAR_MONTH >= '201810'
and WEEKEND_YN = 'N'
),

goals as
(
select 
*
from dates
inner join ClarityCHPUtil.rpt.PB_FRONT_DESK_GOALS goals on goals.MONTH_YEAR = dates.YEAR_MONTH
where DEPARTMENT_ID = 19101101

),

payments as
(
select
 date.YEAR
,date.YEAR_MONTH
,date.CALENDAR_DT
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,upper(sa.NAME) as REGION
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
and arpb_tx.POST_DATE >= '10/1/2018'
and arpb_tx.POST_DATE <= '10/31/2018'
and dep.DEPARTMENT_ID = 19101101

group by
 date.YEAR
,date.YEAR_MONTH
,date.CALENDAR_DT
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,upper(sa.NAME)

)

select 
 goals.CALENDAR_DT
,goals.DEPARTMENT_ID
,payments.DEPARTMENT_NAME
,payments.YEAR_MONTH
,goals.DAILY_GOAL
,goals.MONTHLY_GOAL
,goals.BUS_DAYS
,payments.PAYMENTS
,RN = ROW_NUMBER() OVER (PARTITION BY goals.DEPARTMENT_ID ORDER BY goals.CALENDAR_DT DESC)
,sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT rows between 6 preceding and current row)

from goals
left join payments on payments.DEPARTMENT_ID = goals.DEPARTMENT_ID and payments.CALENDAR_DT = goals.CALENDAR_DT

order by goals.CALENDAR_DT