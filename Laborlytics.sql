declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select
 loc.gl_prefix as 'FACILITY'
,dep.gl_prefix as 'COST CENTER'
,'ACCOUNTS' as 'SERVICE CODE'
,'ACCOUNTS' as 'STATISTIC DESCRIPTION'
--SERVICE DATE
--USER ID
--QUANTITY
/*
Dept ID	Epic Job Title ID
7142846493	10000
7142846493	10001
7142846493	10002
7142846493	10003
7142846493	10004
7142846497	10005
7142846499	10006
7142846500	10007
7142846500	10008
7142846500	10009
7142852003	10010
*/
,case when EMPL_DEM_ONE_C in (10000,10001,10002,10003,10004) then 7142846493
	  when EMPL_DEM_ONE_C = 10005 then 7142846497
	  when EMPL_DEM_ONE_C = 10006 then 7142846499
	  when EMPL_DEM_ONE_C in (10007,10008,10009) then 7142846500
	  when EMPL_DEM_ONE_C = 10010 then 7142852003
	  else 0 end as 'DEPARTMENT'
--,hx.TAR_ID
,hx.USER_ID as 'USER ID'
,emp.name as 'USER NAME'
,DEFAULT_SVC_DATE ' SERVICE DATE'
,activity_date as 'ACTIVITY DATE'
,count(distinct pac.account_id) as Count
from PRE_AR_CHG_HX hx
left join pre_ar_chg pac on hx.tar_id = pac.tar_id
left join clarity_dep dep on dep.department_id = pac.sess_dept_id
left join clarity_loc loc on loc.loc_id = pac.loc_id
left join pre_ar_chg_2 pac2 on pac2.tar_id = pac.tar_id
left join clarity_emp emp on emp.user_id = hx.user_id
inner join EMPL_DEMOGRAPHICS ed on ed.user_id = emp.user_id
where --activity_date = convert(date,getdate()-1)
activity_date = '01/31/2018'
and DEFAULT_SVC_DATE <= convert(date,getdate()-1)
and pac.serv_area_id in (11,13,16,17,18,19)
and (hx.user_id is not null and hx.user_id <> '1')
and EMPL_DEM_ONE_C is not null
group by 
 loc.gl_prefix
,dep.gl_prefix
,EMPL_DEM_ONE_C
,hx.USER_ID
,emp.name
,DEFAULT_SVC_DATE
,activity_date

order by 
 loc.gl_prefix
,dep.gl_prefix
,EMPL_DEM_ONE_C
,hx.USER_ID
,emp.name
,DEFAULT_SVC_DATE
,activity_date
