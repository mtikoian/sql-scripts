select distinct(benefit_plan_name), benefit_plan_id, epp.product_type, epp.rpt_grp_one, epp.rpt_grp_two, 
epm.payor_name, fin.name as 'financial_class', 
record_stat_epp_c, count(subscr_ssn) as Count
from clarity_epp epp
left outer join coverage cov on epp.benefit_plan_id = cov.plan_id
left outer join clarity_epm epm on epp.PAYOR_ID = epm.PAYOR_ID
left outer join ZC_FINANCIAL_CLASS fin on epm.financial_class = fin.financial_class
where (CVG_TERM_DT < getdate() or CVG_TERM_DT is null)
and  record_stat_epp_c is null --null = Active Plans, hidden = 4, deleted = 2, inactive = 1
group by benefit_plan_name, benefit_plan_id, epp.product_type, epp.rpt_grp_one, epp.rpt_grp_two, epm.payor_name, fin.name,  record_stat_epp_c
order by count(subscr_ssn) desc
