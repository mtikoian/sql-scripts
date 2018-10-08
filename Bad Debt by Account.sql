
with charge as
(select * 
from
(
select
 loc_id
,account_id
,post_date
,tx_id
,amount * - 1as amount
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id asc) as Row#
 from clarity_tdl_tran tdl
 where 
 detail_type = 21
 and match_proc_id = 7064
 and tdl.serv_area_id in (11,13,16,17,18,19)
group by
 tdl_id
,loc_id
,tx_id
,account_id
,post_date
,tx_id
,amount
)a
where row# = 1
and post_date >= '1/1/2017'
and post_date <= '12/31/2017'
--and account_id = 400020010
)

select 
 upper(sa.name) as REGION
,charge.ACCOUNT_ID
,sum(amount) as BAD_DEBT
from charge
left join clarity_loc loc on loc.loc_id = charge.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join arpb_tx_void void on void.tx_id = charge.tx_id
where void.tx_id is null
group by
sa.name
,charge.account_id

order by
sa.name
,charge.account_id