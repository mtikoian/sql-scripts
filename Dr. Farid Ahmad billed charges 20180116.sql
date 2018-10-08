/*
Please create a report regarding any billing for Dr. Farid Ahmad to include data from January 1, 2017 to current.   
Date of Service, Patient Name, MRN, and any other pertinent information Reginald Wagner has identified.  
The purpose of the report is to compare acute procedures and hospital consutls/any patient billed for on the 
acute side against what has been billed for on the ambulatory side from January 1, 2017. Working with 
Rev Cycle Liaison Reginald Wagner and Market Director Gary Broderick if additional questions are needed. 
13,208
*/

select 
ser.prov_id as 'Billing Provider ID'
,ser.prov_name as 'Billing Provider'
,cast(service_date as date) as 'Chg Service Date'
,arpb_tx.tx_id as 'Chg ID'
,pat.pat_name as 'Patient'
,pat.pat_mrn_id as 'MRN'
,arpb_tx.amount as 'Chg Amount'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'

from arpb_transactions arpb_tx
left join arpb_tx_void atv on atv.tx_id = arpb_tx.tx_id
left join clarity_ser ser on ser.prov_id = arpb_tx.billing_prov_id
left join patient pat on pat.pat_id = arpb_tx.patient_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
where tx_type_c = 1
and service_date >= '1/1/2017'
and billing_prov_id = '1611747'
and atv.tx_id is null

order by arpb_tx.service_date asc