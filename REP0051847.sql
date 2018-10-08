


select distinct
10 [HSPCODE]
,tdl.MATCH_PROC_ID [PaymentID]
,eap.PROC_CODE [TransactionCode]
,tdl.AMOUNT [TransactionAmount]
,tdl.POST_DATE [Transaction Post Date]
,tdl.MATCH_TX_TYPE
,hsp.ACCT_ZERO_BAL_DT 
,tdl.ORIG_AMT
from CLARITY_TDL_TRAN tdl
left outer join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
--left outer join ARPB_TX_MODERATE arpb_mod on arpb_mod.TX_ID = tdl.MATCH_TRX_ID
left outer join HSP_ACCT_SBO sbo on sbo.HSP_ACCOUNT_ID = tdl.HSP_ACCOUNT_ID
left outer join hsp_account hsp on hsp.hsp_account_id = tdl.HSP_ACCOUNT_ID

where cast(hsp.ACCT_ZERO_BAL_DT as date) between dateadd("d",1,CLARITY_REPORT.RELATIVE_START_DATE('{?StartDate}'))
	and dateadd("d",1,CLARITY_REPORT.RELATIVE_END_DATE('{?EndDate}'))
and tdl.MATCH_TX_TYPE in(2,3)
and sbo.SBO_HAR_TYPE_C in (0,2,3)
and tdl.SERV_AREA_ID=10
--and tdl.HSP_ACCOUNT_ID=35322798

--select * from CLARITY_TDL_TRAN where HSP_ACCOUNT_ID = 35322798


