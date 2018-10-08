select 

sa.serv_area_name + ' [' + cast(sa.serv_area_id as varchar) + ']' as 'Service Area' 
,loc.loc_name + ' [' + cast(loc.GL_PREFIX as varchar) + ']' as Location
,dep.DEPARTMENT_NAME + ' [' + cast(dep.GL_PREFIX as varchar) + ']' as Department


,post_date 
,sum(procedure_quantity) as visits

from clarity_tdl_tran tdl
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id
left join clarity_loc loc on tdl.loc_id = loc.loc_id
left join clarity_dep dep on tdl.DEPT_ID = dep.DEPARTMENT_ID

where post_date >= '2015-01-01' and post_date < '2016-01-01'
and sa.serv_area_id in (11,13,16,17,18,19,21)
and detail_type in (1,10)

and (cpt_code between '96150' and '96154'
or cpt_code between '90800' and '90884'
or cpt_code between '90886' and '90899'
or cpt_code between '99024' and '99079'
or cpt_code between '99071' and '96154'
or cpt_code between '99081' and '99144'
or cpt_code between '99146' and '99149'
or cpt_code between '99151' and '99172'
or cpt_code between '99174' and '99291'
or cpt_code between '99293' and '99359'
or cpt_code between '99375' and '99480'
or cpt_code = '90791'
or cpt_code = '90792'
or cpt_code = '99495'
or cpt_code = '99496'
or cpt_code = '99361'
or cpt_code = '99373'
or cpt_code = 'G0402'
or cpt_code = 'G0406'
or cpt_code = 'G0407'
or cpt_code = 'G0408'
or cpt_code = 'G0409'
or cpt_code = 'G0438'
or cpt_code = 'G0439'
)

group by sa.serv_area_name, sa.serv_area_id, loc.loc_name, loc.gl_prefix, dep.department_name, dep.gl_prefix, tdl.post_date
order by sa.serv_area_name, loc.loc_name, department_name, tdl.post_date

