declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select
date.year_month as 'Year-Month'
,month_name as 'Month'
,sum(datediff(day, vacrw.entry_date, vacrw.exit_date)) as 'Total Charge Review Days'
,count(arpb_tx.account_id) as 'Accounts'
,cast(sum(datediff(day, vacrw.entry_date, vacrw.exit_date)) as float)/cast(count(arpb_tx.account_id) as float) as 'Review Days'

from arpb_transactions arpb_tx
left join arpb_tx_moderate atm on atm.tx_id = arpb_tx.tx_id
left join v_arpb_chg_review_wq vacrw on vacrw.tar_id = atm.source_tar_id
left join arpb_tx_void atv on atv.tx_id = arpb_tx.tx_id
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join date_dimension date on date.calendar_dt_str = vacrw.exit_date

where arpb_tx.tx_type_c =1
and (atv.old_etr_id is null and atv.reposted_etr_id is null and atv.repost_type_c is null and atv.retro_charge_id is null)
and vacrw.exit_date >= @start_date
and vacrw.exit_date <= @end_date
and loc.rpt_grp_ten in (11,13,16,17,18,19)
and loc.rpt_grp_two in ('11106','11124','11149' -- SPRINGFILED
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138' -- CINCINNATI
,'13104','13105' -- YOUNGSTOWN
,'16102','16103','16104' -- LIMA
,'17105','17106','17107','17108','17109','17110','17112','17113' -- LORAIN
,'18120','18121' -- DEFIANCE
,'18101','18102','18103','18104','18105','18130','18131','18132','18133' -- TOLEDO 
,'19101','19102','19106' -- KENTUCKY
)

GROUP BY 
date.year_month
,date.month_name

order by date.year_month
,date.month_name