declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2017')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
a.billing_provider_id as 'Billing Provider ID'
, a.prov_name as 'Billing Provider'
, a.proc_code as 'Charge Code'
, a.proc_name as 'Charge Description'
, a.serv_area_name as 'Service Area'
, a.year_month as 'Year-Month'
, a.specialty as 'Department Specialty'
,@start_date as 'Start Date'
,@end_date as 'End Date'
, sum(coalesce(units,0)) as 'Units'

from

(
select distinct billing_provider_id, ser.prov_name, proc_code, proc_name, sa.serv_area_name, loc.rpt_grp_two, year_month, dep.specialty
from clarity_tdl_tran tdl
cross join clarity_eap eap
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id

where proc_code between '99201' and '99215'
and detail_type in (1,10)
and post_date >= @start_date
and post_date <= @end_date
and tdl.serv_area_id = 1312
--and ser.prov_id = '1000001'
--and dep.specialty in ('Family Medicine','General Internal Medicine','Pediatrics','Primary Care','Internal Medicine')
and tdl.billing_provider_id is not null
--and tdl.billing_provider_id not in ('1740570') -- AKIZIMANA, CHERIYA 

)a

left join 

(
select billing_provider_id, ser.prov_name, proc_code, proc_name, loc.rpt_grp_two, year_month, dep.specialty, procedure_quantity as units
from clarity_tdl_tran tdl
left join  clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id

where proc_code between '99201' and '99215'
and detail_type in (1,10)
and post_date >= @start_date
and post_date <= @end_date
and tdl.serv_area_id = 1312
--and ser.prov_id = '1000001'
--and dep.specialty in ('Family Medicine','General Internal Medicine','Pediatrics','Primary Care','Internal Medicine')
--and tdl.billing_provider_id not in ('1740570') -- AKIZIMANA, CHERIYA 
)b

on a.billing_provider_id = b.billing_provider_id and a.proc_code = b.proc_code and a.year_month = b.year_month and a.rpt_grp_two = b.rpt_grp_two and a.specialty = b.specialty



group by a.billing_provider_id, a.prov_name, a.proc_code, a.proc_name, a.serv_area_name, a.rpt_grp_two, a.year_month, a.specialty
order by a.billing_provider_id, a.proc_code, a.year_month