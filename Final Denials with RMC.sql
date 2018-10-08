

select 
top 100 tdl.tx_id, tdl.post_date, eap_match.proc_code, eap_match.proc_name, a.name, tdl.amount
from 
clarity_tdl_tran tdl
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
inner join (
SELECT
tx_id, post_date, rmc_code.name
from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
where rmc.code_cat_c in (4,5)

)a on a.tx_id = tdl.tx_id
where 
tdl.post_date >= '4/1/2017'
and tdl.post_date <= '4/30/2017'
and eap_match.proc_code in ('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036')
order by tdl.tx_id



