SELECT serv_area_name
	,pat.pat_mrn_id
	,pat.pat_last_name
	,pat.pat_first_name
	,pat.pat_middle_name
	,max(contact_date) as 'last_contact_date'
FROM pat_enc enc
LEFT JOIN clarity_sa sa ON enc.serv_area_id = sa.serv_area_id
LEFT JOIN patient pat ON enc.pat_id = pat.pat_id
WHERE sa.serv_area_id = 701
	AND contact_date >= '2013-11-01'
GROUP BY serv_area_name
	,pat.pat_mrn_id
	,pat.pat_last_name
	,pat.pat_first_name
	,pat.pat_middle_name
ORDER BY pat_last_name