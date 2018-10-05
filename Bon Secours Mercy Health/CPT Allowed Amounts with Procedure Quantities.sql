declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-3') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 
 upper(sa.NAME) + ' [' + sa.RPT_GRP_TEN + ']' as REGION
,eob.DEPT_SPECIALTY as 'DEPARTMENT SPECIALTY'
,ser.PROV_TYPE as 'PROVIDER TYPE'
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
,eob.EOB_COPAY_AMOUNT as 'COPAY AMT'
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
left join clarity_ser ser on ser.prov_id = eob.PROV_ID
where eob.eob_allowed_amount > 0
and arpb_tx.SERVICE_DATE >= @start_date
and arpb_tx.SERVICE_DATE <= @end_date
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and eob.PAYOR_ID in (1005, 1006, 3010, 3123, 3004, 10011, 1003, 4309, 4329, 3067, 4316, 4318, 4319, 4320, 4321, 9011, 3020, 10013, 1007, 3112, 10012, 3519, 5167, 4234, 4244)
and void.tx_id is null
order by tx_match.mtch_tx_hx_id



