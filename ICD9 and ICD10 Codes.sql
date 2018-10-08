select dx_id, dx_name, icd9_code
from clarity_edg
where icd9_code is not null

union 

SELECT dx_id, dx_name, ref_bill_code
FROM   "Clarity"."dbo"."CLARITY_EDG" "CLARITY_EDG" 
LEFT OUTER JOIN ZC_EDG_CODE_SET ZEDGC ON ZEDGC.EDG_CODE_SET_C = CLARITY_EDG.REF_BILL_CODE_SET_C
where ref_bill_code_set_c  = 2
