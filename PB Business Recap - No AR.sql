declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')
declare @sa as integer = {?Service Area}

select 

 [Service Area]
,[Billing Provider]
,[Month]
,[Original Service Date]
,coalesce(sum([Charges]),0) as Charges
,coalesce(sum([Self-pay Payments]),0) as 'Self-pay Payments'
,coalesce(sum([Insurance Payments]),0) as 'Insurance Payments'
,coalesce(sum([Debit Adjustments]),0)as 'Debit Adjustments'
,coalesce(sum([Credit Adjustments]),0) as 'Credit Adjustments'

from

(
select 
 sa.serv_area_name as 'Service Area'
,coalesce(ser.prov_name, 'Unknown Billing Provider') as 'Billing Provider'
,period as 'Month'
,orig_service_date as 'Original Service Date'
,case when detail_type in (1,10) then amount end as 'Charges'
,case when detail_type in (2,5,11,20,22,32,33) then insurance_amount end as 'Insurance Payments'
,case when detail_type in (2,5,11,20,22,32,33) then patient_amount end as 'Self-pay Payments'
,case when detail_type in (3,12) then amount end as 'Debit Adjustments'
,case when detail_type in (4,6,13,21,23,30,31) then amount end as 'Credit Adjustments'

from clarity_tdl_tran tdl
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id

where tdl.serv_area_id = @sa
and detail_type <=33

and orig_service_date >= @start_date
and orig_service_date <= @end_date
)a

group by 
 [Service Area]
,[Billing Provider]
,[Month]
,[Original Service Date]

order by 
 [Service Area]
,[Billing Provider]
,[Original Service Date]
