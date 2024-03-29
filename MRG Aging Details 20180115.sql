/*
EAR 603 – Account Status multiple responses
EPT 112 – Patient Living Status - not in Clarity
ETR 46 – Patient Aging Date
*/


declare @post_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 

 dd.year as 'Year'
,dd.year_month as 'Year-Month'
,case when loc.loc_id = 18110 then 'TOLEDO - MRG' else 'UKNOWN ' end as 'Region'
,loc.loc_id as 'Location ID'
,loc.loc_name as 'Location Name'
,loc.gl_prefix as 'Location GL'
,dep.department_id as 'Department ID'
,dep.department_name as 'Department Name'
,dep.gl_prefix as 'Department GL'
,pos.pos_id as 'POS ID'
,pos.pos_name as 'POS Name'
,age.pat_id as 'Patient ID'
,pat.pat_name as 'Patient Name'
,age.account_id as 'Account ID'
,acct.account_name as 'Account Name'
,case when ser_bill.prov_name is null then 'UNKNOWN BILLING PROVIDER'
	else ser_bill.prov_name + ' [' + cast(ser_bill.prov_id as varchar) + ']' end as 'Billing Provider'
,case when ser_perf.prov_name is null then 'UNKNOWN SERVICE PROVIDER' 
	else ser_perf.prov_name + ' [' + cast(ser_perf.prov_id as varchar) + ']' end as 'Service Provider'
,epm_orig.payor_name + ' [' + cast(epm_orig.payor_id as varchar) + ']' as 'Original Payor'
,epm_cur.payor_name + ' [' + cast(epm_cur.payor_id as varchar) + ']' as 'Current Payor'
,orig_fc.name + ' [' + orig_fc.fin_class_c + ']' as 'Original FC'
,orig_fc.name as 'Original Financial Class'
,cur_fc.name + ' [' + cur_fc.fin_class_c + ']' as 'Current FC'
,eap.proc_name + ' [' + eap.proc_code + ']' as 'Procedure'
,age.orig_amt as 'Charge Amt'
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
,age.amount as 'Amount'
,zcr.name as 'Contest Reason'
--,zas.name as 'Account Status'
,zat.name as 'Account Type'
,cast(acct.last_pat_pmt_date as date) as 'Last Patient Payment Date' 
,acct.last_pat_pmt_amt as 'Last Patient Payment Amt'
,acct.pmt_plan_amount as 'Payment Plan Amt'
,acct.pmt_plan_freq as 'Payment Plan Freq'
,cast(pmt_plan_strt_date as date) as 'Payment Plan Start Date'
,cast(atm.pat_aging_date as date) as 'Patient Aging Date'

from clarity.dbo.clarity_tdl_age age
left join clarity.dbo.clarity_loc loc on loc.loc_id = age.loc_id
left join clarity.dbo.clarity_dep dep on dep.department_id = age.dept_id
left join clarity.dbo.clarity_pos pos on pos.pos_id = age.pos_id
left join clarity.dbo.clarity_ser ser_bill on ser_bill.prov_id = age.billing_provider_id
left join clarity.dbo.clarity_ser ser_perf on ser_perf.prov_id = age.performing_prov_id
left join clarity.dbo.zc_fin_class orig_fc on orig_fc.fin_class_c = age.original_fin_class
left join clarity.dbo.zc_fin_class cur_fc on cur_fc.fin_class_c = age.cur_fin_class
left join clarity.dbo.clarity_epm epm_cur on epm_cur.payor_id = age.cur_payor_id
left join clarity.dbo.clarity_epm epm_orig on epm_orig.payor_id = age.original_payor_id
left join clarity.dbo.account acct on acct.account_id = age.account_id
left join clarity.dbo.date_dimension dd on dd.calendar_dt_str = age.post_date
left join clarity.dbo.clarity_eap eap on eap.proc_id = age.proc_id
left join clarity.dbo.patient pat on pat.pat_id = age.int_pat_id
left join clarity.dbo.arpb_tx_moderate atm on atm.tx_id = age.tx_id
left join clarity.dbo.zc_contest_reason zcr on zcr.contest_reason_c = atm.contest_reason_c
--left join clarity.dbo.account_status stat on stat.account_id = acct.account_id
--left join clarity.dbo.zc_account_status zas on zas.account_status_c = stat.account_status_c
left join clarity.dbo.zc_account_type zat on zat.account_type_c = acct.account_type_c


where loc.loc_id = 18110
and post_date = @post_date




