select distinct
 eap.PROC_CODE as 'POSTING CODE'
,eap.PROC_NAME as 'POSTING DESC'
,ztt.NAME as 'TYPE'
from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_TRAN_TYPE ztt on ztt.TRAN_TYPE = eap.TYPE_C
where loc.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and tdl.POST_DATE >= '9/1/2017'
and tdl.DETAIL_TYPE in (20,21)

order by eap.PROC_CODE