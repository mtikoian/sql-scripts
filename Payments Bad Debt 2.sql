with payment as
(
select 
*
from
(
select
 tdl.tdl_id
,tdl.tx_id
,tdl.match_trx_id
,tdl.post_date
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
from clarity_tdl_tran tdl
where tdl.match_proc_id = '7080' -- 2000 Insurance Payment
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.detail_type = 20 -- matched charge > payment
)main
where main.row# = 1
and main.post_date between '10/1/2016' and '9/30/2017'
),

eob as
(
select
 eob.tdl_id
,eob.line
,eob.cvd_amt
,eob.noncvd_amt
,eob.ded_amt
,eob.copay_amt
,eob.coins_amt
,eob.paid_amt
from payment
left join pmt_eob_info_i eob on eob.tdl_id = payment.tdl_id
--where eob.line = 1
),

write_offs as
(
select
*
from
(
select  
 tdl.tdl_id
,tdl.tx_id
,tdl.match_trx_id
,tdl.match_proc_id
,tdl.post_date
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
from payment
left join clarity_tdl_tran tdl on tdl.tx_id = payment.tx_id
where tdl.match_proc_id = 7064 -- 5002 Collections Bad Debt Write off
and tdl.detail_type = 21
)w2
where w2.row# = 1
)


select * 
from payment
left join eob on eob.tdl_id = payment.tdl_id
left join write_offs on write_offs.tx_id = payment.tx_id
order by 
 payment.tdl_id
,payment.tx_id
,payment.post_date