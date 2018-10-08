select serv_area_name, orig_service_date, detail_type, cpt_code, proc_name
from clarity_tdl_tran tdl
inner join clarity_eap eap on tdl.cpt_code = eap.proc_code
inner join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id
where tdl.serv_area_id = 609
and orig_service_date >= '2014-01-01'
and detail_type = 1
order by orig_service_date