declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

SELECT

 date.year_month as 'Year-Month'
,date.month_name as 'Month'
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'Coding' then tdl.action_amount end) as 'Coding'
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'Bundled' then tdl.action_amount end) as 'Bundled'


from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join date_dimension date on date.calendar_dt_str = tdl.post_date

where loc.rpt_grp_ten in (11,13,16,17,18,19)
and tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and rmc.code_cat_c in (4,5)

group by
date.year_month
,date.month_name


order by
date.year_month
,date.month_name
