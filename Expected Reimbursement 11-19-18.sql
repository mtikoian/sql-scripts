select
 tdl.TX_ID
,tdl.POST_DATE
,tdl.SERV_AREA_ID
,fc.FINANCIAL_CLASS_NAME as ORIGINAL_FC
,atm.REIMB_CONTRACT_AMT -- ETR 162
,atm.EXP_REIMB_DYNAMIC -- ETR 164
,atm.EXPECTED_REIMB -- ETR 165
from CLARITY_TDL_TRAN tdl
left join ARPB_TX_MODERATE atm on atm.TX_ID = tdl.TX_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = tdl.ORIGINAL_FIN_CLASS
where tdl.DETAIL_TYPE = 1
and tdl.SERV_AREA_ID = 19
and tdl.ORIGINAL_FIN_CLASS = 2
and tdl.ORIG_SERVICE_DATE >= '11/20/2018'
--and atm.reimb_contract_amt is not null
order by tdl.TX_ID