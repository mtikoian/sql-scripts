declare @start_date as date = EPIC_UTIL.EFN_DIN('wb-6')
,arpb_tx.period as 'Adj Month'
,cast(arpb_tx.post_date as date) as 'Adj Post Date'
,eap.proc_code as 'Adj Code'
,eap.proc_name as 'Adj Desc'
,arpb_tx.amount as 'Adj Amt'
,arpb_tx_match.mtch_tx_hx_amt as 'Matched Amt'
--,tdl.tdl_id as chg_tdl_id
--,tdl.match_trx_id as ins_pymnt_id
,eob.cvd_amt as 'Cvd Amt'
,eob.noncvd_amt as 'NonCvd Amt'
,eob.ded_amt as 'Ded Amt'
,eob.copay_amt as 'Copay Amt'
,eob.coins_amt as 'Coins Amt'
,varc.REMIT_CODE_NM_WID as 'Remit Code'
