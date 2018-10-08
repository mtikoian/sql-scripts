DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-16')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

SELECT
 sa.NAME + ' [' + sa.rpt_grp_ten + ']' as 'Region'
,loc.gl_prefix + ' [' + loc.rpt_grp_three + ']' as 'Location'
,dep.gl_prefix + ' [' + dep.rpt_grp_two + ']' as 'Department'
,fin.NAME + ' [' + fin.FIN_CLASS_C + ']' as 'Orig Fin Class'
,sum(case when tdl_match.DETAIL_TYPE in (1,3) then arpb_tx.AMOUNT else 0 end) as 'Orig Charge Amt'
,sum(case when tdl_match.DETAIL_TYPE in (5,20,22) then tdl_match.AMOUNT else 0 end) as 'Payments'
,sum(case when tdl_match.DETAIL_TYPE in (6,21,23) and eap_match.GL_NUM_DEBIT = 'CONTRA' then tdl_match.AMOUNT else 0 end) as 'Contract Adj'
,sum(case when tdl_match.DETAIL_TYPE in (6,21,23) and eap_match.GL_NUM_DEBIT = 'BAD' then tdl_match.AMOUNT else 0 end) as 'Bad Debt Adj'
,sum(case when tdl_match.DETAIL_TYPE in (6,21,23) and eap_match.GL_NUM_DEBIT = 'CHARITY' then tdl_match.AMOUNT else 0 end) as 'Charity Adj'
,sum(case when tdl_match.DETAIL_TYPE in (6,21,23) and eap_match.GL_NUM_DEBIT = 'ADMIN' then tdl_match.AMOUNT else 0 end) as 'Admin Adj'
,sum(arpb_tx.OUTSTANDING_AMT) as 'Charge Balance'

FROM
CLARITY_TDL_TRAN tdl 
left join CLARITY_TDL_TRAN tdl_match on tdl_match.TX_ID = tdl.TX_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID
left join ZC_FIN_CLASS fin on fin.FIN_CLASS_C = tdl.ORIGINAL_FIN_CLASS
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_EAP eap_match on eap_match.PROC_ID = tdl_match.MATCH_PROC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN


WHERE 
arpb_tx.SERVICE_DATE >= @start_date
and arpb_tx.SERVICE_DATE <= @end_date
and arpb_tx.DEBIT_CREDIT_FLAG = 1
and arpb_tx.AMOUNT > 0
and arpb_tx.VOID_DATE is null
and arpb_tx.OUTSTANDING_AMT = 0
and tdl.DETAIL_TYPE = 1
--and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and sa.RPT_GRP_TEN in (13)

GROUP BY
 sa.NAME + ' [' + sa.rpt_grp_ten + ']'
,loc.gl_prefix + ' [' + loc.rpt_grp_three + ']'
,dep.gl_prefix + ' [' + dep.rpt_grp_two + ']'
,fin.NAME + ' [' + fin.FIN_CLASS_C + ']'



