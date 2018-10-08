declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2017') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('12/31/2017') 

select 
 case when enc2.VISIT_FC = 4 then 'SELF-PAY' else epm.PAYOR_NAME end as 'PAYOR'
,cast(enc.CONTACT_DATE as date) as 'CONTACT DATE'
,sum(enc.copay_collected) as 'COPAY COLLECTED'
,sum(enc.copay_due) as 'COPAY DUE'
,sum(enc.copay_collected)/sum(enc.copay_due) as 'COPAY COLLECTED %'

from V_SCHED_APPT enc
left join PAT_ENC enc2 on enc2.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
left join clarity_dep dep on dep.department_id = enc.department_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join clarity_prc prc on prc.prc_id = enc.prc_id
left join COVERAGE cov on cov.COVERAGE_ID = enc.COVERAGE_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = cov.PAYOR_ID
left join COVERAGE_2 cov2 on cov2.CVG_ID = cov.COVERAGE_ID

where enc.appt_status_c in (2) -- Completed
and  enc.contact_date >= @start_date
and enc.contact_date <= @end_date
and prc.benefit_group in ('Office Visit','PB Copay','Copay')
and enc.copay_due > 0
and loc.RPT_GRP_TEN in (1,11,13,16,17,18,19)

group by 
 case when enc2.VISIT_FC = 4 then 'SELF-PAY' else epm.PAYOR_NAME end
,cast(enc.CONTACT_DATE as date)

order by
 case when enc2.VISIT_FC = 4 then 'SELF-PAY' else epm.PAYOR_NAME end
,cast(enc.CONTACT_DATE as date)