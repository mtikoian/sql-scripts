select ofc.name, spec.name, count (distinct tdl.int_pat_id) as 'Distinct Count PAT ID'
from 
clarity_tdl_tran tdl
inner join ZC_ORIG_FIN_CLASS ofc on tdl.original_fin_class = ofc.ORIGINAL_FIN_CLASS
inner join ZC_SPECIALTY spec on tdl.PROV_SPECIALTY_C = spec.SPECIALTY_C
where ofc.name in ('Medicare','Medicare Managed')
and spec.name in ('internal medicine','family medicine')
and ORIG_SERVICE_DATE >= '2014-01-01'
and ORIG_SERVICE_DATE < '2015-01-01'
and detail_type = 1
group by ofc.name, spec.name
order by ofc.name, spec.name

select ofc.name, count (distinct tdl.int_pat_id) as 'Distinct Count PAT ID'
from 
clarity_tdl_tran tdl
inner join ZC_ORIG_FIN_CLASS ofc on tdl.original_fin_class = ofc.ORIGINAL_FIN_CLASS
inner join ZC_SPECIALTY spec on tdl.PROV_SPECIALTY_C = spec.SPECIALTY_C
where ofc.name in ('Medicare','Medicare Managed')
and spec.name in ('internal medicine','family medicine')
and ORIG_SERVICE_DATE >= '2014-01-01'
and ORIG_SERVICE_DATE < '2015-01-01'
group by ofc.name
order by ofc.name