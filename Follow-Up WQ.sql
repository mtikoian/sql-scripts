declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')


select 

fol_info.workqueue_id
,workqueue_name
,sum(amount) as 'Amount'

from clarity_tdl_age age
left join clarity_loc loc on loc.loc_id = age.loc_id
left join clarity_dep dep on dep.department_id = age.dept_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_pos pos on pos.pos_id = age.pos_id
left join clarity_ser ser_bill on ser_bill.prov_id = age.billing_provider_id
left join clarity_ser ser_perf on ser_perf.prov_id = age.performing_prov_id
left join zc_fin_class orig_fc on orig_fc.fin_class_c = age.original_fin_class
left join zc_fin_class cur_fc on cur_fc.fin_class_c = age.cur_fin_class
left join clarity_epm epm_cur on epm_cur.payor_id = age.cur_payor_id
left join clarity_epm epm_orig on epm_orig.payor_id = age.original_payor_id
left join account acct on acct.account_id = age.account_id
left join date_dimension dd on dd.calendar_dt_str = age.post_date
left join clarity_eap eap on eap.proc_id = age.proc_id
left join fol_info on fol_info.transaction_id = age.tx_id
left join fol_wq on fol_wq.workqueue_id = fol_info.workqueue_id

where age.amount <> 0
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and age.post_date >= @start_date
and age.post_date <= @end_date

group by fol_info.workqueue_id
,workqueue_name
