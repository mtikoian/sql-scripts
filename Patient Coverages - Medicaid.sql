select
pac.pat_id
,pat.pat_mrn_id
,pat.pat_name
,pat.birth_date
,pac.account_id
,acct.account_name
,pac.fin_class as fin_class_id
,zfc.name as fin_class_name
,pac.coverage_id
,pac.payor_id
,epm.payor_name
,pac.plan_id
,epp.benefit_plan_name
,mem_number as medicaid_num
,mem_eff_from_date
,mem_eff_to_date 
from pat_acct_cvg pac
left join coverage_mem_list cml on cml.pat_id = pac.pat_id
left join clarity_epm epm on epm.payor_id = pac.payor_id
left join clarity_epp epp on epp.benefit_plan_id = pac.plan_id
left join patient pat on pat.pat_id = pac.pat_id
left join account acct on acct.account_id = pac.account_id
left join zc_fin_class zfc on zfc.fin_class_c = pac.fin_class
where pac.fin_class in (3,102) -- medicaid, medicaid managed
order by pac.pat_id, pac.line, mem_eff_from_date, mem_eff_to_date