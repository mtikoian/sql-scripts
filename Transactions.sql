select tx_id, performing_prov_id, clarity_tdl_tran.int_pat_id, pat.pat_id, pat_name, orig_post_date
from clarity_tdl_tran
inner join patient pat on clarity_tdl_tran.int_pat_id = pat.pat_id
where tx_id = 70779800


