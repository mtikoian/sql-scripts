declare @start_date as date = EPIC_UTIL.EFN_DIN('8/28/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('3/31/2018')

select 
 dd.year_month_str as 'Year-Month'
,ser_perf.prov_name as 'Performing Provider'
,sum(case when age.post_date - age.orig_post_date <= 30 then amount else 0 end) as '0 - 30'
,sum(case when age.post_date - age.orig_post_date >= 31 and age.post_date - age.orig_post_date <= 60 then amount else 0 end) as '31 - 60'
,sum(case when age.post_date - age.orig_post_date >= 61 and age.post_date - age.orig_post_date <= 90 then amount else 0 end) as '61 - 90'
,sum(case when age.post_date - age.orig_post_date >= 91 and age.post_date - age.orig_post_date <= 120 then amount else 0 end) as '91 - 120'
,sum(case when age.post_date - age.orig_post_date >= 121 and age.post_date - age.orig_post_date <= 180 then amount else 0 end) as '121 - 180'
,sum(case when age.post_date - age.orig_post_date >= 181 and age.post_date - age.orig_post_date <= 270 then amount else 0 end) as '181 - 270'
,sum(case when age.post_date - age.orig_post_date >= 271 and age.post_date - age.orig_post_date <= 365 then amount else 0 end) as '271 - 365'
,sum(case when age.post_date - age.orig_post_date > 365 then amount else 0 end) as '+ 365'
,sum(age.amount) as 'Amount'

from clarity.dbo.clarity_tdl_age age
left join clarity.dbo.clarity_loc loc on loc.loc_id = age.loc_id
left join clarity.dbo.clarity_dep dep on dep.department_id = age.dept_id
left join clarity.dbo.zc_loc_rpt_grp_10 loc_grp on loc_grp.rpt_grp_ten = loc.rpt_grp_ten
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
left join clarity.dbo.clarity_sa sa on sa.serv_area_id = loc.rpt_grp_ten

where age.post_date >= @start_date
and age.post_date <= @end_date
and ser_perf.prov_id in (
 '1645149'
,'12010121'
,'1751371'
,'1680887'
,'1003204'
,'1659977'
,'1658363'
,'1004208'
,'1000404'
,'1644197'
,'1005545'
,'1005698'
,'1010615'
,'1713892'
,'1006356'
,'1006705'
,'1644006'
,'1007279'
,'1007660'
,'1602936'
,'1008490'
,'1658545'
,'1008788'
,'1639044'
,'1000690'
,'1009641'
,'1675085'
,'1740710'
,'1000734'
,'1010044'
)

group by 
 ser_perf.prov_name
,dd.year_month_str


order by 
 ser_perf.prov_name
,dd.year_month_str





