select orig_service_date, orig_post_date, post_date, tx_id, rvu_work, rvu_overhead, rvu_malpractice
from clarity_tdl_tran
where serv_area_id = 18
and post_date >= '2016-01-01'
and cpt_code = '66984'
and modifier_one = '55'