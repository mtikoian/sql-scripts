declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 
 tdl.SERV_AREA_ID
,tx_id

-->>>>>>>>  Calculation for 1st Denial - Duplicate <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'DUPLICATE' then tdl.action_amount end) as '1st DENIAL - DUPLICATE'

-->>>>>>>>  Calculation for 1st Denial - Eligibility/Registration <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'ELIGIBILITY/REGISTRATION' then tdl.action_amount end) as '1st DENIAL - ELIGIBILITY/REGISTRATION'

-->>>>>>>>  Calculation for 1st Denial - Authorization <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'AUTHORIZATION' then tdl.action_amount end) as '1st DENIAL - AUTHORIZATION'

-->>>>>>>>  Calculation for 1st Denial - Enrollment <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'ENROLLMENT' then tdl.action_amount end) as '1st DENIAL - ENROLLMENT'

-->>>>>>>>  Calculation for 1st Denial - NonCovered <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'NON-COVERED' then tdl.action_amount end) as '1st DENIAL - NON COVERED'

-->>>>>>>>  Calculation for 1st Denial - Past Timely Filing <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'PAST TIMELY FILING' then tdl.action_amount end) as '1st DENIAL - PAST TIMELY FILING'

-->>>>>>>>  Calculation for 1st Denial - Additional Documentation <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'ADDITIONAL DOCUMENTATION NEEDED' then tdl.action_amount end) as '1st DENIAL - ADDITIONAL DOCUMENTATION NEEDED'


from clarity_tdl_tran tdl
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on department_id = tdl.dept_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join zc_orig_fin_class fc on fc.original_fin_class = tdl.original_fin_class

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and tdl.serv_area_id = 1312
and detail_type = 44
and rmc_code.name is not null

group by
tdl.serv_area_id
,tx_id