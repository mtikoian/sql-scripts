select 
case when sa.serv_area_id = 19 then 'KENTUCKY' else sa.serv_area_name end as 'Service Area'
,loc.loc_name as 'Location'
,dep.department_name as 'Department'
,ser.prov_name as 'Performing Provider'
,detail.name as 'Detail Type'
,orig_service_date as 'Service Daet'
,year_month as 'Year Month'
,proc_code as 'Procedure Code'
,proc_name as 'Procedure Name'
,amount as 'Charge Amount'
from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_ser ser on ser.prov_id = tdl.performing_prov_id
left join zc_detail_type detail on detail.detail_type = tdl.detail_type
left join date_dimension date on date.calendar_dt_str = tdl.orig_service_date
where tdl.detail_type in (1,10)
and performing_prov_id = '1608522' 
and orig_service_date >= '9/1/2016'
order by orig_service_date