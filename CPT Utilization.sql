select

date.monthname_year as 'Month of Service'
,dep.department_name as 'Department'
,dep.specialty as 'Specialty'
,ser.prov_id as 'Billing Provider ID'
,ser.prov_name as 'Billing Provider'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,sum(arpb_tx.procedure_quantity) as 'Procedure Quanity'


from arpb_transactions arpb_tx
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
left join clarity_ser ser on ser.prov_id = arpb_tx.billing_prov_id
left join date_dimension date on date.calendar_dt = arpb_tx.service_date
where arpb_tx.service_area_id = 1312
and eap.proc_code between '99201' and '99215'
and tx_type_c = 1
and arpb_tx.void_date is null

group by 
date.monthname_year
,dep.department_name
,dep.specialty
,ser.prov_id
,ser.prov_name
,eap.proc_code
,eap.proc_name

order by 
date.monthname_year
,dep.department_name
,dep.specialty
,ser.prov_id
,ser.prov_name
,eap.proc_code
,eap.proc_name
