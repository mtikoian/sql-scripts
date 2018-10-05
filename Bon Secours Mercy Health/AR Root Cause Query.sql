
declare @start_date as date = EPIC_UTIL.EFN_DIN('6/4/2018')
declare @end_date as date = EPIC_UTIL.EFN_DIN('6/4/2018');

with charge as
(select * 
from
(
select
 serv_area_id
,loc_id
,dept_id
,pos_id
,tx_id
,account_id
,orig_service_date
,orig_post_date
,orig_amt
,proc_id
,match_trx_id
,post_date
,match_proc_id
,tdl_id
,patient_amount
,amount * - 1 as amount
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
 from clarity_tdl_tran tdl
 where 
 --tx_id = 122724180 
 --tx_id = 8105312
 --tx_id = 111343521
 --tx_id = 115077677
 --tx_id = 106963235
 --tx_id = 132602520
 --tx_id = 138989710
 --tx_id = 7403001
 --tx_id = 108774395 
 detail_type in (1,11)
 --and match_proc_id = 7064
 and tdl.serv_area_id in (11,13,16,17,18,19)
 and tdl.patient_amount > 0
group by
 tdl_id
,serv_area_id
,loc_id
,dept_id
,pos_id
,tx_id
,account_id
,orig_service_date
,orig_post_date
,orig_amt
,proc_id
,match_trx_id
,post_date
,match_proc_id
,patient_amount
,amount
)a
where row# = 1
--and post_date >= @start_date
--and post_date <= @end_date

),

payment as
(
select *
from 
(select
 tdl.tdl_id
,tdl.tx_id
,tdl.post_date
,tdl.match_proc_id
,tdl.match_trx_id
,tdl.cur_payor_id
,tdl.cur_plan_id
,tdl.amount


,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
 from charge
 left join clarity_tdl_tran tdl on tdl.tx_id = charge.tx_id
 where detail_type = 20
 and tdl.match_proc_id = 7080 -- insurance payment
 group by 
 tdl.tdl_id
,tdl.tx_id
,tdl.post_date
,tdl.match_proc_id
,tdl.match_trx_id
,tdl.cur_payor_id
,tdl.cur_plan_id
,tdl.amount
 )a
 where row# =1 
and post_date >= @start_date
and post_date <= @end_date
 ),

payment2 as
(
select *
from 
(select
 tdl.tdl_id
,tdl.tx_id
,tdl.post_date
,tdl.match_proc_id
,tdl.match_trx_id
,tdl.cur_payor_id
,tdl.cur_plan_id
,tdl.amount


,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
 from charge
 left join clarity_tdl_tran tdl on tdl.tx_id = charge.tx_id
 where detail_type in (20)--,21,22,23)
 and tdl.match_proc_id in (7084, 7108) -- patient payment
 group by 
 tdl.tdl_id
,tdl.tx_id
,tdl.post_date
,tdl.match_proc_id
,tdl.match_trx_id
,tdl.cur_payor_id
,tdl.cur_plan_id
,tdl.amount
 )a
 where row# =1 
 ),



 eob as
 (
 select 
 eob.tdl_id
,eob.tx_id
,line
,cvd_amt
,noncvd_amt
,ded_amt
,coins_amt
,copay_amt
,paid_amt
from payment
left join pmt_eob_info_i eob on eob.tdl_id = payment.tdl_id
),

eob2 as 
(select * 
from
(
select
 eob2.tx_id
,eob2.line
,eob2.eob_i_line_number
,eob2.actions
,eob2.winningrmc_id
,ROW_NUMBER() OVER(PARTITION BY eob.tx_id ORDER BY eob2.line asc) as Row#
from eob
left join pmt_eob_info_ii eob2 on eob2.tx_id = eob.tx_id and eob2.eob_i_line_number = eob.line
where actions = 9
)a
where row#=1
)

select 
 upper(sa.name) as 'REGION'
,loc.loc_name as 'LOCATION'
,dep.department_name as 'DEPARTMENT'
,dep.specialty as 'SPECIALTY'
--,dep16.name as 'SERVICE LINE'
,pos.pos_name as 'POS'
,pos.pos_type as 'POS TYPE'
,charge.account_id as 'ACCOUNT ID'
,charge.tx_id as 'CHG ID'
,charge.tdl_id
,cast(charge.orig_service_date as date) as 'SERVICE DATE'
,cast(charge.orig_post_date as date) as 'CHG POST DATE'
,eap_chg.proc_code as 'CHG PROC CODE'
,eap_chg.proc_name as 'CHG PROC DESC'
,charge.orig_amt as 'CHG AMT'
,charge.match_trx_id as 'ADJ ID'
,date.year_month as 'ADJ MONTH'
,cast(charge.post_date as date) as 'ADJ POST DATE'
,eap_adj.proc_code as 'ADJ PROC CODE'
,eap_adj.proc_name as 'ADJ PROC DESC'
,charge.amount as 'ADJ AMT'
,payment.tdl_id as 'PYMNT TDL ID'
,coalesce(cast(payment.match_trx_id as nvarchar),'') as 'PYMNT ID'
,coalesce(cast(payment.post_date as date),'') as 'PYMNT POST DATE'
,coalesce(eap_pymnt.proc_code,'') as 'PYMNT PROC CODE'
,coalesce(eap_pymnt.proc_name,'') as 'PYMNT PROC DESC'
,coalesce(epm.payor_name,'') as 'TRANS PAYOR'
,coalesce(cast(payment.amount as nvarchar),'') as 'PYMNT AMT'
--,eob.tdl_id as 'EOB TDL ID'
--,eob.line as 'EOB LINE'
,coalesce(cast(eob.cvd_amt as nvarchar),'') as 'CVD AMT'
,coalesce(cast(eob.noncvd_amt as nvarchar),'') as 'NONCVD AMT'
,case when eob.ded_amt is not null and eob.ded_amt > (-(charge.amount)) then coalesce(cast(charge.amount as nvarchar),'') else coalesce(cast(eob.ded_amt as nvarchar),'')  end as 'DED AMT'
,case when cast(eob.ded_amt as nvarchar) is not null then ''
	  when eob.ded_amt is null and eob.copay_amt is not null and eob.copay_amt > (-(charge.amount)) then coalesce(cast(charge.amount as nvarchar),'')  else coalesce(cast(eob.copay_amt as nvarchar),'')  end as 'COPAY AMT'
,case when cast(eob.ded_amt as nvarchar) is not null then ''
      when cast(eob.copay_amt as nvarchar) is not null then ''
	  when eob.copay_amt is not null and eob.coins_amt > (-(charge.amount)) then coalesce(cast(charge.amount as nvarchar),'')  else coalesce(cast(eob.coins_amt as nvarchar),'')  end as 'COINS AMT'
,coalesce(cast(eob.paid_amt as nvarchar),'') as 'PAID AMT'
--,eob2.line as 'EOB2 LINE'
,coalesce(charge.patient_amount,' ') as 'PATIENT AMT'
--,coalesce(payment2.amount,' ') as 'PATIENT PYMT'
--,coalesce(charge.patient_amount + payment.amount,' ') 'Open AR'
,coalesce(eob2.actions,'') as 'REMIT ACTION'
,coalesce(eob2.winningrmc_id,'') as 'REMIT CODE'
,coalesce(rmc.remit_code_name,'') as 'REMIT DESC'
,coalesce(cat.name,'') as 'REMIT CATEGORY'
,case when payment.cur_payor_id is null then 'SELF-PAY' else 'INSURANCE' end as 'COVERAGE'
,epp.benefit_plan_name as 'BENEFIT PLAN'

from charge
left join payment on payment.tx_id = charge.tx_id
left join payment2 on payment2.tx_id = charge.tx_id
left join eob on eob.tdl_id = payment.tdl_id
left join eob2 on eob2.tx_id = payment.match_trx_id and eob2.eob_i_line_number = eob.line
left join clarity_eap eap_chg on eap_chg.proc_id = charge.proc_id
left join clarity_eap eap_adj on eap_adj.proc_id = charge.match_proc_id
left join clarity_eap eap_pymnt on eap_pymnt.proc_id = payment.match_proc_id
left join clarity_epm epm on epm.payor_id = payment.cur_payor_id
left join clarity_rmc rmc on rmc.remit_code_id = eob2.winningrmc_id
left join zc_rmc_code_cat cat on cat.rmc_code_cat_c = rmc.code_cat_c
left join clarity_loc loc on loc.loc_id = charge.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = charge.dept_id
left join zc_dep_rpt_grp_16 dep16 on dep16.rpt_grp_sixteen_c = dep.rpt_grp_sixteen_c
left join clarity_pos pos on pos.pos_id = charge.pos_id
left join date_dimension date on date.calendar_dt = charge.post_date
left join arpb_tx_void void on void.tx_id = charge.tx_id
left join clarity_epp epp on epp.benefit_plan_id = payment.cur_plan_id

where void.tx_id is null
and sa.name = 'Youngstown'



order by charge.tx_id asc