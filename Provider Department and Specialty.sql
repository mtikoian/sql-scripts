select
 ser.prov_id
,prov_name
,prov_type
,ser_spec.line
,spec.name
,active_status
,dep.department_id
,dep.department_name
,dep.serv_area_id
from clarity_ser ser
left join clarity_ser_spec ser_spec on ser_spec.prov_id = ser.prov_id
left join zc_specialty spec on spec.specialty_c = ser_spec.specialty_c
left join clarity_ser_dept ser_dept on ser_dept.prov_id = ser.prov_id
left join clarity_dep dep on dep.department_id = ser_dept.department_id
where active_status = 'active'
and prov_type = 'physician'

order by prov_id, line