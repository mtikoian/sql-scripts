select
 dep.department_id as 'Department ID'
,dep.department_name as 'Department Name'
,cast(arpb_chg.service_date as date) as 'Service Date'
,arpb_chg.tx_id as 'Charge ID'
,eob.tx_id as 'Payment ID'
,epm.payor_id as 'Payor ID'
,epm.payor_name as 'Payor Name'
,pat.pat_mrn_id as 'Patient MRN'
,pat.pat_name as 'Pateint name'
,cast(pat.birth_date as date) as 'DOB'
--,arpb_pay.tx_id
--,eob.line
--,arpb_match.line
,denial_codes as 'Denial Code'
,rmc.remit_code_name as 'Denial Desc'
,arpb_chg.amount as 'Charge Amt'
,eob.cvd_amt as 'Covered Amt'
,eob.noncvd_amt as 'Non-Covered Amt'
,eob.paid_amt as 'Payment Amt'

from pmt_eob_info_i eob
left join arpb_tx_match_hx arpb_match on arpb_match.tx_id = eob.tx_id and arpb_match.line = eob.line
left join arpb_transactions arpb_chg on arpb_chg.tx_id = arpb_match.mtch_tx_hx_id
left join arpb_transactions arpb_pay on arpb_pay.tx_id = arpb_match.tx_id
left join clarity_rmc rmc on rmc.remit_code_id = eob.denial_codes
left join clarity_dep dep on dep.department_id = arpb_chg.department_id
left join patient pat on pat.pat_id = arpb_chg.patient_id
left join clarity_epm epm on epm.payor_id = arpb_pay.payor_id

where eob.denial_codes in ('165','197')
and arpb_chg.service_date between '6/1/2017' and '8/31/2017'
and arpb_chg.void_date is null
and arpb_pay.void_date is null
--and arpb_chg.tx_id = 169727443 
--and arpb_pay.tx_id = 161386392
and arpb_chg.department_id in 
(11132001
,11132002
,11132003
,11132004
,11132005
,11132006
,11101331
,11101329
,11101325
,11101327
,11101333
,11101426
,11101294
,11101161
,11101213
,11101223
)

order by arpb_chg.tx_id
