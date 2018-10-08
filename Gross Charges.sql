select 
coalesce(loc.gl_prefix + ' - ' + loc.loc_name,'*Unknown Location') as 'Location'
,coalesce(loc.gl_prefix + ' - ' + dep.gl_prefix + ' - ' + dep.department_name,'*Unknown Department') 'Department'
,fc.name as 'Fincancial Class'
,sum(amount) as 'Charge Amt'
from clarity_tdl_tran tdl
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_financial_class fc on fc.financial_class = tdl.original_fin_class
where detail_type in (1,10)
and post_date between '8/1/2017' and '8/31/2017'
and tdl.serv_area_id in (11,13,16,17,18,19)
group by 
loc.gl_prefix + ' - ' + loc.loc_name
,loc.gl_prefix + ' - ' + dep.gl_prefix + ' - ' + dep.department_name
,fc.name 
order by
loc.gl_prefix + ' - ' + loc.loc_name
,loc.gl_prefix + ' - ' + dep.gl_prefix + ' - ' + dep.department_name
,fc.name  