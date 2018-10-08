SELECT serv_area_name
	,pat_mrn_id
	,pat_last_name
	,pat_first_name
	,pat_middle_name

	,max(orig_service_date) AS 'max_orig_service_date'
FROM clarity_tdl_tran tdl
LEFT JOIN clarity_sa sa ON tdl.serv_area_id = sa.serv_area_id
LEFT JOIN patient pat ON tdl.int_pat_id = pat.pat_id
WHERE sa.serv_area_id = 701
	AND orig_service_date >= '2013-11-01'
	AND detail_type = 1
GROUP BY serv_area_name
	,pat_mrn_id
	,pat_last_name
	,pat_first_name
	,pat_middle_name

order by pat_last_name