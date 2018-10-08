declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
 date.year_month as 'Month of Transaction'
,cast(tdl.post_date as date) as 'Payment Date'
,upper(sa.name) as 'Region'
,dep.department_name as 'Department'
,loc.gl_prefix + '-' + dep.gl_prefix as 'Cost Center'
,ser.prov_id as 'Performing Provider ID'
,ser.prov_name as 'Performing Provider'
,tdl.tx_id as 'Charge ETR'
,eob.tx_id as 'Payment ETR'
,eob.paid_amt as 'Paid Amt'
,tdl.orig_amt as 'Charge Amt'
,tdl_adj.amount as 'Write Off Amt'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Name'
,WINNINGRMC_ID as 'Remit Code'
,rmc.remit_code_name as 'Remit Code Name'
,code.name as 'Remit Category'
from pmt_eob_info_i eob
left join pmt_eob_info_ii eob2 on eob2.tx_id = eob.tx_id and eob2.EOB_I_LINE_NUMBER = eob.line
inner join clarity_tdl_tran tdl on tdl.tdl_id = eob.tdl_id
left join clarity_tdl_tran tdl_adj on tdl_adj.tx_id = tdl.tx_id and tdl_adj.detail_type = 21
left join clarity_eap eap on eap.proc_id = tdl_adj.match_proc_id
left join clarity_rmc rmc on remit_code_id = eob2.winningrmc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_ser ser on ser.prov_id = tdl.performing_prov_id
left join date_dimension date on date.calendar_dt = tdl.post_date
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join zc_rmc_code_cat code on code.rmc_code_cat_c = rmc.code_cat_c
where eob2.actions = 9 -- Denied
and eap.proc_code in 
('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036')
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.post_date >= @start_date
and tdl.post_date <= @end_date

order by tdl.post_date, tdl.tx_id