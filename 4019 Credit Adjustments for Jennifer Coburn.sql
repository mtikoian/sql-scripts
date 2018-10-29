/*
I adjusted off invoices and we need to confirm DOS adjusted off prior to month end. This report is needed for adjustment code 4019 for date range 10/01-10/22/18 for Youngstown SA 19.  
The report needs to includes the DOS that was adjusted off and Jennifer Coburn as the user.  Ping me with any questions.
*/

select

 upper(sa.NAME) as 'REGION'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE_DATE'
,cast(tdl.POST_DATE as date) as 'POST_DATE'
,tdl.MATCH_TRX_ID as 'CHARGE_ID'
,tdl.TX_ID as 'ADJUSTMENT_ID'
,eap.PROC_CODE
,eap.PROC_NAME
,tdl.ORIG_AMT as 'CHG_AMT'
,tdl.AMOUNT as 'ADJ_AMT'
,tdl.USER_ID

from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where tdl.POST_DATE >= '10/1/2018'
and tdl.POST_DATE <= '10/22/2018'
and loc.RPT_GRP_TEN = 18
and eap.PROC_CODE = '4019'
and tdl.DETAIL_TYPE = 30 -- Credit Adjustment matched to CHARGE
and tdl.USER_ID = 'COBU101'

order by tdl.ORIG_SERVICE_DATE 