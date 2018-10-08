declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

SELECT 
	 cast([Company Code] AS VARCHAR(50)) AS 'Company Code'
	,cast([Account Number] AS VARCHAR(20)) AS 'Account Number'
	,cast([Parent Account Number] AS VARCHAR(20)) AS 'Parent Account Number'
	,cast([Account Type] AS VARCHAR(5)) AS 'Account Type'
	,cast([Medical Record Number] AS VARCHAR(20)) AS 'Medical Record Number'
	,Replace(cast([Last Name] AS VARCHAR(100)), ',', ' ') AS 'Last Name'
	,Replace(cast([First Name] AS VARCHAR(50)), ',', ' ') AS 'First_Name'
	,cast([Middle Initial] AS VARCHAR(1)) AS 'Middle Initial'
	,cast([Birth Date] AS DATETIME) AS 'Birth Date'
	,cast([Social Security Number] AS VARCHAR(15)) AS 'Social Security Number'
	,cast([Patient Type Code] AS VARCHAR(20)) AS 'Patient Type Code'
	,cast([Hospital Service Code] AS VARCHAR(20)) AS 'Hospital Service Code'
	,cast([Admit Date] AS DATETIME) AS 'Admit Date'
	,cast([Discharge Date] AS DATETIME) AS 'Discharge Date'
	,cast([First Bill Date] AS DATETIME) AS 'First Bill Date'
	,max(cast([Financial Class Code 1] AS VARCHAR(20))) AS 'Financial Class Code 1'
	,max(cast([Financial Class Code 2] AS VARCHAR(20))) AS 'Financial Class Code 2'
	,max(cast([Financial Class Code 3] AS VARCHAR(20))) AS 'Financial Class Code 3'
	,max(cast([Financial Class Code 4] AS VARCHAR(20))) AS 'Financial Class Code 4'
	,max(cast([Financial Class Code 5] AS VARCHAR(20))) AS 'Financial Class Code 5'
	,max(cast([Insurance Code 1] AS VARCHAR(20))) AS 'Insurance Code 1'
	,max(cast([Insurance Code 2] AS VARCHAR(20))) AS 'Insurance Code 2'
	,max(cast([Insurance Code 3] AS VARCHAR(20))) AS 'Insurance Code 3'
	,max(cast([Insurance Code 4] AS VARCHAR(20))) AS 'Insurance Code 4'
	,max(cast([Insurance Code 5] AS VARCHAR(20))) AS 'Insurance Code 5'
	,sum([Insurance 1 Payments]) AS 'Insurance 1 Payments'
	,sum([Insurance 2 Payments]) AS 'Insurance 2 Payments'
	,sum([Insurance 3 Payments]) AS 'Insurance 3 Payments'
	,sum([Insurance 4 Payments]) AS 'Insurance 4 Payments'
	,sum([Insurance 5 Payments]) AS 'Insurance 5 Payments'
	,CASE 
		WHEN [Charge Cvg ID] IS NULL
			THEN 0
		WHEN cast([Charge Cvg ID] AS VARCHAR) = max([Insurance Cvg 1])
			THEN max([Insurance Amount])
		ELSE 0
		END AS 'Insurance Balance 1'
	,CASE 
		WHEN [Charge Cvg ID] IS NULL
			THEN 0
		WHEN cast([Charge Cvg ID] AS VARCHAR) = max([Insurance Cvg 2])
			THEN max([Insurance Amount])
		ELSE 0
		END AS 'Insurance Balance 2'
	,CASE 
		WHEN [Charge Cvg ID] IS NULL
			THEN 0
		WHEN cast([Charge Cvg ID] AS VARCHAR) = max([Insurance Cvg 3])
			THEN max([Insurance Amount])
		ELSE 0
		END AS 'Insurance Balance 3'
	,CASE 
		WHEN [Charge Cvg ID] IS NULL
			THEN 0
		WHEN cast([Charge Cvg ID] AS VARCHAR) = max([Insurance Cvg 4])
			THEN max([Insurance Amount])
		ELSE 0
		END AS 'Insurance Balance 4'
	,CASE 
		WHEN [Charge Cvg ID] IS NULL
			THEN 0
		WHEN cast([Charge Cvg ID] AS VARCHAR) = max([Insurance Cvg 5])
			THEN max([Insurance Amount])
		ELSE 0
		END AS 'Insurance Balance 5'
	,max([Patient Payments]) AS 'Patient Payments'
	,CASE 
		WHEN [Patient Balance] < 0
			THEN min([Patient Balance])
		ELSE max([Patient Balance])
		END AS 'Patient Balance'
	,CASE 
		WHEN [Total Charges] < 0
			THEN min([Total Charges])
		ELSE max([Total Charges])
		END AS 'Total Charges'
	,CASE 
		WHEN [Account Balance] < 0
			THEN min([Account Balance])
		ELSE max([Account Balance])
		END AS 'Account Balance'
	,max([Expected Revenue]) AS 'Expected Revenue'
	,cast([Primary DRG] AS VARCHAR(20)) AS 'Primary DRG'
	,Replace(cast([Patient Representative] AS VARCHAR(20)), ',', ' ') AS 'Patient Representative'
	,cast([Responsibility Code] AS VARCHAR(20)) AS 'Responsibility Code'
	,cast([Physician Code] AS VARCHAR(20)) AS 'Physician Code'
	,max([Financial Class]) AS 'Financial Class'
	,max(cast([Account Plan ID] AS VARCHAR(20))) AS 'Account Plan ID'
FROM (
	SELECT dep2.serv_area_name
		,coalesce((cast(dep2.dept_id as varchar)), '000000000') AS 'Company Code'
		,cast(clarity_tdl_age.tx_id AS VARCHAR) + '-' + cast(clarity_tdl_age.account_id AS VARCHAR) AS 'Account Number'
		,'' AS 'Parent Account Number'
		,'O' AS 'Account Type'
		,patient.pat_mrn_id AS 'Medical Record Number'
		,patient.pat_last_name AS 'Last Name'
		,patient.pat_first_name AS 'First Name'
		,coalesce(patient.pat_middle_name, '') AS 'Middle Initial'
		,patient.birth_date AS 'Birth Date'
		,patient.ssn AS 'Social Security Number'
		,'102' AS 'Patient Type Code'
		,'' AS 'Hospital Service Code'
		,clarity_tdl_age.orig_service_date AS 'Admit Date'
		,clarity_tdl_age.orig_service_date AS 'Discharge Date'
		,(
			SELECT min(arpb_tx_stmclaimhx.bc_hx_date)
			FROM arpb_tx_stmclaimhx
			WHERE arpb_tx_stmclaimhx.tx_id = clarity_tdl_age.tx_id
			) AS 'First Bill Date'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN clarity_epm.financial_class
			WHEN acct_coverage.line = 1
				THEN clarity_epm.financial_class
			ELSE ''
			END AS 'Financial Class Code 1'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN clarity_epm.financial_class
			WHEN acct_coverage.line = 2
				THEN clarity_epm.financial_class
			ELSE ''
			END AS 'Financial Class Code 2'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN clarity_epm.financial_class
			WHEN acct_coverage.line = 3
				THEN clarity_epm.financial_class
			ELSE ''
			END AS 'Financial Class Code 3'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN clarity_epm.financial_class
			WHEN acct_coverage.line = 4
				THEN clarity_epm.financial_class
			ELSE ''
			END AS 'Financial Class Code 4'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN clarity_epm.financial_class
			WHEN acct_coverage.line = 5
				THEN clarity_epm.financial_class
			ELSE ''
			END AS 'Financial Class Code 5'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 1
				THEN cast(coverage_account.plan_id AS VARCHAR)
			ELSE ''
			END AS 'Insurance Code 1'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 2
				THEN cast(coverage_account.plan_id AS VARCHAR)
			ELSE ''
			END AS 'Insurance Code 2'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 3
				THEN cast(coverage_account.plan_id AS VARCHAR)
			ELSE ''
			END AS 'Insurance Code 3'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 4
				THEN cast(coverage_account.plan_id AS VARCHAR)
			ELSE ''
			END AS 'Insurance Code 4'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 5
				THEN cast(coverage_account.plan_id AS VARCHAR)
			ELSE ''
			END AS 'Insurance Code 5'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 1
				THEN cast(coverage_account.COVERAGE_ID AS VARCHAR)
			ELSE ''
			END AS 'Insurance Cvg 1'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 2
				THEN cast(coverage_account.COVERAGE_ID AS VARCHAR)
			ELSE ''
			END AS 'Insurance Cvg 2'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 3
				THEN cast(coverage_account.COVERAGE_ID AS VARCHAR)
			ELSE ''
			END AS 'Insurance Cvg 3'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 4
				THEN cast(coverage_account.COVERAGE_ID AS VARCHAR)
			ELSE ''
			END AS 'Insurance Cvg 4'
		,CASE 
			WHEN clarity_epm.financial_class = 4
				THEN ''
			WHEN acct_coverage.line = 5
				THEN cast(coverage_account.COVERAGE_ID AS VARCHAR)
			ELSE ''
			END AS 'Insurance Cvg 5'
		,CASE 
			WHEN coverage_charges.plan_id IS NULL
				THEN 0
			WHEN acct_coverage.line = 1
				AND arpb_tx_match_hx.MTCH_TX_HX_D_CVG_ID = coverage_account.COVERAGE_ID
				THEN arpb_tx_match_hx.mtch_tx_hx_ins_amt
			ELSE 0
			END AS 'Insurance 1 Payments'
		,CASE 
			WHEN coverage_charges.plan_id IS NULL
				THEN 0
			WHEN acct_coverage.line = 2
				AND arpb_tx_match_hx.MTCH_TX_HX_D_CVG_ID = coverage_account.COVERAGE_ID
				THEN arpb_tx_match_hx.mtch_tx_hx_ins_amt
			ELSE 0
			END AS 'Insurance 2 Payments'
		,CASE 
			WHEN coverage_charges.plan_id IS NULL
				THEN 0
			WHEN acct_coverage.line = 3
				AND arpb_tx_match_hx.MTCH_TX_HX_D_CVG_ID = coverage_account.COVERAGE_ID
				THEN arpb_tx_match_hx.mtch_tx_hx_ins_amt
			ELSE 0
			END AS 'Insurance 3 Payments'
		,CASE 
			WHEN coverage_charges.COVERAGE_ID IS NULL
				THEN 0
			WHEN acct_coverage.line = 4
				AND arpb_tx_match_hx.MTCH_TX_HX_D_CVG_ID = coverage_account.COVERAGE_ID
				THEN arpb_tx_match_hx.mtch_tx_hx_ins_amt
			ELSE 0
			END AS 'Insurance 4 Payments'
		,CASE 
			WHEN coverage_charges.COVERAGE_ID IS NULL
				THEN 0
			WHEN acct_coverage.line = 5
				AND arpb_tx_match_hx.MTCH_TX_HX_D_CVG_ID = coverage_account.COVERAGE_ID
				THEN arpb_tx_match_hx.mtch_tx_hx_ins_amt
			ELSE 0
			END AS 'Insurance 5 Payments'
		,coalesce(arpb_tx_match_hx.mtch_tx_hx_pat_amt, 0) AS 'Patient Payments'
		,clarity_tdl_age.patient_amount AS 'Patient Balance'
		,clarity_tdl_age.orig_price AS 'Total Charges'
		,clarity_tdl_age.amount AS 'Account Balance'
		,'' AS 'Expected Revenue'
		,'' AS 'Primary DRG'
		,account.account_name AS 'Patient Representative'
		,'' AS 'Responsibility Code'
		,clarity_tdl_age.billing_provider_id AS 'Physician Code'
		,coverage_charges.plan_id AS 'Charge Plan ID'
		,coverage_charges.COVERAGE_ID AS 'Charge Cvg ID'
		,coverage_account.plan_id AS 'Account Plan ID'
		,clarity_tdl_age.insurance_amount AS 'Insurance Amount'
		,clarity_epm.financial_class AS 'Financial Class'
	FROM clarity_tdl_age clarity_tdl_age WITH (NOLOCK)
	LEFT JOIN arpb_tx_match_hx WITH (NOLOCK) ON clarity_tdl_age.tx_id = arpb_tx_match_hx.mtch_tx_hx_id
	LEFT JOIN account WITH (NOLOCK) ON clarity_tdl_age.account_id = account.account_id
	LEFT JOIN acct_coverage WITH (NOLOCK) ON account.account_id = acct_coverage.account_id
	LEFT JOIN coverage coverage_account WITH (NOLOCK) ON acct_coverage.coverage_id = coverage_account.coverage_id
	LEFT JOIN clarity_epm WITH (NOLOCK) ON coverage_account.payor_id = clarity_epm.payor_id
	LEFT JOIN patient WITH (NOLOCK) ON clarity_tdl_age.int_pat_id = patient.pat_id
	LEFT JOIN coverage coverage_charges WITH (NOLOCK) ON clarity_tdl_age.ORIGINAL_CVG_ID = coverage_charges.coverage_id
	LEFT JOIN clarity_dep dep on dep.department_id = clarity_tdl_age.dept_id
	LEFT JOIN claritychputil.rpt.v_pb_department dep2 on dep2.dept_id = dep.rpt_grp_one
	WHERE clarity_tdl_age.serv_area_id in (11,13,16,17,18,19)
		AND post_date = @end_date
		) a

		where [Account Balance] <> 0
		and [Account Number] is not null

	GROUP BY [Company Code]
		,[Account Number]
		,[Parent Account Number]
		,[Account Type]
		,[Medical Record Number]
		,[Last Name]
		,[First Name]
		,[Middle Initial]
		,[Birth Date]
		,[Social Security Number]
		,[Patient Type Code]
		,[Hospital Service Code]
		,[Admit Date]
		,[Discharge Date]
		,[First Bill Date]
		,[Patient Balance]
		,[Account Balance]
		,[Total Charges]
		,[Primary DRG]
		,[Patient Representative]
		,[Responsibility Code]
		,[Physician Code]
		,[Charge Cvg ID]
ORDER BY [account number]

