select 
 sa.rpt_grp_ten as service_area_id -- Displays previous service areas prior to service area consolidation
,arpb_charges.account_id
,arpb_charges.tx_id
,arpb_match.mtch_tx_hx_amt as payments
from arpb_transactions arpb_charges
left join arpb_tx_match_hx arpb_match on arpb_match.tx_id = arpb_charges.tx_id
left join arpb_transactions arpb_payments on arpb_payments.tx_id = arpb_match.mtch_tx_hx_id
left join clarity_loc loc on loc.loc_id = arpb_charges.loc_id
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN


where arpb_charges.service_date < ' 1/1/2018'
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and arpb_payments.post_date >= '1/1/2018'
and arpb_payments.post_date <= '2/28/2018'
and arpb_charges.tx_type_c = 1
and arpb_payments.tx_type_c = 2
and mtch_tx_hx_amt <> 0
and arpb_payments.void_date is null
and arpb_charges.void_date is null
and arpb_match.mtch_tx_hx_un_dt is null