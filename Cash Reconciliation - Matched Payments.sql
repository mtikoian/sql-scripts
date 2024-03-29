declare @start_date as date = EPIC_UTIL.EFN_DIN('6/16/2017')
declare @end_date as date = EPIC_UTIL.EFN_DIN('6/30/2017')

select 
 
 upper(sa.serv_area_name) + ' - ' + cast(sa.serv_area_id as varchar) as 'SERVICE AREA'
,upper(loc.loc_name) + ' - ' + cast(loc.loc_id as varchar) as 'LOCATION'
,upper(dep.department_name) + ' - ' + cast(dep.department_id as varchar) as 'DEPARTMENT'
,upper(dep_chg.department_name) + ' - ' + cast(dep_chg.department_id as varchar) as 'CHARGE DEPARTMENT'
,tdl.tx_id as 'TRANSACTION ID'
,case when tdl.detail_type in (3,5,6,12) then 'DEBIT' else 'CREDIT' end as 'TRAN TYPE'
,eap.proc_code as 'PROCEDURE CODE'
,case when tdl.detail_type in (2,3,4) then 'POSTED'
      when tdl.detail_type in (11,12,13) then 'VOID'
      when tdl.detail_type in (5,6) then 'REVERSAL'
	  else 'MATCHED TO CHARGE' end as 'POSTING_TYPE'
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

Clarity.dbo.clarity_tdl_tran tdl
left join Clarity.dbo.clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join Clarity.dbo.clarity_loc loc on loc.loc_id = tdl.loc_id
left join Clarity.dbo.clarity_dep dep on dep.department_id = tdl.dept_id
left join Clarity.dbo.clarity_eap eap on eap.proc_id = tdl.proc_id
left join Clarity.dbo.account acct on acct.account_id = tdl.account_id
left join Clarity.dbo.arpb_tx_moderate atm on atm.tx_id = tdl.tx_id
left join Clarity.dbo.arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join Clarity.dbo.cashdwr_deposit_txs cdt on cdt.transaction_id = tdl.tx_id 
left join Clarity.dbo.zc_payment_source zps on zps.payment_source_c = tdl.orig_pay_source_c
left join Clarity.dbo.zc_tran_type ztt on ztt.tran_type = tdl.tran_type
left join Clarity.dbo.zc_mtch_dist_src zmds on zmds.mtch_tx_hx_dist_c = arpb_tx.credit_src_module_c
left join Clarity.dbo.cashdwr_info ci on ci.cdw_id = cdt.cdw_id
left join Clarity.dbo.arpb_transactions2 arpb_tx_2 on arpb_tx_2.tx_id = arpb_tx.tx_id
left join Clarity.dbo.clarity_tdl_tran tdl_charge on tdl_charge.tx_id = tdl.match_trx_id and tdl_charge.detail_type = 1
left join Clarity.dbo.clarity_dep dep_chg on dep_chg.department_id = tdl_charge.dept_id

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and sa.serv_area_id in (11,13,16,17,18,19)
and tdl.detail_type in (32) -- Payment matched to a charge
and (tdl.debit_gl_num = 'CASH' or tdl.credit_gl_num = 'CASH')




