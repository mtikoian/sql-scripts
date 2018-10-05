select 
arpb_tx.TX_ID
,hx.TX_ID
,hx.LINE
,CR_HX_USER_ID
,cast(CR_HX_DATE as date) as 'CHG_REVIEW_HX_DATE'
,zc.NAME as ACTIVITY
,CR_HX_SYS_COMMENT
,upper(sa.NAME) as REGION

from ARPB_TRANSACTIONS arpb_tx 
left join ARPB_TX_CHG_REV_HX hx on arpb_tx.TX_ID = hx.TX_ID  and CR_HX_ACTIVITY_C = 1 
left join ZC_CHG_HX_ACTIVITY zc on zc.CHG_HX_ACTIVITY_C = hx.CR_HX_ACTIVITY_C
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where --CR_HX_ACTIVITY_C = 1 -- Entry
--and hx.CR_HX_DATE between '8/1/2018' and '8/31/2018'
 arpb_tx.POST_DATE between '7/1/2018' and '7/4/2018'
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)
--and CR_HX_SYS_COMMENT is null
and tx_type_c = 1
--and arpb_tx.TX_ID = 214293575