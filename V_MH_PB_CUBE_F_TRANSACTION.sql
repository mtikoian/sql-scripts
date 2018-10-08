/*Copyright (C) 2015 MERCY HEALTH
********************************************************************************
TITLE:   V_MH_PB_CUBE_F_TRANSACTION
PURPOSE: Fact table view for TDL with SSAS Cubes
AUTHOR:  Dustin Plowman
REVISION HISTORY: 
*dsp 4/19/16 - created
********************************************************************************
*/

SELECT tdl.TDL_ID
,tdl.TX_ID
,tdl.detail_type
,tdl.ACCOUNT_ID
,tdl.TX_NUM
,tdl.ORIG_REF_NUM
,tdl.POSTING_BATCH_NUM
,tdl.ORIG_SERVICE_DATE
,tdl.ORIG_POST_DATE
,tdl.POST_DATE  
,tdl.INT_PAT_ID
,tdl.PERFORMING_PROV_ID
,tdl.BILLING_PROVIDER_ID
,tdl.PROC_ID
,tdl.MATCH_PROC_ID
,tdl.SERV_AREA_ID
,tdl.LOC_ID
,tdl.POS_ID
,tdl.DEPT_ID
,eap.PROC_CODE
,tdl.ORIG_PAY_SOURCE_C
,arpb.CREDIT_SRC_MODULE_C 
,atm.RECONCILIATION_NUM
,ci.CDW_NAME
,ci.DISPLAY_NAME

/*TRANSACTION TYPE*/
,case when tdl.detail_type in (3,5,6,12) then 'Debit' when tdl.detail_type in (2,4,11,13) then 'Credit' else 'Other' end as 'Tran_Type'

/*POSTING TYPE*/
,case when tdl.detail_type in (2,3,4) then 'Posted' when tdl.detail_type in (11,12,13) then 'Void' when tdl.detail_type in (5,6) then 'Reversal' else 'Other' end as 'Posting_Type'

/*CHARGES*/
,CASE WHEN tdl.DETAIL_TYPE IN (1,10) THEN tdl.AMOUNT ELSE 0 END as CHARGES 
,case when tdl.detail_type in (1,10) and month(tdl.post_date) = month(tdl.orig_service_date) then tdl.amount else 0 end as CHARGES_CURRENT   
,(CASE WHEN tdl.DETAIL_TYPE IN (1,10) THEN tdl.AMOUNT ELSE 0 END) - (case when tdl.detail_type in (1,10) and month(tdl.post_date) = month(tdl.orig_service_date) then tdl.amount else 0 end)  as CHARGES_LATE    
,case when detail_type in (1,10) then tdl.PROCEDURE_QUANTITY else 0 end as CHARGE_COUNT

/*PAYMENTS*/
,CASE WHEN tdl.DETAIL_TYPE IN (2,5,11,20,22,32,33) THEN tdl.AMOUNT ELSE 0 END as PAYMENTS
,case when tdl.detail_type in (2,5,11,20,22,32,33) then tdl.patient_amount else 0 end as PAYMENTS_PATIENT
,case when tdl.detail_type in (2,5,11,20,22,32,33) then tdl.insurance_amount else 0 end as PAYMENTS_INSURANCE
,case when tdl.detail_type in (20) then tdl.amount else 0 end as PAYMENTS_MATCHED

/*CREDIT ADJUSTMENTS*/
,case when tdl.detail_type in (4,6,13,21,23,30,31) then tdl.amount else 0 end as CREDIT_ADJ
,case when tdl.detail_type in (21,23) and eap_match.gl_num_debit = 'Admin' then tdl.amount
      when tdl.detail_type in (4,13,30,31) and eap.gl_num_debit = 'Admin' then tdl.amount
	  when tdl.detail_type in (6) and eap.gl_num_credit = 'Admin' then tdl.amount
	  else 0 end as CREDIT_ADJ_ADMIN         
,case when tdl.detail_type in (21,23) and eap_match.gl_num_debit = 'CHARITY' then tdl.amount
      when tdl.detail_type in (4,13,30,31) and eap.gl_num_debit = 'CHARITY' then tdl.amount
	  when tdl.detail_type in (6) and eap.gl_num_credit = 'CHARITY' then tdl.amount
	  else 0 end as  CREDIT_ADJ_CHARITY       
,case when tdl.detail_type in (21,23) and eap_match.gl_num_debit = 'CONTRA' then tdl.amount
      when tdl.detail_type in (4,13,30,31) and eap.gl_num_debit = 'CONTRA' then tdl.amount
	  when tdl.detail_type in (6) and eap.gl_num_credit = 'CONTRA' then tdl.amount
	  else 0 end as CREDIT_ADJ_CONTRA    
,case when tdl.detail_type in (21,23) and eap_match.gl_num_debit = 'BAD' then tdl.amount
      when tdl.detail_type in (4,13,30,31) and eap.gl_num_debit = 'BAD' then tdl.amount
	  when tdl.detail_type in (4,21) and eap_match.gl_num_debit = 'BAD DEBT RECOVERY' then tdl.amount
	  when tdl.detail_type in (6) and eap.gl_num_credit = 'BADRECOVERY' then tdl.amount
	  else 0 end  as CREDIT_ADJ_BAD_DEBT    
,case when tdl.detail_type in (21,23) and (eap_match.gl_num_debit is null or eap_match.gl_num_debit not in ('CONTRA','CHARITY','ADMIN','BADRECOVERY','BAD') and eap.gl_num_debit not in ('BAD DEBT RECOVERY')) then tdl.amount
	  when tdl.detail_type in (4,13,30,31) and (eap.gl_num_debit is null or eap.gl_num_debit not in ('CONTRA','CHARITY','ADMIN','BAD DEBT RECOVERY','BADRECOVERY','BAD')) then tdl.amount
	  when tdl.detail_type in (6) and (eap.gl_num_credit is null or eap.gl_num_credit not in ('CONTRA','CHARITY','ADMIN','BAD DEBT RECOVERY','BADRECOVERY','BAD')) then tdl.amount
	  else 0 end as CREDIT_ADJ_OTHER
,case when tdl.detail_type in (21) then tdl.amount else 0 end as CREDIT_ADJ_MATCHED

/*DEBIT ADJUSTMENTS*/
,case when tdl.detail_type in (3,12) then tdl.amount else 0 end as DEBIT_ADJ
,case when tdl.detail_type in (3,12) and tdl.credit_gl_num = 'REFUND' then tdl.amount else 0 end as DEBIT_ADJ_REFUND            
,case when tdl.detail_type in (3,12) and (eap.gl_num_debit is null or eap.gl_num_credit <> 'REFUND') then tdl.amount else 0 end as DEBIT_ADJUSTMENTS_OTHER

/*Total Adjustments*/
,CASE WHEN tdl.DETAIL_TYPE IN (3,4,6,12,13,21,23,30,31) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as ADJUSTMENT_TOTAL

/*NET CHANGE IN AR*/
,case when tdl.amount is null then 0 
	  when detail_type in (1,10,11,12,13,2,20,21,22,23,3,30,31,32,33,4,5,6) then tdl.amount end as NET_CHANGE_AR       
	     
FROM clarity.dbo.clarity_tdl_tran tdl
left outer join clarity.dbo.clarity_eap eap on tdl.proc_id = eap.proc_id
left outer join clarity.dbo.clarity_eap eap_match on tdl.match_proc_id = eap_match.proc_id
left outer join arpb_transactions arpb on arpb.tx_id = tdl.tx_id
left outer join arpb_tx_moderate atm on atm.tx_id = tdl.tx_id
left outer join cashdwr_deposit_txs cdt on cdt.transaction_id = tdl.tx_id
left outer join cashdwr_info ci on ci.cdw_id = cdt.cdw_id

where tdl.serv_area_id in (16)
and tdl.post_date >= '2016-04-12'
and detail_type <= 33
