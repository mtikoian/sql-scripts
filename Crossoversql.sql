select
 medicare.tx_id as 'Charge ETR'
 ,medicare.department_id as 'Charge Department'
,'Professional' as 'Patient Type'
,medicare.patient_id as 'Patient ID'
,medicare.pat_last_name as 'Last Name'
,medicare.pat_first_name as 'First Name'
,cast(medicare.service_date as date) as 'Date of Service From'
,cast(medicare.service_date as date) as 'Date of Service To'
,medicare.account_id as 'Account Number'
,medicare.subscr_num as 'Medicare HIC Number'
,'' as 'Indigent'
,'' as 'Charity Care Application'
,medicaid.subscr_num as 'Medicaid ID'
,cast(medicare.post_date as date) as 'Medicare Remittance Date'
,cast(medicaid.post_date as date) as 'Medicaid Remittance Date'
,'' as 'Date First Bill Sent To Beneficiary'
,'' as 'Sent to Collections?'
,'' as 'Date Sent To Collections'
,'' as 'Date Returned From Collections'
,cast(medicaid.post_date as date) as 'Write Off Date'
,'' as '120 Days From First Bill?'
,isnull(medicare.cvd_amt,0) as 'Medicare Allowed Amt'
,isnull(medicare.noncvd_amt,0) as 'Medicare Not Allowed Amt'
,isnull(medicare.ded_amt,0) as 'Medicare Ded Amt'
,isnull(medicare.coins_amt,0) as 'Medicare Coins Amt'
,isnull(medicare.paid_amt,0) as 'Medicare Paid Amt'
,isnull(medicaid.noncvd_amt,0) as 'Medicaid Not Allowed Amt'
,isnull(medicaid.paid_amt,0) as 'Medicaid Paid Amt'
,isnull(medicare.ded_amt,0) + isnull(medicare.coins_amt,0) - isnull(medicaid.paid_amt,0) as 'Total'
,medicaid.ipp_crossovr_pmt_yn as 'Crossover'
,medicaid.tx_id 

from

(

select 
 arpb_tx.tx_id
,arpb_tx.tx_type_c
,arpb_tx.department_id
,epm_original.payor_name as original_payor
,eob.ded_amt
,eob.coins_amt
,eob.crossover_c
,eob.cvd_amt
,eob.noncvd_amt
,eob.paid_amt
,epm_current.payor_name as current_payor
,eap.proc_name
,arpb_pay.IPP_CROSSOVR_PMT_YN
,eob.PEOB_POST_NAME_C
,eob.denial_codes
,post.name
,pat.pat_last_name
,pat.pat_first_name
,arpb_tx.service_date
,arpb_tx.account_id
,cov.subscr_num
,arpb_tx.post_date
,arpb_tx.patient_id

from
arpb_transactions arpb_tx
left join clarity_epm epm_original on epm_original.payor_id = arpb_tx.original_epm_id
left join arpb_tx_match_hx arpb_match on arpb_match.tx_id = arpb_tx.tx_id
left join pmt_eob_info_i eob on eob.tx_id = arpb_match.mtch_tx_hx_id and eob.line = arpb_match.mtch_tx_hx_eob_line
left join arpb_transactions arpb_pay on arpb_pay.tx_id = arpb_match.mtch_tx_hx_id
left join clarity_epm epm_current on epm_current.payor_id = arpb_pay.payor_id
left join clarity_eap eap on eap.proc_code = arpb_pay.cpt_code
left join ZC_PEOB_POST_NAME post on post.PEOB_POST_NAME_C = eob.PEOB_POST_NAME_C
left join patient pat on pat.pat_id = arpb_tx.patient_id
left join coverage cov on cov.coverage_id = arpb_tx.original_cvg_id

where 
arpb_tx.department_id in 
( 17110101
 ,17110102
 ,19102101
 ,19102102
 ,19102103
 ,19102104
 ,19102105
)
and arpb_tx.tx_type_c = 1   -- Charges
and arpb_tx.original_epm_id = 1001 -- Medicare
and arpb_tx.void_date is null -- Exclude Voids
and (eob.ded_amt <> 0 or eob.coins_amt <> 0) -- Exclude deductibe or coinsurance amt = 0
--and arpb_tx.tx_id = 74990250
and eob.peob_post_name_c = 1
and eob.denial_codes is null
and arpb_pay.payor_id = 1001
) as medicare,

(
select 
 arpb_tx.tx_id
,arpb_tx.tx_type_c
,arpb_tx.department_id
,epm_original.payor_name as original_payor
,eob.ded_amt
,eob.coins_amt
,eob.crossover_c
,eob.cvd_amt
,eob.noncvd_amt
,eob.paid_amt
,epm_current.payor_name as current_payor
,eap.proc_name
,arpb_pay.IPP_CROSSOVR_PMT_YN
,eob.PEOB_POST_NAME_C
,eob.denial_codes
,post.name
,cov.subscr_num
,arpb_pay.post_date

from
arpb_transactions arpb_tx
left join clarity_epm epm_original on epm_original.payor_id = arpb_tx.original_epm_id
left join arpb_tx_match_hx arpb_match on arpb_match.tx_id = arpb_tx.tx_id
left join pmt_eob_info_i eob on eob.tx_id = arpb_match.mtch_tx_hx_id and eob.line = arpb_match.mtch_tx_hx_eob_line
left join arpb_transactions arpb_pay on arpb_pay.tx_id = arpb_match.mtch_tx_hx_id
left join clarity_epm epm_current on epm_current.payor_id = arpb_pay.payor_id
left join clarity_eap eap on eap.proc_code = arpb_pay.cpt_code
left join ZC_PEOB_POST_NAME post on post.PEOB_POST_NAME_C = eob.PEOB_POST_NAME_C
left join coverage cov on cov.coverage_id = arpb_pay.coverage_id

where 
arpb_tx.department_id in 
( 17110101
 ,17110102
 ,19102101
 ,19102102
 ,19102103
 ,19102104
 ,19102105
)
and arpb_tx.tx_type_c = 1   -- Charges
and arpb_tx.original_epm_id = 1001 -- Medicare
and arpb_tx.void_date is null -- Exclude Voids
--and (eob.ded_amt <> 0 or eob.coins_amt <> 0) -- Exclude deductibe or coinsurance amt = 0
--and arpb_tx.tx_id = 74990250
and eob.peob_post_name_c = 1
and eob.denial_codes is null
and arpb_pay.original_fc_c in (3,102)
) as medicaid

where medicare.tx_id = medicaid.tx_id

order by medicare.tx_id

