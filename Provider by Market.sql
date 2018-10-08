select

clarity_ser.prov_id,
clarity_ser.prov_name,
clarity_ser_dept.department_id,
clarity_sa.serv_area_name as 'market'

from

clarity_ser
left join clarity_ser_dept on clarity_ser.prov_id = clarity_ser_dept.prov_id
left join clarity_dep on clarity_ser_dept.department_id = clarity_dep.department_id
left join clarity_sa on clarity_dep.serv_area_id = clarity_sa.serv_area_id

where 

clarity_dep.department_id is not null

order by clarity_ser.prov_id