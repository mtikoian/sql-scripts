select 
 date.YEAR_MONTH
,sa.RPT_GRP_TEN as 'REGION ID'
,upper(sa.NAME) as 'REGION'
,loc.LOC_ID as 'LOCATION ID'
,loc.lOC_NAME as 'LOCATION'
,dep.DEPARTMENT_ID as 'DEPARTMENT ID'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,emp.USER_ID as 'USER ID'
,emp.NAME as 'USER'
,eap.PROC_NAME as 'PAYMENT TYPE'
,src.NAME as 'CREDIT SOURCE'
,cast(arpb_tx.VOID_DATE as date) as 'VOID DATE'
,arpb_tx.AMOUNT * -1 as 'PAYMENT'


from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = arpb_tx.POST_DATE
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EMP emp on emp.USER_ID = arpb_tx.USER_ID
left join ZC_MTCH_DIST_SRC src on src.MTCH_TX_HX_DIST_C = arpb_tx.CREDIT_SRC_MODULE_C

where arpb_tx.SERVICE_AREA_ID in (19)
and arpb_tx.TX_TYPE_C = 2
and eap.PROC_CODE in ('1000','1001','1002')
and date.YEAR_MONTH >= '201810'
and arpb_tx.DEPARTMENT_ID not in (19000001)
and arpb_tx.LOC_ID not in (
197100, 
197000, 
19106, 
19108, 
19000, 
193300, 
193200, 
193500, 
196100, 
196000, 
19137, 
195000, 
195100, 
195100, 
195400, 
195400, 
194000
)