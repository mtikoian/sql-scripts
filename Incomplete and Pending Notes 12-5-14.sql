SELECT "hno_info"."note_id",
       "note_enc_info"."contact_serial_num",
       "note_enc_info"."note_status_c",
	   "pat_enc"."primary_loc_id",
	   "hno_info"."pat_enc_csn_id",
	   "pat_enc"."pat_enc_csn_id",
       "zc_note_status"."name", 
       "hno_info"."ip_note_type_c", 
       "zc_note_type_ip"."name", 
       "CLARITY_EMP_AUTHOR"."name", 
       "CLARITY_EMP_USER"."name", 
       "pat_enc_2"."bill_num", 
       "pat_enc"."contact_date", 
       "patient"."pat_name", 
       "note_enc_info"."spec_note_time_dttm", 
       "clarity_sa"."serv_area_name" 
	   
FROM   "Clarity"."dbo"."hno_info" "HNO_INFO" 
       INNER JOIN "Clarity"."dbo"."note_enc_info" "NOTE_ENC_INFO" ON "hno_info"."note_id" = "note_enc_info"."note_id"  
	   LEFT OUTER JOIN "Clarity"."dbo"."pat_enc" "PAT_ENC" ON "hno_info"."pat_enc_csn_id" = "pat_enc"."pat_enc_csn_id" 
       LEFT OUTER JOIN "Clarity"."dbo"."zc_note_type_ip" "ZC_NOTE_TYPE_IP" ON "hno_info"."ip_note_type_c" = "zc_note_type_ip"."type_ip_c"
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_emp" "CLARITY_EMP_USER" ON "hno_info"."current_author_id" = "CLARITY_EMP_USER"."user_id"
       LEFT OUTER JOIN "Clarity"."dbo"."patient" "PATIENT" ON "hno_info"."pat_id" = "patient"."pat_id"
	   INNER JOIN "Clarity"."dbo"."clarity_dep" "CLARITY_DEP" ON "pat_enc"."department_id" = "clarity_dep"."department_id"
       INNER JOIN "Clarity"."dbo"."clarity_loc" "CLARITY_LOC" ON "pat_enc"."primary_loc_id" = "clarity_loc"."loc_id"
       LEFT OUTER JOIN "Clarity"."dbo"."pat_enc_2" "PAT_ENC_2" ON "pat_enc"."pat_enc_csn_id" = "pat_enc_2"."pat_enc_csn_id"
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_sa" "CLARITY_SA" ON "clarity_loc"."serv_area_id" = "clarity_sa"."serv_area_id"
       LEFT OUTER JOIN "Clarity"."dbo"."zc_note_status" "ZC_NOTE_STATUS" ON "note_enc_info"."note_status_c" = "zc_note_status"."note_status_c"
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_emp" "CLARITY_EMP_AUTHOR" ON "note_enc_info"."author_user_id" = "CLARITY_EMP_AUTHOR"."user_id" 
WHERE  "pat_enc"."primary_loc_id" = 13102 
	   AND "PAT_ENC".PAT_ENC_CSN_ID = '33097649'
	   AND ( "note_enc_info"."note_status_c" = '1' OR "note_enc_info"."note_status_c" = '10' OR "note_enc_info"."note_status_c" = '12' ) 
ORDER  BY "hno_info"."note_id" 