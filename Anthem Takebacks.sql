/* SSMSBoost
Event: Timer
Event date: 2017-08-29 12:20:51
*/
/*
She will need transaction detail 
(patient name, dob, Anthem ID Number, ICN of Payment, CPT Code, Modifier, Billing Provider, Charge Amount, 
Allowed Amount, Paid Amount, Takeback amount, Service Date, Original Pmt Date, Takeback date)
*/

select 
 arpb_chg.service_area_id as 'Service Area'
,cast(arpb_chg.service_date as date) as 'Service Date'
,arpb_chg.tx_id as 'Charge ID'
,arpb_chg.amount as 'Charge Amt'
,eap.proc_code  as 'Procedure Code'
,eap.proc_name as 'Procedure Name'
,arpb_chg.modifier_one as 'Mod 1'
,arpb_chg.modifier_two as 'Mod 2'
,arpb_chg.modifier_three as 'Mod 3'
,arpb_chg.modifier_four as 'Mod 4'
,arpb_chg.account_id as 'Acct ID'
,arpb_chg.patient_id as 'Pat ID'
,pat.pat_name as 'Pat Name'
,ser.prov_id as 'Billing Prov ID'
,ser.prov_name as 'Billing Prov Name'
,arpb_pay.payor_id as 'Takeback Payor ID'
,epm.payor_name as 'Take Payor Name'
,arpb_chg.outstanding_amt as 'Outstanding Amt'
,eob.tx_id as 'Takeback Payment ID'
,eob.ICN as 'ICN'
,cast(arpb_pay.post_date as date) as 'TakebackPost Date'
,eob.paid_amt as 'Paid Amount'
,eob.comments as 'Comments'
,arpb_match2.max_line as 'Original Payment Line'
,arpb_match3.mtch_tx_hx_id as 'Original Payment ID'
,cast(arpb_pay2.post_date as date) as 'Original Payment Post Date'
,datediff(mm,arpb_pay2.post_date,arpb_pay.post_date) as 'Months from Orig Payment'

from pmt_eob_info_i eob
left join arpb_tx_match_hx arpb_match on arpb_match.tx_id = eob.tx_id and arpb_match.line = eob.line
left join arpb_transactions arpb_pay on arpb_pay.tx_id = eob.tx_id
left join clarity_epm epm on epm.payor_id = arpb_pay.payor_id
left join arpb_transactions arpb_chg on arpb_chg.tx_id = arpb_match.mtch_tx_hx_id
left join patient pat on pat.pat_id = arpb_chg.patient_id
left join clarity_ser ser on ser.prov_id = arpb_chg.billing_prov_id
left join clarity_eap eap on eap.proc_id = arpb_chg.proc_id
left join (select min(line) as max_line, tx_id from arpb_tx_match_hx where MTCH_TX_HX_UN_DT is null group by tx_id) arpb_match2 on arpb_match2.tx_id = arpb_chg.tx_id
left join arpb_tx_match_hx arpb_match3 on arpb_match3.tx_id = arpb_chg.tx_id and arpb_match2.max_line = arpb_match3.line
left join arpb_transactions arpb_pay2 on arpb_pay2.tx_id = arpb_match3.mtch_tx_hx_id

where eob.tx_id = 138564573
and arpb_chg.outstanding_amt > 0 
and eob.paid_amt < 0
and arpb_pay.payor_id in (1006)
and arpb_chg.service_area_id in (11,13,16,17,18,19)
and datediff(mm,arpb_pay2.post_date,arpb_pay.post_date) >= 24