declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1');


with ar as
(
select date.CALENDAR_DT, date.YEAR_MONTH, date.MONTHNAME_YEAR, loc.rpt_grp_ten, sa.NAME as Region, loc.loc_id, loc.loc_name, dep.department_id, dep.department_name, sum(amount) as ar
from CLARITY_TDL_AGE age 
left join CLARITY_LOC loc on loc.LOC_ID = age.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = age.DEPT_ID
left join date_dimension date on date.CALENDAR_DT = age.post_date
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where post_date >= '01/01/2018'
and loc.rpt_grp_ten in (11,13,16,17,18,19)
group by date.CALENDAR_DT, date.YEAR_MONTH, date.MONTHNAME_YEAR, loc.rpt_grp_ten, sa.NAME, loc.loc_id, loc.loc_name, dep.department_id, dep.department_name
),

charges as
(

select post_date, rpt_grp_ten, dept_id, sum(amount) as charges
from clarity_tdl_tran tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
where tdl.detail_type in (1,10)
and tdl.serv_area_id in (11,13,16,17,18,19)
and post_date >= '1/1/2017'
and post_date <= @end_date
group by post_date, rpt_grp_ten, dept_id
)

select a.CALENDAR_DT, a.YEAR_MONTH, a.MONTHNAME_YEAR, SERVICE_AREA, a.REGION, coalesce(cast(a.DEPARTMENT_ID as nvarchar),'Unknown Department') as DEPARTMENT_ID, a.DEPARTMENT_NAME
,a.LOC_ID, a.LOC_NAME, a.ar, charges

from

(
select 
ar.CALENDAR_DT
,ar.YEAR_MONTH
,ar.MONTHNAME_YEAR
,ar.RPT_GRP_TEN as SERVICE_AREA
,ar.REGION
,ar.DEPARTMENT_ID
,ar.DEPARTMENT_NAME
,ar.LOC_ID
,ar.LOC_NAME
,ar.ar
,sum(case when charges.charges is null or charges.charges = 0 then 0 else charges.charges end) charges

from ar 
left join charges on charges.dept_id = ar.department_id and charges.post_date between DATEADD(dd, DATEDIFF(dd, 0, ar.CALENDAR_DT)-91, 0) and ar.CALENDAR_DT
group by 
ar.CALENDAR_DT
,ar.YEAR_MONTH
,ar.MONTHNAME_YEAR
,ar.RPT_GRP_TEN
,ar.REGION
,ar.DEPARTMENT_ID
,ar.DEPARTMENT_NAME
,ar.LOC_ID
,ar.LOC_NAME
,ar.ar
)a

order by a.DEPARTMENT_ID, a.CALENDAR_DT
