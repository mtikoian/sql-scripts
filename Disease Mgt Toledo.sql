select

case when sa.serv_area_id = 19 then 'KENTUCKY' else sa.serv_area_name end as serv_area_name
,loc.gl_prefix
,dep.gl_prefix
,dep.department_name
,icd9_code
,current_icd10_list
,dx_name
,sum(amount) amount
,count(tx_id) quantity

from arpb_transactions arpb
left join clarity_dep dep on dep.department_id = arpb.department_id
left join clarity_edg edg on edg.dx_id = arpb.primary_dx_id
left join clarity_loc loc on loc.loc_id = arpb.loc_id
left join clarity_sa sa on sa.serv_area_id = arpb.service_area_id

where post_date >= '2017-01-01'
and post_date <= '2017-02-28'

and tx_type_c = 1
and dep.gl_prefix in  ('422355', '440355', '440360', '471352', '471355', '480000', '495356', '500361', '630358', '630359', '630360', '630361', '630362', '630364', '630366', '790360', '790362', '790363', '790364', '790365', '790366', '790367', '790371', '790377', '790382', '790383', '790388', '790391', '790395', '818362')
and arpb.void_date is null
and loc.gl_prefix <> '6749'

group by 

sa.serv_area_id
,sa.serv_area_name
,loc.gl_prefix
,dep.gl_prefix
,dep.department_name
,icd9_code
,current_icd10_list
,dx_name

order by sa.serv_area_name, count(tx_id) desc
