select 
 tdl.invoice_number 'INVOICE_NUMBER'
,tdl.tx_id 'TRANSACTION_ID'
,cast(tdl.orig_service_date as date) 'SERVICE_DATE'
,epm.payor_name 'PAYOR'
,coalesce(edg1.current_icd10_list,'') +
 case when edg2.current_icd10_list is null then '' else ', ' + coalesce(edg2.current_icd10_list,'') +
 case when edg3.current_icd10_list is null then '' else ', ' + coalesce(edg3.current_icd10_list,'') + 
 case when edg4.current_icd10_list is null then '' else ', ' + coalesce(edg4.current_icd10_list,'') +
 case when edg5.current_icd10_list is null then '' else ', ' + coalesce(edg5.current_icd10_list,'') +
 case when edg6.current_icd10_list is null then '' else ', ' + coalesce(edg6.current_icd10_list,'') end end end end end as 'CURRENT_ICD10_CODE'
--,edg1.current_icd10_list as 'ICD_CODE_1'
--,edg2.current_icd10_list as 'ICD_CODE_2'
--,edg3.current_icd10_list as 'ICD_CODE_3'
--,edg4.current_icd10_list as 'ICD_CODE_4'
--,edg5.current_icd10_list as 'ICD_CODE_5'
--,edg6.current_icd10_list as 'ICD_CODE_6'
,tdl.bill_claim_amount 'BILL_CLAIM_AMOUNT'
,pat.pat_name 'PATIENT_NAME'
,pat.add_line_1 'ADD_LINE_1'
,coalesce(pat.add_line_2,'') 'ADD_LINE_2'
,pat.city 'CITY'
,state.abbr 'STATE'
,pat.zip 'ZIP'
,cast(pat.birth_date as date) 'DOB'

from 
clarity_tdl_tran tdl
left join clarity_epm epm on epm.payor_id = tdl.original_payor_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_edg edg1 on edg1.dx_id = tdl.dx_one_id
left join clarity_edg edg2 on edg2.dx_id = tdl.dx_two_id
left join clarity_edg edg3 on edg3.dx_id = tdl.dx_three_id
left join clarity_edg edg4 on edg4.dx_id = tdl.dx_four_id
left join clarity_edg edg5 on edg5.dx_id = tdl.dx_five_id
left join clarity_edg edg6 on edg6.dx_id = tdl.dx_six_id
left join zc_state state on state.state_c = pat.state_c

where detail_type = 50 -- insurance claim
and orig_service_date >= '9/1/2017'
and original_payor_id = '1010'

order by tdl.invoice_number