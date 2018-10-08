select ser.PROV_ID, ser.PROV_NAME, dep.DEPARTMENT_ID, dep.DEPARTMENT_NAME, REV_LOC_ID, loc.SERV_AREA_ID, ACTIVE_STATUS
from clarity_ser ser
inner join clarity_ser_dept sd on ser.prov_id = sd.prov_id
inner join clarity_dep dep on sd.department_id = dep.department_id
inner join clarity_loc loc on loc.LOC_ID = dep.REV_LOC_ID
where loc.SERV_AREA_ID = '13' --Youngstown
order by ser.prov_id