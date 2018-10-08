select
 
post_date,
sa.serv_area_name as 'Service Area',
department_name as 'Department',
sum (patient_amount) as 'Outstanding Patient Amount'

from clarity_tdl_age arpb_tx
left join clarity_sa sa on sa.serv_area_id = arpb_tx.serv_area_id
left join clarity_dep dep on dep.department_id = arpb_tx.dept_id
where patient_amount <> 0
and sa.serv_area_id in (11,13,16,17,18,19)
and post_date = '9/30/2016'

group by post_date, serv_area_name, department_name
order by serv_area_name, department_name

--select
--post_date,
--serv_area_name as 'Service Area',
--department_name as 'Department',
--sum (patient_amt) as 'Outstanding Patient Amount'

--from arpb_transactions arpb_tx
--left join clarity_sa sa on sa.serv_area_id = arpb_tx.service_area_id
--left join clarity_dep dep on dep.department_id = arpb_tx.department_id
--where patient_amt <> 0
--and service_area_id in (11,13,16,17,18,19)
--and tx_type_c = 1

--group by post_date, serv_area_name, department_name
--order by serv_area_name, department_name

