
-- Select first insurance payment on the charge

select
*
from 
(
select 
 tdl.tdl_id
,tdl.tx_id
,tdl.post_date
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.match_proc_id
where eap.proc_code = '2000'
and tdl.detail_type = 20 -- charge matched to payment
and serv_area_id in (11,13,16,17,18,19)
)payments
where row# = 1
and post_date >= '10/1/2016'
and post_date <= '9/30/2017'