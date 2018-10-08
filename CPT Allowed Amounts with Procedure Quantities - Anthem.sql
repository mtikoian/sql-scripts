--January 2017
--V_ARPB_REIMBURSEMENT COUNT 388,821
--BELOW QUERY RESULTS 388,734
--Excluding voided charges 369,120

select 
 upper(sa.NAME) + ' [' + sa.RPT_GRP_TEN + ']' as REGION
,pos.pos_type as 'POS TYPE'
,tx_match.mtch_tx_hx_id as 'CHG ID'
,cast(arpb_tx.service_date as date) as 'CHG SERVICE DATE'
,eap.proc_code as 'PROC CODE'
,eap.proc_name as 'PROC DESC'
,arpb_tx.amount as 'CHG AMOUNT'
,arpb_tx.modifier_one as 'MODIFIER ONE'
,arpb_tx.modifier_two as 'MODIFIER TWO'
,tx_match.tx_id as 'PYMT ID'
,cast(PAYMENT_POST_DATE as date) as 'PYMT POST DATE'
,PAYOR_NM_WID as 'PAYOR'
,eob.eob_allowed_amount as 'ALLOWED AMT'
,eob.eob_deduct_amount as 'DEDUCTIBLE AMT'
,eob.eob_paid_amount as 'PAID AMT'
,arpb_tx.procedure_quantity as 'PROC QUANTITY'
from v_arpb_reimbursement eob
left join arpb_tx_match_hx tx_match on tx_match.tx_id = eob.payment_tx_id and tx_match.line = eob.eob_line
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tx_match.mtch_tx_hx_id and arpb_tx.tx_type_c = 1
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join clarity_pos pos on pos.pos_id = arpb_tx.pos_id
left join arpb_tx_void void on void.tx_id = arpb_tx.tx_id
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
where eob.eob_allowed_amount > 0
and arpb_tx.SERVICE_DATE >= '3/15/2017'
and arpb_tx.SERVICE_DATE <= getdate()
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and eob.PAYOR_ID in (3010, 1005, 3123, 1006, 11001, 4011, 4012) -- Anthem
and void.tx_id is null
and dep.specialty in ('Family Medicine','General Internal Medicine','Pediatrics','Primary Care','Internal Medicine')
order by tx_match.mtch_tx_hx_id



