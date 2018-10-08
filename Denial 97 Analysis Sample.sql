/*
Need a rolling 12 month report on Denial 97 remit code. Need to also include voided charges with denial 97. Need by transaction post month. Please assign to Dustin Plowman to work with Tina Haas. 
This report is high on Carl Swart's priority list. 

Need columns - 
Patient, 
DOS, 
Transaction date of remit denial, 
Payor, 
Provider, 
Department, 
Department Specialty, 
CPT Code and Description, 
Modifier 1 and 2, 
Rejection Code and Description, 
Service Area, 
Rejection Charge Amount. 
*/

select 
 cast(eob.service_date as date) as 'Date of Service'
,pat.pat_mrn_id as 'Patient MRN'
,cast(charge_post_date as date) as 'Charge Post Date'
,charge_transaction_id as 'Charge Transaction'
,charge_amount as 'Charge Amount'
,cast(arpb_tx.void_date as date) as 'Void Date'
,eob.payor_id as 'Payor ID'
,epm.payor_name as 'Payor'
,ser.prov_id as 'Billing Provider ID'
,ser.prov_name as 'Billing Provider'
,sa.rpt_grp_ten as 'Region ID'
,upper(sa.name) as 'Region'
,eob.location_id as 'Location ID'
,loc.loc_name as 'Location'
,eob.department_id as 'Department'
,dep.specialty as 'Department Specialty'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Description'
,arpb_tx.modifier_one as 'Modifier one'
,arpb_tx.modifier_two as 'Modifier Two'
,cast(payment_post_date as date) as 'Payment Post Date'
,rmc.remit_code_id as 'Remit Code'
,rmc.remit_code_name as 'Remit Description'
,payment_transaction_id as 'Payment Transaction'
,denied_amount as 'Denied Amount'

from v_cube_f_pb_all_eob eob
left join patient pat on pat.pat_id = eob.patient_id
left join clarity_ser ser on ser.prov_id = eob.billing_provider_id
left join clarity_eap eap on eap.proc_id = eob.charge_procedure_id
left join clarity_rmc rmc on rmc.remit_code_id = eob.remit_code_id
left join clarity_dep dep on dep.department_id = eob.department_id
left join clarity_loc loc on loc.loc_id = eob.location_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_epm epm on epm.payor_id = eob.payor_id
left join arpb_transactions arpb_tx on arpb_tx.tx_id = charge_transaction_id
where eob.service_date >= '9/1/2017'
and eob.service_date <= '9/30/2017'
and rmc.remit_code_id = 97
and sa.rpt_grp_ten in (11,13,16,17,18,19)
