--charges from march 11 - 31
--Mercy only
-- entity code, cost center, billing provider, department name, amount

select 
 loc.gl_prefix as entity_code
,loc.loc_id as location_id
,loc.loc_name as location_name
,dep.gl_prefix as cost_center
,dep.department_name as department
,ser.prov_name as billing_provider
,eap.proc_code
,eap.proc_name
,tdl.tx_id as etr
,tdl.detail_type
,tdl.amount
from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id 
where post_date >= '3/11/2017'
and post_date <= '3/31/2017'
and detail_type = 3
and tdl.serv_area_id in (19)
and amount <> 0
and loc.gl_prefix is not null
