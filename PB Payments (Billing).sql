declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

Select 
 tdl.tx_id as Encounter_Record_Number
,convert(varchar(18),eap_match.proc_code) as Transaction_Code
,CONVERT(VARCHAR(10), tdl.POST_DATE, 112) as Post_Date
,convert(varchar(18),tdl.CUR_PLAN_ID) as Insurance_Plan_Code
,case when tdl.DETAIL_TYPE in (20,22) then (tdl.AMOUNT)*-1 end as Payment_Amount
,case when tdl.DETAIL_TYPE in (21,23)then (tdl.AMOUNT)*-1 end as Adjustment_Amount
,tdl.match_trx_id as Transaction_Number
,case when detail_type in (22,23) then 'Yes' else 'No' end as 'DebitAdj_YN'
,loc.gl_prefix as Entity_code
,'Epic' as Source_System

from clarity_tdl_tran tdl
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id

where tdl.POST_DATE >= @start_date
	and tdl.POST_DATE <= @end_date
    and tdl.serv_area_id in (11,13,16,17,18,19)
	and tdl.amount <> 0

order by tdl.match_trx_id
,tdl.post_date

/*
2	New Payment
3	New Debit Adjustment
4	New Credit Adjustment
5	Payment Reversal
6	Credit Adjustment Reversal
11	Void Payment
12	Void Debit Adjustment
13	Void Credit Adjustment
20	Match/Unmatch (Charge->Payment)
21	Match/Unmatch (Charge->Credit Adjustment)
22	Match/Unmatch (Debit Adjustment->Payment)
23	Match/Unmatch (Debit Adjustment->Credit Adjustment)
30	Match/Unmatch (Credit Adjustment->Charge)
31	Match/Unmatch (Credit Adjustment->Debit Adjustment)
32	Match/Unmatch (Payment->Charge)
33	Match/Unmatch (Payment->Debit Adjustment)
*/
