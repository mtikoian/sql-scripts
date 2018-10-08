declare @start_date as date = EPIC_UTIL.EFN_DIN('t-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('t-1')

select 
sa.serv_area_id as 'Service Area ID'
,sa.serv_area_name as 'Service Area'
,dep.department_id as 'Department ID'
,dep.department_name as 'Department'
,sum(procedure_quantity) as 'Visits'

from clarity_tdl_tran tdl
left join clarity_dep dep on tdl.dept_id= dep.department_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id

where post_date >= @start_date and post_date <= @end_date
and detail_type in (1,10)
and sa.serv_area_id in (11,13,16,17,18,19)

/*Mercy Visits Codes*/

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

group by sa.serv_area_id, sa.serv_area_name, dep.department_id, dep.department_name
