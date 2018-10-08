declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 


select 
case when loc.loc_id in ('131201','131202') then 'SUMMA' end as 'REGION'
,date.year_month as 'Year-Month'
,eap.proc_code as 'Adj Code'
,eap.proc_name as 'Adj Desc'
-->>>>>>>>  Calculation for Admin  <<<<<<<<<<<
,sum(case when tdl.detail_type <= 13 and (eap.gl_num_debit in ('admin') or eap.gl_num_credit in ('admin')) then tdl.amount
		  end)*-1 as 'ADMIN'

from clarity_tdl_tran tdl
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on department_id = tdl.dept_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join zc_orig_fin_class fc on fc.original_fin_class = tdl.original_fin_class
left join date_dimension date on date.calendar_dt = tdl.post_date

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and loc.loc_id in ('131201','131202')
and (eap.gl_num_debit = 'admin' or eap.gl_num_credit = 'admin')

group by
	case when loc.loc_id in ('131201','131202') then 'SUMMA' end
	,date.year_month
	,eap.proc_code
	,eap.proc_name