select top 5 int_pat_id, pat.pat_id, pat_name, orig_service_date, billing_provider_id, performing_prov_id, sa.serv_area_id, sa.serv_area_name, pos.pos_id, pos_name, cpt_code, proc_name, charge_slip_number
from clarity_tdl_tran tdl
left join clarity_eap eap on tdl.proc_id = eap.proc_id
left join clarity_pos pos on tdl.pos_id = pos.pos_id
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id
left join patient pat on tdl.int_pat_id = pat.pat_id
where orig_service_date >= '2015-05-01'
and orig_service_date <= '2015-05-31'
and int_pat_id like 'm%'
and detail_type = 1
and cpt_code = '99203'
and sa.serv_area_id <> '21'
and tx_id in (83034458, 82615279, 83284892, 82414026)
order by int_pat_id, orig_service_date