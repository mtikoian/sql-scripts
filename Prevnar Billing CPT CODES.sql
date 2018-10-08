IF OBJECT_ID('tempdb.dbo.#tempPrevnar', 'U') IS NOT NULL
	DROP TABLE #tempPrevnar;

SELECT a."PROC_CODE"
	,a."ORIG_SERVICE_DATE"
	,a."GL_PREFIX"
	,a."NAME"
	,a."PROC_NAME"
	,a."PAT_NAME"
	,a."FINANCIAL_CLASS"
	,a."LOC_NAME"
	,a."SERV_AREA_ID"
	,a."INT_PAT_ID"
	,a."TX_ID"
	,a.pat_mrn_id
	,max(a.invoice_number) AS INVOICE_NUMBER
	,sum(a.charges) AS CHARGES
	,sum(a.payments) AS PAYMENTS
	,sum(a.[Credit Adjustments]) AS CREDIT_ADJUSTMENT
INTO #tempPrevnar
FROM (
	SELECT "CLARITY_EAP"."PROC_CODE"
		,"CLARITY_TDL_TRAN"."ORIG_SERVICE_DATE"
		,"CLARITY_LOC"."GL_PREFIX"
		,"ZC_FINANCIAL_CLASS"."NAME"
		,"CLARITY_EAP"."PROC_NAME"
		,"PATIENT"."PAT_NAME"
		,"ZC_FINANCIAL_CLASS"."FINANCIAL_CLASS"
		,"CLARITY_LOC"."LOC_NAME"
		,"CLARITY_TDL_TRAN"."PROCEDURE_QUANTITY"
		,"CLARITY_TDL_TRAN"."SERV_AREA_ID"
		,"CLARITY_TDL_TRAN"."INVOICE_NUMBER"
		,"CLARITY_TDL_TRAN"."INT_PAT_ID"
		,"CLARITY_TDL_TRAN"."TX_ID"
		,patient.pat_mrn_id
		,CASE 
			WHEN detail_type IN (
					1
					,10
					,40
					,41
					,42
					,43
					,44
					,45
					)
				THEN amount
			ELSE 0
			END AS 'Charges'
		,CASE 
			WHEN detail_type IN (
					2
					,5
					,11
					,20
					,22
					,32
					,33
					)
				THEN amount
			ELSE 0
			END AS 'Payments'
		,CASE 
			WHEN detail_type IN (
					4
					,6
					,13
					,21
					,23
					,30
					,31
					)
				THEN amount
			ELSE 0
			END AS 'Credit Adjustments'
	FROM (
		(
			(
				"Clarity"."dbo"."CLARITY_TDL_TRAN" "CLARITY_TDL_TRAN" LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_EAP" "CLARITY_EAP" ON "CLARITY_TDL_TRAN"."PROC_ID" = "CLARITY_EAP"."PROC_ID"
				) LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_LOC" "CLARITY_LOC" ON "CLARITY_TDL_TRAN"."LOC_ID" = "CLARITY_LOC"."LOC_ID"
			) LEFT OUTER JOIN "Clarity"."dbo"."ZC_FINANCIAL_CLASS" "ZC_FINANCIAL_CLASS" ON "CLARITY_TDL_TRAN"."ORIGINAL_FIN_CLASS" = "ZC_FINANCIAL_CLASS"."FINANCIAL_CLASS"
		)
	LEFT OUTER JOIN "Clarity"."dbo"."PATIENT" "PATIENT" ON "CLARITY_TDL_TRAN"."INT_PAT_ID" = "PATIENT"."PAT_ID"
	WHERE (
			"CLARITY_TDL_TRAN"."SERV_AREA_ID" = 11
			OR "CLARITY_TDL_TRAN"."SERV_AREA_ID" = 13
			OR "CLARITY_TDL_TRAN"."SERV_AREA_ID" = 16
			OR "CLARITY_TDL_TRAN"."SERV_AREA_ID" = 17
			OR "CLARITY_TDL_TRAN"."SERV_AREA_ID" = 18
			OR "CLARITY_TDL_TRAN"."SERV_AREA_ID" = 19
			)
		AND "CLARITY_TDL_TRAN"."ORIG_SERVICE_DATE" >= {ts '2015-01-01 00:00:00' }
		AND ("CLARITY_EAP"."PROC_CODE" = '90670')
		--AND pat_mrn_id = 'E5834070'
	) a
GROUP BY a."PROC_CODE"
	,a."ORIG_SERVICE_DATE"
	,a."GL_PREFIX"
	,a."NAME"
	,a."PROC_NAME"
	,a."PAT_NAME"
	,a."FINANCIAL_CLASS"
	,a."LOC_NAME"
	,a."SERV_AREA_ID"
	,a."INT_PAT_ID"
	,a."TX_ID"
	,a.pat_mrn_id

SELECT b.tx_id
	,b."SERV_AREA_ID"
	,b."LOC_NAME"
	,b."GL_PREFIX"
	,b."INT_PAT_ID"
    ,b.pat_mrn_id
	,b."PAT_NAME"
	,b."ORIG_SERVICE_DATE"
	,b."PROC_CODE"
	,b."NAME"
	,b."PROC_NAME"
	,b."FINANCIAL_CLASS"
	,b.charges
	,b.payments
	,b.credit_adjustment
	,b.tx_id2
	,b.proc_code2
	,b.proc_name2
	,sum(charges2) AS charges2
	,sum(payments2) AS payments2
	,sum([Credit Adjustments2]) AS credit_adjustments2
FROM (
	SELECT #tempPrevnar.tx_id
		,#tempPrevnar."SERV_AREA_ID"
		,#tempPrevnar."LOC_NAME"
		,#tempPrevnar."GL_PREFIX"
		,#tempPrevnar."INT_PAT_ID"
	    ,#tempPrevnar.pat_mrn_id
		,#tempPrevnar."PAT_NAME"
		,#tempPrevnar."ORIG_SERVICE_DATE"
		,#tempPrevnar."PROC_CODE"
		,#tempPrevnar."NAME"
		,#tempPrevnar."PROC_NAME"
		,#tempPrevnar."FINANCIAL_CLASS"
		,#tempPrevnar.charges
		,#tempPrevnar.payments
		,#tempPrevnar.credit_adjustment	
		,tdl.tx_id AS tx_id2
		,eap.proc_code AS proc_code2
		,eap.proc_name AS proc_name2
		,CASE 
			WHEN detail_type IN (
					1
					,10
					,40
					,41
					,42
					,43
					,44
					,45
					)
				THEN amount
			ELSE 0
			END AS 'Charges2'
		,CASE 
			WHEN detail_type IN (
					2
					,5
					,11
					,20
					,22
					,32
					,33
					)
				THEN amount
			ELSE 0
			END AS 'Payments2'
		,CASE 
			WHEN detail_type IN (
					4
					,6
					,13
					,21
					,23
					,30
					,31
					)
				THEN amount
			ELSE 0
			END AS 'Credit Adjustments2'
	FROM #tempPrevnar
	INNER JOIN clarity_tdl_tran tdl ON #tempPrevnar.int_pat_id = tdl.int_pat_id
		AND #tempPrevnar.orig_service_date = tdl.orig_service_date
	INNER JOIN clarity_eap eap ON tdl.proc_id = eap.proc_id
	INNER JOIN clarity_loc loc ON tdl.loc_id = loc.loc_id
	WHERE eap.proc_code IN (
			'90471'
			,'G0009'
			)
	) b
GROUP BY b.tx_id
	,b."SERV_AREA_ID"
	,b."LOC_NAME"
	,b."GL_PREFIX"
	,b."INT_PAT_ID"
	,b."PAT_NAME"
	,b."ORIG_SERVICE_DATE"
	,b."PROC_CODE"
	,b."NAME"
	,b."PROC_NAME"
	,b."FINANCIAL_CLASS"
	,b.charges
	,b.payments
	,b.credit_adjustment
	,b.tx_id2
	,b.proc_code2
	,b.proc_name2
	,b.pat_mrn_id
ORDER BY int_pat_id
	,ORIG_SERVICE_DATE