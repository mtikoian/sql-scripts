declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')


select 

 dd.year as 'Year'
,dd.year_month as 'Year-Month'
,dd.month_name as 'Month'
,upper(sa.name) + ' [' + sa.rpt_grp_ten + ']' as 'Region'
,upper(loc.rpt_grp_three) + ' [' + loc.rpt_grp_two + ']' as 'Location'
,loc.gl_prefix as 'Location GL'
,upper(dep.rpt_grp_two) + ' [' + dep.rpt_grp_one + ']' as 'Department'
,dep.gl_prefix as 'Department GL'
,upper(pos.rpt_grp_two) + ' [' + pos.rpt_grp_one + ']' as 'Place of Service'
,ser_bill.prov_name + ' [' + cast(ser_bill.prov_id as varchar) + ']' as 'Billing Provider'
,ser_perf.prov_name + ' [' + cast(ser_perf.prov_id as varchar) + ']' as 'Service Provider'
,epm_orig.payor_name + ' [' + cast(epm_orig.payor_id as varchar) + ']' as 'Original Payor'
,epm_cur.payor_name + ' [' + cast(epm_cur.payor_id as varchar) + ']' as 'Current Payor'
,orig_fc.name + ' [' + orig_fc.fin_class_c + ']' as 'Original FC'
,cur_fc.name + ' [' + cur_fc.fin_class_c + ']' as 'Current FC'
,eap.proc_name + ' [' + eap.proc_code + ']' as 'Procedure'

,case when age.amount > 0 and detail_type = 60 then 'Debit AR - Positive Debits'
	  when age.amount < 0 and detail_type = 60 then 'Debit AR - Credit Balance'
	  when detail_type = 61 then 'Credit AR'
	  when detail_type in  (60,61) then 'Combined AR'
	  end as 'AR Type'
,case when age.post_date - age.orig_post_date <= 30 then amount else 0 end as '0 - 30'
,case when age.post_date - age.orig_post_date >= 31 and age.post_date - age.orig_post_date <= 60 then amount else 0 end as '31 - 60'
,case when age.post_date - age.orig_post_date >= 61 and age.post_date - age.orig_post_date <= 90 then amount else 0 end as '61 - 90'
,case when age.post_date - age.orig_post_date >= 91 and age.post_date - age.orig_post_date <= 120 then amount else 0 end as '91 - 120'
,case when age.post_date - age.orig_post_date >= 121 and age.post_date - age.orig_post_date <= 180 then amount else 0 end as '121 - 180'
,case when age.post_date - age.orig_post_date >= 181 and age.post_date - age.orig_post_date <= 270 then amount else 0 end as '181 - 270'
,case when age.post_date - age.orig_post_date >= 271 and age.post_date - age.orig_post_date <= 365 then amount else 0 end as '271 - 365'
,case when age.post_date - age.orig_post_date > 365 then amount else 0 end as '+ 365'
,acct.account_name as 'Account'
,age.amount as 'Amount'

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

where age.amount <> 0
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and age.post_date >= @start_date
and age.post_date <= @end_date
