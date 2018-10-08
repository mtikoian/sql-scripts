declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

select 

	 sa.serv_area_name
	,tdl.account_id
	,tdl.post_date
	,tdl.tx_id
	,perf.prov_name as 'performing_provider'
	,case when tdl.detail_type = 32 then 'Pymt_Mx_Chg' else null end as 'tran_type'
	,eap.proc_code
	,eap.proc_name
	,eap_match.proc_code
	,eap_match.proc_name
	,epm.payor_name
	,tdl.orig_amt
	,tdl.insurance_amount


from 

clarity_tdl_tran tdl
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id
left join clarity_ser perf on tdl.match_prov_id =  perf.prov_id
left join clarity_eap eap on tdl.proc_id = eap.proc_id
left join clarity_eap eap_match on tdl.MATCH_PROC_ID = eap_match.proc_id
left join clarity_epm epm on tdl.original_payor_id = epm.payor_id

where

sa.serv_area_id = 612
and tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and tdl.detail_type in (32) --Payment matched to Charge
and eap.proc_code = '2000'
and eap_match.proc_code in ('90460','90461','90698','90670','90744','90680','90633','90707','90716','90700','90648','90713','90715','90734','90649','90657','90658','90660','90473','90710')


order by account_id, post_date, eap_match.proc_code

--first run back to 1/1/15