declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-17')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-17')

select 
 upper(sa.name) as 'Region'
,date.year_month as 'Month of Transaction'
,arpb_tx.ORIGINAL_FC_C
,arpb_tx.ORIGINAL_EPM_ID
,arpb3.original_fc_c
,arpb3.original_epm_id
,sum(MTCH_TX_HX_AMT) as 'Sent to Collections'
from arpb_transactions arpb_tx 
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join date_dimension date on date.calendar_dt = arpb_tx.post_date
left join arpb_tx_match_hx arpb2 on arpb2.tx_id = arpb_tx.tx_id
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join arpb_transactions arpb3 on arpb3.tx_id = arpb2.MTCH_TX_HX_ID and arpb3.tx_type_c = 1

where 
arpb_tx.post_date >= @start_date
and arpb_tx.post_date <= @end_date
and eap.proc_code = '5002'
and sa.rpt_grp_ten in (16)
and arpb_tx.tx_type_c = 3
--and void_date is null
and MTCH_TX_HX_UN_DTTM is null
group by 
 sa.name
,arpb_tx.ORIGINAL_FC_C
,arpb_tx.ORIGINAL_EPM_ID
,arpb3.original_fc_c
,arpb3.original_epm_id
,date.year_month

order by 
 sa.name
,arpb_tx.ORIGINAL_FC_C
,arpb_tx.ORIGINAL_EPM_ID
,arpb3.original_fc_c
,arpb3.original_epm_id
,date.year_month