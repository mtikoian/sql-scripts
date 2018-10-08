--declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')
--declare  @serv_area_id as int = {?Service Area}

declare @start_date as date = EPIC_UTIL.EFN_DIN('3/1/2017')
declare @end_date as date = EPIC_UTIL.EFN_DIN('3/27/2017')

select 
 
 upper(sa.serv_area_name) + ' - ' + cast(sa.serv_area_id as varchar) as 'CHARGE SERVICE AREA'
,upper(loc.loc_name) + ' - ' + cast(loc.loc_id as varchar) as 'CHARGE LOCATION'
,upper(dep.department_name) + ' - ' + cast(dep.department_id as varchar) as 'CHARGE DEPARTMENT'
,tdl.tx_id as 'TRANSACTION ID'
,'Credit' as 'TRAN TYPE'
,eap.proc_code as 'PROCEDURE CODE'
,'Matched Payment' as 'POSTING_TYPE'
,tdl.post_date as 'POST DATE'
,zps.name as 'SOURCE'
,zmds.name as 'POSTING MODULE'
,tdl.amount as 'PAYMENT AMOUNT'
,tdl.account_id as 'ACCOUNT'
,acct.account_name as 'ACCOUNT NAME'
,tdl.tx_num as 'TRANSACTION #'
,tdl.orig_ref_num as 'REFERENCE #'
,tdl.posting_batch_num as 'POSTING BATCH #'
,atm.reconciliation_num as 'RECONCILIATION #'
,ci.cdw_name as 'CASH DRAWER'
,loc.gl_prefix + ' - ' + dep.gl_prefix as 'FULL GL #'
,ci.display_name as 'DISPLAY NAME'
,arpb_tx_2.pmt_routing_code_c as 'PAYMENT ROUTING CODE'
,arpb_tx_2.pmt_routing_number as 'PAYMENT ROUTING #'
,arpb_tx.ipp_inv_number as 'INVOICE #'
,@start_date as 'START DATE'
,@end_date as 'END DATE'

from

clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join account acct on acct.account_id = tdl.account_id
left join arpb_tx_moderate atm on atm.tx_id = tdl.tx_id
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join cashdwr_deposit_txs cdt on cdt.transaction_id = tdl.tx_id 
left join zc_payment_source zps on zps.payment_source_c = tdl.orig_pay_source_c
left join zc_tran_type ztt on ztt.tran_type = tdl.tran_type
left join zc_mtch_dist_src zmds on zmds.mtch_tx_hx_dist_c = arpb_tx.credit_src_module_c
left join cashdwr_info ci on ci.cdw_id = cdt.cdw_id
left join arpb_transactions2 arpb_tx_2 on arpb_tx_2.tx_id = arpb_tx.tx_id
left join clarity_tdl_tran match_tdl on match_tdl.tx_id = tdl.match_trx_id and match_tdl.detail_type = 1
left join clarity_sa sa on sa.serv_area_id = match_tdl.serv_area_id
left join clarity_loc loc on loc.loc_id = match_tdl.loc_id
left join clarity_dep dep on dep.department_id = match_tdl.dept_id

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.detail_type in (32) -- Payment Matched to a charge
and tdl.amount <> 0
