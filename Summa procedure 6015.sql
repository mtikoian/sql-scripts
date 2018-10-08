select 
 sa.serv_area_name
,arpb_tx.account_id
,arpb_chg.service_date
,arpb_tx.post_date
,match.mtch_tx_hx_id as 'chg_id'
,arpb_tx.tx_id as 'adj_id'
,eap.proc_code
,eap.proc_name
,arpb_tx.amount


from arpb_transactions arpb_tx
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join arpb_tx_void atv on atv.tx_id = arpb_tx.tx_id
left join arpb_tx_match_hx match on match.tx_id = arpb_tx.tx_id
left join arpb_transactions arpb_chg on arpb_chg.tx_id = match.mtch_tx_hx_id
left join clarity_sa sa on sa.serv_area_id = arpb_tx.service_area_id
where eap.proc_code = '6015'
and arpb_chg.service_area_id = 1312
--and arpb_tx.tx_id = 146476892
and atv.tx_id is null

order by arpb_chg.service_date