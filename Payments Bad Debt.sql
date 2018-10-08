select * from clarity_tdl_tran where match_proc_id = 7064
and post_date >= '1/1/2017'
and serv_area_id in (11,13,16,17,18,19)
and detail_type = 21

select * from clarity_tdl_tran where tdl_id = 33092619200011

select * from clarity_eap where proc_id = 10226

select * from arpb_tx_void where tx_id = 2681373

select * from pmt_eob_info_i where tx_id =179843792