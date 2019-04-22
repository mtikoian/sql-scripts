select 
 tdl.TDL_ID
,tdl.TX_ID as 'CHARGE_ID'
,tdl.MATCH_TRX_ID as 'PAYMENT_ID'
,tdl.CHARGE_SLIP_NUMBER
,loc.GL_PREFIX as LOCATION_GL
,dep.GL_PREFIX as DEPARTMENT_GL
,dep.DEPARTMENT_NAME
,eap.PROC_CODE
,tdl.DETAIL_TYPE
,det.NAME 'DETAIL_TYPE_NAME'
,cast(tdl.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,cast(tdl.ORIG_POST_DATE as date) as ORIGINAL_POST_DATE
,cast(tdl.POST_DATE as date) as POST_DATE
,tdl.AMOUNT *-1 as PAYMENT_AMT
,arpb_tx.OUTSTANDING_AMT

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join ZC_DETAIL_TYPE det on det.DETAIL_TYPE = tdl.DETAIL_TYPE
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID

where tdl.DETAIL_TYPE in (20) -- Payments > Charges
and eap.PROC_CODE in ('99444','98969')
-- and tdl.CHARGE_SLIP_NUMBER = -11221057
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and arpb_tx.OUTSTANDING_AMT = 0
and arpb_tx.VOID_DATE is null
and tdl.ORIG_POST_DATE >= '3/1/2018'
and tdl.ORIG_POST_DATE <= '2/28/2019'
and tdl.POST_DATE <= '2/28/2019'
order by tdl.MATCH_TRX_ID
