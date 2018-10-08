with payment as
(select
 tdl.tdl_id
,tdl.tx_id
,tdl.orig_service_date
,tdl.orig_post_date
,tdl.post_date
,tdl.loc_id
,tdl.dept_id
,tdl.account_id
,tdl.proc_id
,tdl.match_proc_id
,tdl.match_trx_id
,tdl.cur_payor_id
,tdl.cur_plan_id
,tdl.cur_fin_class
,tdl.orig_amt
,tdl.amount
 from clarity_tdl_tran tdl
 where detail_type = 20 -- charge matched to a payment
 --and tdl.match_proc_id = 7080 -- insurance payment
 and post_date >= '1/1/2017'
 and post_date <= '12/31/2017'
 and tdl.serv_area_id in (11,13,16,17,18,19)
 and tdl.amount <> 0 -- remove $0 payments
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
)

select 
 upper(sa.name) as 'REGION'
 ,date.year_month as 'PYMNT MONTH'
--,loc.loc_name as 'LOCATION'
--,dep.department_name as 'DEPARTMENT'
--,dep.specialty as 'SPECIALTY'
--,payment.account_id as 'ACCOUNT ID'
--,payment.tx_id as 'CHG ID'
--,cast(payment.orig_service_date as date) as 'SERVICE DATE'
--,cast(payment.orig_post_date as date) as 'CHG POST DATE'
,eap_chg.proc_code as 'CHG PROC CODE'
,eap_chg.proc_name as 'CHG PROC DESC'
--,coalesce(cast(payment.match_trx_id as nvarchar),'') as 'PYMNT ID'
--,coalesce(cast(payment.post_date as date),'') as 'PYMNT POST DATE'
,coalesce(eap_pymnt.proc_code,'') as 'PYMNT PROC CODE'
,coalesce(eap_pymnt.proc_name,'') as 'PYMNT PROC DESC'
,coalesce(epm.payor_name,'') as 'TRANS PAYOR'
,epp.benefit_plan_name as 'BENEFIT PLAN'
,fc.name as 'Financial Class'
,case when payment.cur_payor_id is null then 'SELF-PAY' else 'INSURANCE' end as 'COVERAGE'
,sum(payment.orig_amt) as 'CHG AMT'
,sum(coalesce(payment.amount,0))*-1 as 'PYMNT AMT'
,sum(coalesce(eob.cvd_amt,0)) as 'CVD AMT'
,sum(coalesce(eob.noncvd_amt,0)) as 'NONCVD AMT'
,sum(coalesce(eob.ded_amt,0)) as 'DED AMT'
,sum(coalesce(eob.copay_amt,0)) as 'COPAY AMT'
,sum(coalesce(eob.coins_amt,0)) as 'COINS AMT'
,sum(coalesce(eob.paid_amt,0)) as 'PAID AMT'



from payment
left join eob on eob.tdl_id = payment.tdl_id
left join clarity_eap eap_chg on eap_chg.proc_id = payment.proc_id
left join clarity_eap eap_pymnt on eap_pymnt.proc_id = payment.match_proc_id
left join clarity_epm epm on epm.payor_id = payment.cur_payor_id
left join clarity_loc loc on loc.loc_id = payment.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = payment.dept_id
left join zc_dep_rpt_grp_16 dep16 on dep16.rpt_grp_sixteen_c = dep.rpt_grp_sixteen_c
left join date_dimension date on date.calendar_dt = payment.post_date
left join clarity_epp epp on epp.benefit_plan_id = payment.cur_plan_id
left join arpb_tx_void void on void.tx_id = payment.tx_id
left join ZC_FIN_CLASS fc on fc.fin_class_c = payment.cur_fin_class

where void.tx_id is null


group by 
 sa.name
 ,date.year_month
,eap_chg.proc_code
,eap_chg.proc_name
,coalesce(eap_pymnt.proc_code,'')
,coalesce(eap_pymnt.proc_name,'')
,coalesce(epm.payor_name,'')
,epp.benefit_plan_name
,fc.name
,case when payment.cur_payor_id is null then 'SELF-PAY' else 'INSURANCE' end


order by 
 sa.name
 ,date.year_month
,eap_chg.proc_code
,eap_chg.proc_name
,coalesce(eap_pymnt.proc_code,'')
,coalesce(eap_pymnt.proc_name,'')
,coalesce(epm.payor_name,'')
,epp.benefit_plan_name
,fc.name
,case when payment.cur_payor_id is null then 'SELF-PAY' else 'INSURANCE' end