SELECT 
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
,crw.ENTRY_DATE as 'Entry Date'
,crw.EXIT_DATE as 'Exit Date'
,arpb_tx.ACCOUNT_ID as 'Account ID'

FROM ARPB_TRANSACTIONS arpb_tx
left join ARPB_TX_MODERATE atm on atm.TX_ID = arpb_tx.TX_ID
left join ARPB_TX_VOID atv on atv.TX_ID = arpb_tx.TX_ID
left join V_ARPB_CHG_REVIEW_WQ crw on crw.TAR_ID = atm.SOURCE_TAR_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
       
WHERE  arpb_tx.TX_TYPE_C=1 
and (atv.OLD_ETR_ID IS NULL and atv.REPOSTED_ETR_ID IS NULL and atv.REPOST_TYPE_C IS NULL and atv.RETRO_CHARGE_ID IS NULL)
and arpb_tx.SERVICE_DATE >= '5/1/2018'
and arpb_tx.SERVICE_DATE <= '5/31/2018'
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)