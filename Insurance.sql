select

 'ALL' as 'Level 1 Code'
,'N/A' as 'Insurance Code'
,'SELF PAY' as 'Insurance Code Description'
,'SELF PAY' as 'Insurance Subtype'
,'SELF PAY' as 'Financial Class'
,'SELF PAY' as 'SIPG'

union all


select

 convert(varchar,'ALL') as 'Level 1 Code'
,convert(varchar,benefit_plan_id) as 'insurance code'
,convert(varchar,benefit_plan_name) as 'insurance code description'
,convert(varchar,'') as 'insurance subtype'
,convert(varchar,coalesce(fin.name,'Commercial')) as 'financial class'
,convert(varchar,'') as 'sipg'

from clarity_epp epp
left join clarity_epm epm on epm.payor_id = epp.payor_id
left join zc_financial_class fin on fin.financial_class = epm.financial_class

