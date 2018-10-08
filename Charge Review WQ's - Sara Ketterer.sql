/*Need report of all charges currently in Charge Review WQs (need charge lines not charge sessions though (UCLs not TARs)) 
for service area 21-Healthspan with Place of Service (POS) HSP Lorain Lab, HSP ARUP Lab, HSP Parma Lab, and HSP Clhts Lab from 2/20/2015 - 
Present where the financial class is Medicare, Medicaid, Medicare Managed, Managed Medicaid or the payor is HSIC Medicare Cost, 
HSIC Medicare CostXX, or HSIC Medicare Advantage.  

Need the report to include the following:  Patient MRN, Patient Name, Date of Service, DOB, Patient Address, City, State & Zip,
 Billing Provider, Diagnosis Codes, Procedure Code, Procedure Description, Procedure Amount, Payor Name, Payor Address, Payor City, 
 Payor State, Payor Zip, Subscriber ID, Subscriber Name, Subscriber Group#.

If it easier to run all payors, I can filter by those I need, I would just need additional column of Financial Class within the report.

This is being requested as URGENT as this needs to be reported to Finance by the end of the year and is being treated as a Compliance issue.  

*Updated 1/25/15
Added CHG_REVIEW_MODS
Updted 2/10/16
Added Referring Prov ID
Row Count 143243
*/

select
	pac.tar_id as 'Tar ID'
	,charge_line as 'Charge Line'
	,stat.name as 'Charge Status'
	,sa.serv_area_id
	,sa.serv_area_name
	,pos.pos_id
	,pos.pos_name
	,pat.pat_mrn_id as 'Patient MRN'
	,pat.pat_name as 'Patient Name'
	,pac.service_date as 'Date of Service'
	,pat.birth_date as 'DOB'
	,pat.add_line_1 as 'Address 1'
	,pat.add_line_2 as 'Address 2'
	,pat.city as 'City'
	,state.name as 'State'
	,pat.zip as 'Zip'
	,ser.prov_id as 'Billing Provider ID'
	,ser.prov_name as 'Billing Provider Name'
	,ref.prov_id as 'Referring Provider ID'
	,ref.prov_name as 'Referring Provider Name'
	,edg.dx_id as 'Diagnosis Code'
	,edg.icd9_code as 'ICD Code'
	,edg.dx_name as 'Diagnosis Descriptionhe act'
	,eap.proc_code as 'Procedure Code'
	,eap.proc_name as 'Procedure Description'
	,amount as 'Procedure Amount'
	,fin.financial_claSS as 'Financial Class ID'
	,fin.name as 'Financial Class Name'
	,epm.payor_id as 'Payor ID'
	,epm.payor_name as 'Payor Name' 
	,epm.addr_line_1 as 'Payor Address 1'
	,epm.addr_line_2 as 'Payor Address 2'
	,epm.city as 'Payor City'
	,epm_state.name as 'Payor State'
	,epm.zip_code as 'Payor Zip'
	,cov.subscr_num as 'Subscriber ID'
	,cov.subscr_name as 'Subscriber Name'
	,cov.group_num as 'Group Number'
	,ext_modifier
	,int_modifier_id


from pre_ar_chg pac
left join clarity_pos pos on pac.proc_pos_id = pos.pos_id
left join patient pat on pac.pat_id = pat.pat_id
left join zc_state state on pat.state_c = state.state_c
left join clarity_ser ser on pac.bill_prov_id = prov_id
left join clarity_eap eap on pac.proc_id = eap.proc_id
left join clarity_epm epm on pac.payor_id = epm.payor_id
left join zc_financial_class fin on pac.fin_class_c = fin.financial_class
left join zc_state epm_state on epm.state_c = epm_state.state_c
left join zc_charge_status stat on pac.charge_status_c = stat.charge_status_c
left join clarity_sa sa on sa.serv_area_id = pac.serv_area_id
left join chg_review_dx crd on crd.tar_id = pac.tar_id and crd.line = pac.charge_line
left join (

select dx_id, dx_name, icd9_code
from clarity_edg
where icd9_code is not null
union 
SELECT dx_id, dx_name, ref_bill_code
FROM   "Clarity"."dbo"."CLARITY_EDG" "CLARITY_EDG" 
LEFT OUTER JOIN ZC_EDG_CODE_SET ZEDGC ON ZEDGC.EDG_CODE_SET_C = CLARITY_EDG.REF_BILL_CODE_SET_C
where ref_bill_code_set_c  = 2
)edg on crd.dx_id = edg.dx_id

left join coverage cov on pac.coverage_id = cov.coverage_id
left join chg_review_mods mods on pac.tar_id = mods.tar_id and pac.charge_line = mods.line_count
left join clarity_ser ref on pac.referring_prov_id = ref.prov_id

where pac.serv_area_id = 21
and pos_name in ('HSP LORAIN LAB','HSP ARUP LAB', 'HSP Parm Lab', 'HSP CLHTS Lab')
and service_date >= '2016-01-01 00:00:00'
and service_date <= '2016-03-31 00:00:00'
and (fin.name in ('Medicare','Medicare Managed', 'Medicaid', 'Medicaid Managed')
or payor_name in ( 'HSIC MEDICARE COST', 'HSIC Medicare CostXX', 'HSIC Medicare Advantage'))
and stat.charge_status_c = 3 --IN REVIEW

order by pat_mrn_id, service_date, charge_line