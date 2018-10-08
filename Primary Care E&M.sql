declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
 year as 'Year'
,year_month as 'Year-Month'
,case when sa.name in ('11106','11124') then 'SPRINGFIELD'
	   else upper(sa.name) end as 'Service Area'
,ser.prov_id as 'Billing Provider ID'
,ser.prov_name as 'Billing Provider'
,eap.proc_code as 'Charge Code'
,eap.proc_name as 'Charge Description'
,dep.SPECIALTY as 'Department Specialty'

,isnull(sum(coalesce(procedure_quantity,0)),0) as 'Units'

from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join date_dimension date on date.calendar_dt_str = tdl.post_date

where proc_code between '99201' and '99215'
and detail_type in (1,10)
and post_date >= @start_date
and post_date <= @end_date
and sa.rpt_grp_ten in (11,13,16,17,18,19)
and dep.specialty in ('Family Medicine','General Internal Medicine','Pediatrics','Primary Care','Internal Medicine')
and tdl.billing_provider_id is not null
and tdl.billing_provider_id not in ('1740570') -- AKIZIMANA, CHERIYA 
--and ser.prov_id = '1620859'

group by ser.prov_id, ser.prov_name, year, year_month, sa.name, eap.proc_code, eap.proc_name, dep.specialty
order by ser.prov_id, ser.prov_name, year, year_month, sa.name, eap.proc_code, eap.proc_name, dep.specialty