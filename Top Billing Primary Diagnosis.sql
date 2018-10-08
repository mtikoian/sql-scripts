with diagnosisrank as
(
select 
 year_month as 'Year-Month'
,ser.prov_name + ' - ' + ser.prov_id as 'Billing Provider'
,spec.name + ' - ' + spec.specialty_c as 'Specialty'
,edg.current_icd10_list + ' - ' + edg.dx_name as 'Primary Dx'
,count(*) as count
, ROW_NUMBER() OVER(PARTITION BY year_month,ser.prov_name + ' - ' + ser.prov_id ORDER BY count(*) DESC)  AS Row#
from arpb_transactions arpb_tx
left join clarity_edg edg on edg.dx_id = arpb_tx.primary_dx_id
left join date_dimension date on date.calendar_dt = arpb_tx.service_date
left join clarity_ser ser on ser.prov_id = arpb_tx.billing_prov_id
left join zc_specialty spec on spec.specialty_c = arpb_tx.prov_specialty_c
where tx_type_c = 1
and service_date >= '8/1/2017'
and billing_prov_id in ('1617936', '1677236')
and void_date is null
group by 
year_month
,ser.prov_name + ' - ' + ser.prov_id
,spec.name + ' - ' + spec.specialty_c 
,edg.current_icd10_list + ' - ' + edg.dx_name
--order by 
--year_month
--,ser.prov_name + ' - ' + ser.prov_id
--,count desc
)

select * from diagnosisrank
where row# <= 20