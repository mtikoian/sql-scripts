select prov_id, dept.DEPARTMENT_ID, DEPARTMENT_NAME
from clarity_ser_dept dept
left join clarity_dep dep on dept.DEPARTMENT_ID = dep.DEPARTMENT_ID
where prov_id = '3058082'