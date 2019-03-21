with goals as
(
select 

 goals.DEPARTMENT_ID
,date.MONTH_BEGIN_DT as DATE
,'1' as '1'
,goals.MONTHLY_GOAL
,'2' as '2'
,goals.DAILY_GOAL

from ClarityCHPUtil.rpt.PB_FRONT_DESK_GOALS goals
left join Clarity.dbo.DATE_DIMENSION date on date.YEAR_MONTH = goals.MONTH_YEAR

GROUP BY
 goals.DEPARTMENT_ID
,date.MONTH_BEGIN_DT
,goals.MONTHLY_GOAL
,goals.DAILY_GOAL
),

busdays as 

(select
              DATE_DIMENSION.MONTH_BEGIN_DT
              , sum(1) as BUS_DAYS
from 
              Clarity.dbo.DATE_DIMENSION
where 
              DATE_DIMENSION.WEEKEND_YN = 'N' 
              and DATE_DIMENSION.HOLIDAY_YN = 'N' 
              and DATE_DIMENSION.CALENDAR_DT >= convert(date,getdate())

group by
              DATE_DIMENSION.MONTH_BEGIN_DT
)

select 
 goals.DEPARTMENT_ID
,goals.DATE
,goals.[1]
,goals.MONTHLY_GOAL
,goals.[2]
,goals.DAILY_GOAL
,'3' as '3'
,busdays.BUS_DAYS
from goals
left join busdays on busdays.MONTH_BEGIN_DT = goals.DATE