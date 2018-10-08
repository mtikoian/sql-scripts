--proc code, proc name, department, name, ordering date, authorizing, service are tdl tran
SELECT 
	pat_enc.serv_area_id
	,serv_area_name
	,effective_dept_id
	,department_name
	,clarity_ser.prov_id
	,"CLARITY_SER"."PROV_NAME"
	,"PAT_ENC"."PAT_ENC_CSN_ID"
	,"PATIENT"."PAT_NAME"
	,"PATIENT"."BIRTH_DATE"
	,order_proc.proc_code
	,"ORDER_PROC"."PROC_BGN_TIME"
	,"ORDER_PROC"."DESCRIPTION"


FROM "Clarity"."dbo"."PATIENT" "PATIENT"
LEFT OUTER JOIN "Clarity"."dbo"."ORDER_PROC" "ORDER_PROC" ON "PATIENT"."PAT_ID" = "ORDER_PROC"."PAT_ID"
LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_SER" "CLARITY_SER" ON "ORDER_PROC"."AUTHRZING_PROV_ID" = "CLARITY_SER"."PROV_ID"
LEFT OUTER JOIN "Clarity"."dbo"."PAT_ENC" "PAT_ENC" ON "ORDER_PROC"."PAT_ENC_CSN_ID" = "PAT_ENC"."PAT_ENC_CSN_ID"
left outer join clarity_dep dep on pat_enc.effective_dept_id = dep.department_id
left outer join clarity_sa sa on pat_enc.serv_area_id = sa.serv_area_id
WHERE "CLARITY_SER"."PROV_ID" = '1000645'
	AND "ORDER_PROC"."PROC_BGN_TIME" >= {ts '2015-01-01 00:00:00' }
	AND "ORDER_PROC"."PROC_BGN_TIME" < {ts '2015-12-31 00:00:01' }
	and pat_enc.serv_area_id = 11
ORDER BY "PATIENT"."PAT_NAME"

