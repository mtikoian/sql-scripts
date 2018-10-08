select distinct c.department_id, department_name
from clarity_ser a
inner join clarity_ser_dept b on a.prov_id = b.prov_id
inner join clarity_dep c on b.department_id = c.department_id
where department_name like '%oregon%'