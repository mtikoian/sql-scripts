SELECT "clarity_loc"."loc_id", 
       "clarity_loc"."loc_name", 
       "clarity_pos"."pos_id", 
       "clarity_pos"."pos_name", 
       "clarity_sa"."serv_area_id", 
       "clarity_sa"."serv_area_name", 
       "clarity_dep"."department_id", 
       "clarity_dep"."department_name", 
       "clarity_dep"."specialty", 
       "CLARITY_SER_BILLING"."prov_id", 
       "CLARITY_SER_BILLING"."prov_name", 
       "clarity_tdl_tran"."detail_type", 
       "clarity_tdl_tran"."post_date", 
       "clarity_tdl_tran"."serv_area_id", 
       "clarity_tdl_tran"."loc_id", 
       "clarity_tdl_tran"."pos_id", 
       "clarity_tdl_tran"."dept_id", 
       "clarity_tdl_tran"."billing_provider_id", 
       "clarity_tdl_tran"."performing_prov_id", 
       "clarity_tdl_tran"."amount", 
       "clarity_tdl_tran"."tx_id", 
       "clarity_eap"."gl_num_debit", 
       "CLARITY_EAP_MATCH"."gl_num_debit", 
       "clarity_eap"."gl_num_credit", 
       "clarity_tdl_tran"."credit_gl_num", 
       "clarity_tdl_tran"."debit_gl_num", 
       "CLARITY_EAP_MATCH"."gl_num_credit", 
       "clarity_tdl_tran"."patient_amount", 
       "clarity_tdl_tran"."insurance_amount", 
       "clarity_tdl_tran"."original_fin_class", 
       "zc_orig_fin_class"."name", 
       "clarity_tdl_tran"."orig_service_date", 
       "clarity_dep"."gl_prefix", 
       "clarity_eap"."proc_id", 
       "clarity_eap"."proc_name", 
       "clarity_eap"."proc_code", 
       "clarity_loc"."gl_prefix", 
       "clarity_tdl_tran"."posting_batch_num", 
       "clarity_epm"."payor_name", 
       "clarity_tdl_tran"."original_payor_id" 
FROM   (((((((("Clarity"."dbo"."clarity_tdl_tran" "CLARITY_TDL_TRAN" 
               LEFT OUTER JOIN "Clarity"."dbo"."clarity_dep" "CLARITY_DEP" 
                            ON 
           "clarity_tdl_tran"."dept_id" = "clarity_dep"."department_id") 
              LEFT OUTER JOIN "Clarity"."dbo"."clarity_loc" "CLARITY_LOC" 
                           ON "clarity_tdl_tran"."loc_id" = 
                              "clarity_loc"."loc_id") 
             LEFT OUTER JOIN "Clarity"."dbo"."clarity_sa" "CLARITY_SA" 
                          ON "clarity_tdl_tran"."serv_area_id" = 
                             "clarity_sa"."serv_area_id") 
            LEFT OUTER JOIN "Clarity"."dbo"."clarity_ser" "CLARITY_SER_BILLING" 
                         ON 
            "clarity_tdl_tran"."billing_provider_id" = 
            "CLARITY_SER_BILLING"."prov_id") 
           LEFT OUTER JOIN "Clarity"."dbo"."clarity_eap" "CLARITY_EAP" 
                        ON "clarity_tdl_tran"."proc_id" = 
                           "clarity_eap"."proc_id") 
          LEFT OUTER JOIN "Clarity"."dbo"."clarity_pos" "CLARITY_POS" 
                       ON "clarity_tdl_tran"."pos_id" = "clarity_pos"."pos_id") 
         LEFT OUTER JOIN "Clarity"."dbo"."clarity_eap" "CLARITY_EAP_MATCH" 
                      ON "clarity_tdl_tran"."match_proc_id" = 
                         "CLARITY_EAP_MATCH"."proc_id") 
        LEFT OUTER JOIN "Clarity"."dbo"."zc_orig_fin_class" "ZC_ORIG_FIN_CLASS" 
                     ON "clarity_tdl_tran"."original_fin_class" = 
                        "zc_orig_fin_class"."original_fin_class") 
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_epm" "CLARITY_EPM" 
                    ON "clarity_tdl_tran"."original_payor_id" = 
                       "clarity_epm"."payor_id" 
WHERE  "clarity_tdl_tran"."serv_area_id" IS NOT NULL 
       AND "clarity_tdl_tran"."serv_area_id" = 11 
       AND ( "clarity_tdl_tran"."post_date" >= {ts '2014-01-01 00:00:00'} 
             AND "clarity_tdl_tran"."post_date" < {ts '2014-10-03 00:00:00'} ) 
       AND ( "clarity_tdl_tran"."detail_type" = 1 
              OR "clarity_tdl_tran"."detail_type" = 2 
              OR "clarity_tdl_tran"."detail_type" = 3 
              OR "clarity_tdl_tran"."detail_type" = 4 
              OR "clarity_tdl_tran"."detail_type" = 5 
              OR "clarity_tdl_tran"."detail_type" = 6 
              OR "clarity_tdl_tran"."detail_type" = 10 
              OR "clarity_tdl_tran"."detail_type" = 11 
              OR "clarity_tdl_tran"."detail_type" = 12 
              OR "clarity_tdl_tran"."detail_type" = 13 
              OR "clarity_tdl_tran"."detail_type" = 20 
              OR "clarity_tdl_tran"."detail_type" = 21 
              OR "clarity_tdl_tran"."detail_type" = 22 
              OR "clarity_tdl_tran"."detail_type" = 23 
              OR "clarity_tdl_tran"."detail_type" = 30 
              OR "clarity_tdl_tran"."detail_type" = 31 
              OR "clarity_tdl_tran"."detail_type" = 32 
              OR "clarity_tdl_tran"."detail_type" = 33 ) 
        and "clarity_loc"."loc_id" not like '11%'