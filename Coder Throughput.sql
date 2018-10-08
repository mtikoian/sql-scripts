declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 

date.year_month as 'Year-Month'
,date.month_name as 'Month'
,count(*) as 'Claim Count'
,count(distinct(emp.user_id)) as 'Distinct User Count'
,cast(count(*) as float)/cast(count(distinct(emp.user_id)) as float) as 'Average Per Coder'
 
from WQF_CR_WQ wcw
left join ZC_OWNING_AREA_2 oa on oa.owning_area_2_c = wcw.owning_area_c
left join PRE_AR_CHG_HX pac on pac.workqueue_id = wcw.workqueue_id
left join clarity_emp emp on emp.user_id = pac.user_id
left join date_dimension date on date.calendar_dt_str = activity_date
where 
owning_area_2_c in (13,14,15,16,42,43,44,1640000004)
/*
13			Coding 1
14			Coding 2
15			Coding 3
16			Coding 4
42			Coding 5
43			Coding 6
44			Coding 7
1640000004	Coding
*/
and activity_c = 106 -- Charge Filed
and activity_date >= @start_date
and activity_date <= @end_date
and wcw.service_area_id in (11,13,16,17,18,19)

group by 
 date.year_month
,date.month_name

order by 
 date.year_month
,date.month_name