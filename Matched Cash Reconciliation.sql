declare @start_date as date = EPIC_UTIL.EFN_DIN('t-4')
declare @end_date as date = EPIC_UTIL.EFN_DIN('t-4')
declare  @serv_area_id as int = 11
--23,641

select 
 dd.year as 'YEAR'
,dd.year_month as 'YEAR-MONTH'
,@start_date as 'START DATE'
,@end_date as 'END DATE'
,cast(tdl_pay.post_date as date) as 'PAYMENT POST DATE'
,tdl_pay.tx_id as 'PAYMENT ETR'
,sa_pay.serv_area_name + ' - ' + cast(sa_pay.serv_area_id as varchar) as 'PAYMENT SERVICE AREA'
,loc_pay.loc_name + ' - ' + cast(loc_pay.loc_id as varchar) as 'PAYMENT LOCATION'
,dep_pay.department_name + ' - ' + cast(dep_pay.department_id as varchar) as 'PAYMENT DEPARTMENT'
,eap_pay.proc_code as 'PAYMENT PROCEDURE CODE'
,eap_pay.proc_name as 'PAYMENT PROCEDURE DESC'
,zps.name as 'SOURCE'
,zmds.name as 'POSTING MODULE'
,tdl_pay.amount as 'PAYMENT AMOUNT'
,tdl_pay.account_id as 'ACCOUNT'
,acct.account_name as 'ACCOUNT NAME'
,tdl_pay.tx_num as 'TRANSACTION #'
,tdl_pay.orig_ref_num as 'REFERENCE #'
,tdl_pay.posting_batch_num as 'POSTING BATCH #'
,atm.reconciliation_num as 'RECONCILIATION #'
,ci.cdw_name as 'CASH DRAWER'
,loc_pay.gl_prefix + ' - ' + dep_pay.gl_prefix as 'PAYMENT FULL GL #'
,ci.display_name as 'DISPLAY NAME'
,arpb_tx_2.pmt_routing_code_c as 'PAYMENT ROUTING CODE'
,arpb_tx_2.pmt_routing_number as 'PAYMENT ROUTING #'
,arpb_pay.ipp_inv_number as 'INVOICE #'
,tdl_pay.match_trx_id as 'MATCHING ETR'
,sa_chg.serv_area_name + ' - ' + cast(sa_chg.serv_area_id as varchar) as 'MATCHING SERVICE AREA'
,loc_chg.loc_name + ' - ' + cast(loc_chg.loc_id as varchar) as 'MATCHING LOCATION'
,dep_chg.department_name + ' - ' + cast(dep_chg.department_id as varchar) as 'MATCHING DEPARTMENT'
,cast(arpb_chg.service_date as date) as 'MATCHING SERVICE DATE'
,arpb_chg.amount as 'MATCHING AMOUNT'
,eap_chg.proc_code as 'MATCHING PROCEDURE CODE'
,eap_chg.proc_name as 'MATCHING PROCEDURE DESC'
,loc_chg.gl_prefix + ' - ' + dep_chg.gl_prefix as 'MATCHING FULL GL #'
,arpb_chg.tx_type_c as 'MATCHING TYPE'

--,case when tdl.detail_type in (3,5,6,12) then 'DEBIT' else 'CREDIT' end as 'TRAN TYPE'

--,case when tdl.detail_type in (2,3,4) then 'POSTED'
--      when tdl.detail_type in (11,12,13) then 'VOID'
--   when tdl.detail_type in (5,6) then 'REVERSAL'
--   else '' end as 'POSTING TYPE'



from

clarity_tdl_tran tdl_pay
left join clarity_loc loc_pay on loc_pay.loc_id = tdl_pay.loc_id
left join clarity_dep dep_pay on dep_pay.department_id = tdl_pay.dept_id
left join clarity_eap eap_pay on eap_pay.proc_id = tdl_pay.proc_id
left join account acct on acct.account_id = tdl_pay.account_id
left join arpb_tx_moderate atm on atm.tx_id = tdl_pay.tx_id
left join arpb_transactions arpb_pay on arpb_pay.tx_id = tdl_pay.tx_id
left join cashdwr_deposit_txs cdt on cdt.transaction_id = tdl_pay.tx_id 
left join zc_payment_source zps on zps.payment_source_c = tdl_pay.orig_pay_source_c
left join zc_tran_type ztt on ztt.tran_type = tdl_pay.tran_type
left join zc_mtch_dist_src zmds on zmds.mtch_tx_hx_dist_c = arpb_pay.credit_src_module_c
left join cashdwr_info ci on ci.cdw_id = cdt.cdw_id
left join arpb_transactions2 arpb_tx_2 on arpb_tx_2.tx_id = arpb_pay.tx_id
left join date_dimension dd on dd.calendar_dt = tdl_pay.post_date
left join clarity_sa sa_pay on sa_pay.serv_area_id = tdl_pay.serv_area_id
left join arpb_transactions arpb_chg on arpb_chg.tx_id = tdl_pay.match_trx_id
left join clarity_dep dep_chg on dep_chg.department_id = arpb_chg.department_id
left join clarity_loc loc_chg on loc_chg.loc_id = arpb_chg.loc_id
left join clarity_sa sa_chg on sa_chg.serv_area_id = arpb_chg.service_area_id
left join clarity_eap eap_chg on eap_chg.proc_id = arpb_chg.proc_id

where

tdl_pay.post_date >= @start_date
and tdl_pay.post_date <= @end_date
and sa_pay.serv_area_id = @serv_area_id
and detail_type in (2,5,11,20,22,32,33) -- Payment > Charge
and (tdl_pay.debit_gl_num = 'CASH' or tdl_pay.credit_gl_num = 'CASH')
