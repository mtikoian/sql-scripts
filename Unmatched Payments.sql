select
 upper(sa.serv_area_name) + ' - ' + cast(sa.serv_area_id as varchar) as 'SERVICE AREA'
,upper(loc.loc_name) + ' - ' + cast(loc.loc_id as varchar) as 'LOCATION'
,upper(dep.department_name) + ' - ' + cast(dep.department_id as varchar) as 'DEPARTMENT'
,tdl.tx_id as 'TRANSACTION ID'
,case when tdl.detail_type in (3,5,6,12) then 'DEBIT' else 'CREDIT' end as 'TRAN TYPE'
,eap.proc_code as 'PROCEDURE CODE'
,case when tdl.detail_type in (2,3,4) then 'POSTED'
      when tdl.detail_type in (11,12,13) then 'VOID'
      when tdl.detail_type in (5,6) then 'REVERSAL'
	  else '' end as 'POSTING_TYPE'
,cast(tdl.post_date as date) as 'POST DATE'
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

from clarity_tdl_tran tdl
left join arpb_tx_match_hx arpb_match on arpb_match.tx_id = tdl.tx_id -- matched transactions
left join arpb_tx_void atv on atv.tx_id = tdl.tx_id -- voided transactions
left join clarity_loc loc on loc.loc_id = tdl.loc_id 
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join zc_payment_source zps on zps.payment_source_c = tdl.orig_pay_source_c
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join zc_mtch_dist_src zmds on zmds.mtch_tx_hx_dist_c = arpb_tx.credit_src_module_c
left join account acct on acct.account_id = tdl.account_id
left join arpb_tx_moderate atm on atm.tx_id = tdl.tx_id
left join cashdwr_deposit_txs cdt on cdt.transaction_id = tdl.tx_id 
left join cashdwr_info ci on ci.cdw_id = cdt.cdw_id
left join arpb_transactions2 arpb_tx_2 on arpb_tx_2.tx_id = arpb_tx.tx_id

where 
arpb_match.mtch_tx_hx_id is null -- exclude all payments with a matched transaction
and atv.tx_id is null -- exclude all voided payments
and tdl.detail_type = 2
and tdl.loc_id = 19000
and tdl.amount <> 0
--and tdl.tx_id in (189419765, 189419773, 189419812)

order by 
 tdl.post_date
,tdl.tx_id