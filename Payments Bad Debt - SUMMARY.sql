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
,tdl.CUR_PAYOR_ID
,tdl.CUR_PLAN_ID
,tdl.CUR_FIN_CLASS
,tdl.loc_id
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
)


select 

 date.YEAR_MONTH as 'YEAR-MONTH'
,sa.name as 'REGION'
,epm.PAYOR_NAME as 'PAYOR'
,epp.BENEFIT_PLAN_NAME 'PLAN'
,fc.name as 'FINANCIAL CLASS'
,sum(eob.CVD_AMT) as 'ALLOWED'
,sum(eob.NONCVD_AMT) as 'NON-ALLOWED'
,sum(eob.DED_AMT) as 'DEDUCTIBLE'
,sum(eob.COPAY_AMT) as 'COPAY'
,sum(eob.COINS_AMT) as 'COINS'
,sum(eob.PAID_AMT) as 'PAID'


from payment
left join eob on eob.tdl_id = payment.tdl_id
left join clarity_epm epm on epm.payor_id = payment.cur_payor_id
left join clarity_epp epp on epp.BENEFIT_PLAN_ID = payment.CUR_PLAN_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = payment.POST_DATE
left join CLARITY_LOC loc on loc.LOC_ID = payment.LOC_ID
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.RPT_GRP_TEN
left join ZC_FIN_CLASS fc on fc.FIN_CLASS_C = payment.CUR_FIN_CLASS

group by 

 date.YEAR_MONTH
,sa.name
,epm.PAYOR_NAME
,epp.BENEFIT_PLAN_NAME
,fc.name

order by 
 date.YEAR_MONTH
,sa.name
,epm.PAYOR_NAME
,epp.BENEFIT_PLAN_NAME
,fc.name