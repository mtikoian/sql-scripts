select
tx_id, detail_type, pat_id, BENEFIT_PLAN_ID, BENEFIT_PLAN_NAME, POST_DATE
from 
clarity_tdl_tran tdl
inner join clarity_epp epp on epp.BENEFIT_PLAN_ID = tdl.cur_plan_id
where post_date >= '2014-12-01 00:00:00'
and post_date <= '2014-12-31 00:00:00'
--and benefit_plan_id in (401101,3004002,3020006,3112037)
and RECORD_STAT_EPP_C = 2 -- Delete Status
and DETAIL_TYPE = 1 -- New Charges
and tx_id = 66429280
order by BENEFIT_PLAN_NAME