SELECT "clarity_tdl_tran"."account_id", 
       "clarity_tdl_tran"."charge_slip_number", 
       "clarity_eap"."proc_code", 
       "clarity_eap"."proc_name", 
       "CLARITY_EAP_Match"."proc_code", 
       "CLARITY_EAP_Match"."proc_name", 
       "clarity_tdl_tran"."amount", 
       "clarity_tdl_tran"."post_date", 
       "clarity_tdl_tran"."orig_service_date", 
       "clarity_tdl_tran"."serv_area_id", 
       "clarity_tdl_tran"."detail_type", 
       "arpb_transactions"."outstanding_amt", 
       "clarity_sa"."serv_area_name", 
       "clarity_tdl_tran"."loc_id" 
FROM   ((("Clarity"."dbo"."clarity_tdl_tran" "CLARITY_TDL_TRAN" 
          LEFT OUTER JOIN "Clarity"."dbo"."clarity_eap" "CLARITY_EAP" 
                       ON 
"clarity_tdl_tran"."proc_id" = "clarity_eap"."proc_id") 
         LEFT OUTER JOIN "Clarity"."dbo"."clarity_eap" "CLARITY_EAP_Match" 
                      ON "clarity_tdl_tran"."match_proc_id" = 
                         "CLARITY_EAP_Match"."proc_id") 
        LEFT OUTER JOIN "Clarity"."dbo"."arpb_transactions" "ARPB_TRANSACTIONS" 
                     ON 
"clarity_tdl_tran"."tx_id" = "arpb_transactions"."tx_id") 
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_sa" "CLARITY_SA" 
                    ON "clarity_tdl_tran"."serv_area_id" = 
                       "clarity_sa"."serv_area_id" 
WHERE  "clarity_tdl_tran"."serv_area_id" = 17 
       AND "clarity_tdl_tran"."orig_service_date" < {ts '2013-04-01 00:00:00'} 
       AND ( "clarity_tdl_tran"."post_date" >= {ts '2013-04-01 00:00:00'} 
             AND "clarity_tdl_tran"."post_date" < {ts '2014-10-01 00:00:00'} ) 
       AND ( "CLARITY_EAP_Match"."proc_code" = '5017' 
              OR "CLARITY_EAP_Match"."proc_code" = '6002' ) 
       AND "arpb_transactions"."outstanding_amt" = 0 
       AND ( "clarity_eap"."proc_code" = '5002' 
              OR "clarity_eap"."proc_code" = '5017' 
              OR "clarity_eap"."proc_code" = '6002' ) 
       AND "clarity_tdl_tran"."account_id" = 1765983 
ORDER  BY "clarity_tdl_tran"."loc_id" 