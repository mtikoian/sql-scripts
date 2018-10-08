--declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select distinct 

 arpb_tx.tx_id as Encounter_Record_Number 
,edg.ref_bill_code as ICD10_Diagnosis_Code
 ,tdx.line as Sequence_Number
,'Epic' as Source_System

from ARPB_TRANSACTIONS arpb_tx
inner join V_ARPB_CODING_DX tdx on arpb_tx.tx_id=tdx.tx_id and tdx.line = '1'
inner join clarity_edg edg on tdx.dx_id=edg.dx_id and edg.REF_BILL_CODE_SET_C= '2' --1	ICD-9-CM
left join clarity_tdl_tran tdl on tdl.tx_id = arpb_tx.tx_id
left join clarity_dep dep on dep.department_id = tdl.dept_id

where arpb_tx.SERVICE_DATE >= @start_date
	and arpb_tx.SERVICE_DATE <= @end_date
	and arpb_tx.tx_type_c = '1'  -- limiting encounters to those generating a charge on Service Date in timeframe
	and tdl.detail_type = 1
	and arpb_tx.service_area_id in (11,13,16,17,18,19)

order by arpb_tx.tx_id
