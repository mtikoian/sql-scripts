select 
	tdl.pat_enc_csn_id as 'Encounter_Number', 
	pat_mrn_id as 'Patient_Record_Number', 
	pat_name as 'Patient_Name', 
	pat.birth_date as 'Date_of_Birth', 
	orig_service_date as 'Date_of_Service', 
    npi.identity_id as 'Billing_Physician_NPI#', 
	ser.prov_id as 'Billing_Provider_ID',
	ser.prov_name as 'Billing_Physician Name',
	tdl.cpt_code as 'CPT_Code',
	tdl.modifier_one as 'Modifier_One',
	tdl.modifier_two as 'Modifier_Two',
	tdl.modifier_three as 'Modifier_Three',
	tdl.modifier_four as 'Modifier_Four',
	tdl.procedure_quantity as 'CPT_Code_Quantity',
	tdl.amount as 'Amount',
	fin.name as 'Current_Financial_Class'
	--Primary Inusurance Code?

from
	clarity_tdl_tran tdl 
	left join patient pat on pat.pat_id = tdl.int_pat_id
	left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
	left join identity_ser_id npi on ser.prov_id = npi.prov_id
	left join zc_cur_fin_class fin on fin.cur_fin_class = tdl.cur_fin_class


where
	ORIG_SERVICE_DATE >= '2014-08-01 00:00:00'
	and ORIG_SERVICE_DATE <= '2014-11-30 00:00:00'
	and detail_type in (1)
	and identity_type_id = '100001' --100001 represents NPI#'s
	and ser.prov_id = '1605102'
