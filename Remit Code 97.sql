/*

We need a report that will pull any line item charge with DOS 01/01/2016 through 12/31/2016 
that had a denial/reason code 97 where the adjustment equaled the total charge.       
It would  need to include the Date of Service, patient MRN, billing provider, 
the procedure code, DOS, original payer and if possible the user that submitted it out of a WQ.

*/


select 
 service_date as 'Date of Service'
,pat.pat_mrn_id as 'Patient MRN'
,ser.prov_id as 'Billing Provider ID'
,ser.prov_name as 'Billing Provider'
,eob.service_area_id as 'Service Area'
,eob.location_id as 'Location'
,eob.department_id as 'Department'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Description'
,rmc.remit_code_id as 'Remit Code'
,rmc.remit_code_name as 'Remit Description'
,charge_transaction_id as 'Charge Transaction'
,charge_amount as 'Charge Amount'
,payment_transaction_id as 'Payment Transaction'
,denied_amount as 'Denied Amount'
from V_CUBE_F_PB_ALL_EOB eob
left join patient pat on pat.pat_id = eob.patient_id
left join clarity_ser ser on ser.prov_id = eob.billing_provider_id
left join clarity_eap eap on eap.proc_id = eob.charge_procedure_id
left join clarity_rmc rmc on rmc.remit_code_id = eob.remit_code_id
where eob.service_date >= '1/1/2016'
and eob.service_date <= '12/31/2016'
and rmc.remit_code_id = 97
and eob.service_area_id in (11,13,16,17,18,19)
and charge_amount = denied_amount
