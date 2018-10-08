select 
 arpb_tx.DEPARTMENT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department'
,dep.SPECIALTY as 'Department Specialty'
,dep.GL_PREFIX as 'Department GL'
,arpb_tx.LOC_ID as 'Location ID'
,loc.LOC_NAME as 'Location'
,loc.GL_PREFIX as 'Location GL'
,sa.RPT_GRP_TEN as 'Region ID'
,upper(sa.NAME) as 'Region'
,arpb_tx.SERVICE_DATE as 'Service Date'
,arpb_tx.POST_DATE as 'Post Date'
,arpb_tx.TX_ID as 'TX ID'
,case when arpb_tx.SERVICE_DATE > arpb_tx.POST_DATE then 0 else datediff(DD, arpb_tx.SERVICE_DATE, arpb_tx.POST_DATE) end as 'Lag Days'
,case when arpb_tx.SERVICE_DATE = arpb_tx.POST_DATE then 0 else 1 end as 'Lag Count'

from ARPB_TRANSACTIONS arpb_tx 
left join ARPB_TX_VOID void on void.TX_ID = arpb_tx.TX_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where arpb_tx.POST_DATE >= '5/1/2018'
and arpb_tx.POST_DATE <= '5/31/2018'
and arpb_tx.TX_TYPE_C = 1
and (void.OLD_ETR_ID is null and void.REPOSTED_ETR_ID is null and void.REPOST_TYPE_C is null and void.RETRO_CHARGE_ID is null)
and (arpb_tx.SERVICE_DATE = arpb_tx.POST_DATE or arpb_tx.POST_DATE = arpb_tx.POST_DATE)
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)