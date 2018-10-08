--Dr. Simcoe 1000645

select billing_provider_id, prov_name, orig_service_date, pos.pos_id, pos_name, pos_type, eap.procedure_id, procedure_code, procedure_name, billing_category
from clarity_tdl_tran tdl
left join clarity_pos pos on tdl.pos_id = pos.pos_id
left join clarity_ser ser on tdl.billing_provider_id = ser.prov_id
left join v_cube_d_procedure eap on tdl.proc_id = eap.procedure_id
where billing_provider_id = '1000645'
and orig_service_date >= '2015-01-01 00:00:00'
and pos_type = 'office'
and detail_type = 1
and pos.pos_id like '11%'
order by orig_service_date