with dates as
(
select 
 *
from DATE_DIMENSION date
where date.YEAR_MONTH >= '201810'
and WEEKEND_YN = 'N'
and HOLIDAY_YN = 'N'
and CALENDAR_DT <= EPIC_UTIL.EFN_DIN('me')
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

from goals
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.POST_DATE = goals.CALENDAR_DT and arpb_tx.DEPARTMENT_ID = goals.DEPARTMENT_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where arpb_tx.SERVICE_AREA_ID in (19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')

group by
 date.YEAR
,date.YEAR_MONTH
,date.CALENDAR_DT
,dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,upper(sa.NAME)

)

select 
-- cast(goals.CALENDAR_DT as date) as DATE
--,goals.YEAR_MONTH
--,goals.DEPARTMENT_ID
--,dep.DEPARTMENT_NAME
--,goals.DAILY_GOAL
--,goals.MONTHLY_GOAL
--,payments.PAYMENTS as DAILY_PAYMENTS
--,sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT) as CUMULATIVE_PAYMENTS
--,sum(goals.DAILY_GOAL) over (order by goals.CALENDAR_DT) as CUMULATIVE_DAILY_GOAL
--,(sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT) / goals.MONTHLY_GOAL)  as MTD_PROGRESS
--,goals.MONTHLY_GOAL - sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT) as REMAINING_GOAL
--,BUS_DAYS_COUNTDOWN = ROW_NUMBER() OVER (PARTITION BY goals.DEPARTMENT_ID ORDER BY goals.CALENDAR_DT DESC)
--,cast((goals.MONTHLY_GOAL - sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT)) / (ROW_NUMBER() OVER (PARTITION BY goals.DEPARTMENT_ID ORDER BY goals.CALENDAR_DT DESC)) as decimal(10,2)) as UPDATED_DAILY_GOAL


 goals.Department_ID as DepartmentID
,cast(goals.CALENDAR_DT as date) as Date
,'1' as '1'
,goals.MONTHLY_GOAL - sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT) as UpdatedDailyGoalNum
,ROW_NUMBER() OVER (PARTITION BY goals.DEPARTMENT_ID ORDER BY goals.CALENDAR_DT DESC) as UpdatedDailyGoalDen
,'2' as '2'
,goals.Monthly_Goal as MonthlyGoal
,'3' as '3'
,sum(payments.PAYMENTS) over (order by goals.CALENDAR_DT) as CumulativePayments

from goals
left join payments on payments.DEPARTMENT_ID = goals.DEPARTMENT_ID and payments.CALENDAR_DT = goals.CALENDAR_DT
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = goals.DEPARTMENT_ID

order by goals.CALENDAR_DT