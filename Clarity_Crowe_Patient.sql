declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('t-1')
declare @sa as integer = 16


select
[Company Code]
,[Account Number]
,[Admit Date]
,[Discharge Date]
,max([Payor Code 1]) as 'Payor Code 1'
,max([Payor Code 2]) as 'Payor Code 2'
,max([Payor Code 3]) as 'Payor Code 3'
,max([Payor Code 4]) as 'Payor Code 4'
,max([Payor Code 5]) as 'Payor Code 5'
,[Total Charges]

from 

(
SELECT 
	 arpb_transactions_charges.department_id AS 'Company Code'
	,cast(arpb_transactions_charges.tx_id AS VARCHAR) + '-' + cast(arpb_transactions_charges.account_id AS VARCHAR) AS 'Account Number'
	,arpb_transactions_charges.service_date as 'Admit Date'
	,arpb_transactions_charges.service_date as 'Discharge Date'
	,CASE 
			WHEN arpb_transactions_charges.original_fc_c is not null and arpb_transactions_charges.original_fc_c = 4
				THEN ''
			WHEN pat_cvg_file_order.filing_order is not null and pat_cvg_file_order.filing_order = 1
			    THEN cast(v_coverage_payor_plan.benefit_plan_id AS VARCHAR)
			ELSE ''
			END AS 'Payor Code 1'
	,CASE 
			WHEN arpb_transactions_charges.original_fc_c is not null and arpb_transactions_charges.original_fc_c = 4
				THEN ''
			WHEN pat_cvg_file_order.filing_order is not null and pat_cvg_file_order.filing_order = 2
			    THEN cast(v_coverage_payor_plan.benefit_plan_id AS VARCHAR)
			ELSE ''
			END AS 'Payor Code 2'
	,CASE 
			WHEN arpb_transactions_charges.original_fc_c is not null and arpb_transactions_charges.original_fc_c = 4
				THEN ''
			WHEN pat_cvg_file_order.filing_order is not null and pat_cvg_file_order.filing_order = 3
			    THEN cast(v_coverage_payor_plan.benefit_plan_id AS VARCHAR)
			ELSE ''
			END AS 'Payor Code 3'
	,CASE 
			WHEN arpb_transactions_charges.original_fc_c is not null and arpb_transactions_charges.original_fc_c = 4
				THEN ''
			WHEN pat_cvg_file_order.filing_order is not null and pat_cvg_file_order.filing_order = 4
			    THEN cast(v_coverage_payor_plan.benefit_plan_id AS VARCHAR)
			ELSE ''
			END AS 'Payor Code 4'
	,CASE 
			WHEN arpb_transactions_charges.original_fc_c is not null and arpb_transactions_charges.original_fc_c = 4
				THEN ''
			WHEN pat_cvg_file_order.filing_order is not null and pat_cvg_file_order.filing_order = 5
			    THEN cast(v_coverage_payor_plan.benefit_plan_id AS VARCHAR)
			ELSE ''
			END AS 'Payor Code 5'
	,arpb_transactions_charges.amount as 'Total Charges'

FROM 
arpb_transactions arpb_transactions_charges with (nolock)
left join pat_cvg_file_order with (nolock) on arpb_transactions_charges.patient_id = pat_cvg_file_order.pat_id
left join v_coverage_payor_plan with (nolock) on pat_cvg_file_order.coverage_id = v_coverage_payor_plan.coverage_id

WHERE
arpb_transactions_charges.service_date >= @start_date
and arpb_transactions_charges.service_date < @end_date
and arpb_transactions_charges.service_area_id in (@sa)
and arpb_transactions_charges.tx_type_c =1 
)a

group by 
[Company Code]
,[Account Number]
,[Admit Date]
,[Discharge Date]
,[Total Charges]

order by [Company Code], [Account Number]


