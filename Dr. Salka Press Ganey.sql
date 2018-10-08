SELECT "patient"."add_line_1", 
       "patient"."add_line_2", 
       "patient"."city", 
       "patient"."zip", 
       "patient"."birth_date", 
       "patient"."email_address", 
       "zc_specialty_dep"."name", 
       "pat_enc_appt"."contact_date", 
       "clarity_ser"."prov_name", 
       "clarity_ser"."prov_id", 
       "patient"."pat_mrn_id", 
       "clarity_epm"."payor_name", 
       "pat_enc_appt"."pat_enc_csn_id", 
       "patient"."home_phone", 
       "patient"."pat_middle_name", 
       "patient"."pat_first_name", 
       "patient"."pat_last_name", 
       "clarity_ser"."prov_type", 
       "zc_state"."abbr", 
       "zc_sex"."abbr", 
       "pat_enc"."serv_area_id", 
       "clarity_ser"."doctors_degree", 
       "clarity_dep"."department_name", 
       "clarity_dep"."department_id", 
       "clarity_dep"."rev_loc_id", 
       "pat_enc"."enc_type_c", 
       "patient"."pat_id",
	   "clarity_ser"."prov_id"
FROM   ((((((("Clarity"."dbo"."pat_enc_appt" "PAT_ENC_APPT" 
              INNER JOIN "Clarity"."dbo"."pat_enc" "PAT_ENC" 
                      ON "pat_enc_appt"."pat_enc_csn_id" = 
                         "pat_enc"."pat_enc_csn_id") 
             RIGHT OUTER JOIN "Clarity"."dbo"."patient" "PATIENT" 
                           ON "pat_enc_appt"."pat_id" = "patient"."pat_id") 
            LEFT OUTER JOIN "Clarity"."dbo"."clarity_dep" "CLARITY_DEP" 
                         ON 
          "pat_enc_appt"."department_id" = "clarity_dep"."department_id") 
           LEFT OUTER JOIN "Clarity"."dbo"."clarity_ser" "CLARITY_SER" 
                        ON "pat_enc_appt"."prov_id" = "clarity_ser"."prov_id") 
          LEFT OUTER JOIN "Clarity"."dbo"."zc_specialty_dep" "ZC_SPECIALTY_DEP" 
                       ON "clarity_dep"."specialty_dep_c" = 
                          "zc_specialty_dep"."specialty_dep_c") 
         LEFT OUTER JOIN "Clarity"."dbo"."clarity_epm" "CLARITY_EPM" 
                      ON "patient"."prim_epm_id" = "clarity_epm"."payor_id") 
        LEFT OUTER JOIN "Clarity"."dbo"."zc_state" "ZC_STATE" 
                     ON "patient"."state_c" = "zc_state"."state_c") 
       LEFT OUTER JOIN "Clarity"."dbo"."zc_sex" "ZC_SEX" 
                    ON "patient"."sex_c" = "zc_sex"."rcpt_mem_sex_c" 
WHERE  --"pat_enc"."enc_type_c" = '101' 
         -- OR "pat_enc"."enc_type_c" = '108' 
         --OR "pat_enc"."enc_type_c" = '1200' 
        -- OR "pat_enc"."enc_type_c" = '2' ) 
        ( "clarity_ser"."prov_type" = 'Certfied Nurse Midwife' 
              OR "clarity_ser"."prov_type" = 'Nurse Practitioner' 
              OR "clarity_ser"."prov_type" = 'Physician' 
              OR "clarity_ser"."prov_type" = 'Physician Assistant' 
              OR "clarity_ser"."prov_type" = 'Resident' ) 
       AND ( "pat_enc_appt"."contact_date" >= {ts '2014-10-01 00:00:00'} 
             AND "pat_enc_appt"."contact_date" < {ts '2014-11-24 00:00:00'} ) 
	and "clarity_ser"."prov_id" = '3056386'
	and enc_type_c = 50
ORDER  BY "pat_enc_appt"."pat_enc_csn_id" 