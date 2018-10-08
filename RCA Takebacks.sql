IF OBJECT_ID('tempdb.dbo.#tempCharges', 'U') IS NOT NULL
  DROP TABLE #tempCharges; 

declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

SELECT tdl.tx_id
	,tdl.match_trx_id
	,eob.eob_codes
INTO #tempCharges
FROM clarity_tdl_tran tdl
LEFT JOIN pmt_eob_info_ii eob ON tdl.match_trx_id = eob.tx_id
WHERE tdl.match_proc_id = 7080
	AND tdl.original_payor_id = 1001
	AND eob_codes = 'N432'
	AND tdl.orig_service_date >= @start_date
	AND tdl.orig_service_date < @end_date

SELECT DISTINCT (tdl.insurance_amount)
	,TEMP.tx_id
	,TEMP.match_trx_id
	,TEMP.eob_codes
	,serv_area_name
	,ser.prov_name
	,ser2.npi
	,orig_service_date
	,account_id
	,cpt_code
	,eap.proc_name
	,eap2.proc_code
	,eap2.proc_name
	,original_payor_id
	,epm.payor_name
FROM #tempCharges TEMP
LEFT JOIN clarity_tdl_tran tdl ON TEMP.tx_id = tdl.tx_id
LEFT JOIN clarity_sa sa ON tdl.serv_area_id = sa.serv_area_id
LEFT JOIN clarity_ser ser ON tdl.billing_provider_id = ser.prov_id
LEFT JOIN clarity_ser_2 ser2 ON ser.prov_id = ser2.prov_id
LEFT JOIN clarity_eap eap ON tdl.cpt_code = eap.proc_code
LEFT JOIN clarity_eap eap2 ON tdl.match_proc_id = eap2.proc_id
LEFT JOIN clarity_epm epm ON tdl.original_payor_id = epm.payor_id
WHERE match_proc_id = 7080
	AND insurance_amount > 0
	AND tdl.detail_type = 20
	and tdl.serv_area_id < 30
ORDER BY tx_id