declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 
distinct *,
case when open_encounters >= 30 then '30 or Greater' else 'Less than 30' end as 'ENCOUNTER_BUCKET'
from ClarityCHPAdhoc.rpt.PB_COPR_Encounters_Monthly_Summary
where date >= @start_date
and date <= @end_date
order by region, visit_provider_id, date