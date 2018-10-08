DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-9')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')
DECLARE @ar_date as date = EPIC_UTIL.EFN_DIN('me-10')

select 
 tdl.account_id
,tdl.tx_id
,charge_slip_number
,eap.proc_code
,eap.proc_name
,eap_match.proc_code
,eap_match.proc_name
,cast(tdl.post_date as date) as post_date
,tdl.amount
,cast(tdl.orig_service_date as date) as service_date
,detail_type
,arpb_tx.outstanding_amt
,loc.rpt_grp_two
from clarity_tdl_tran tdl
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten

where 
arpb_tx.outstanding_amt = 0
and tdl.orig_service_date <= @ar_date
and tdl.post_date>= @start_date
and tdl.post_date <= @end_date
and ((eap.proc_code in ('5002','5017','6002','5060') and eap_match.proc_code in ('5017','6002'))
or (eap.proc_code in ('5060')))
and sa.rpt_grp_ten in ('11')
and tdl.match_trx_id is not null
