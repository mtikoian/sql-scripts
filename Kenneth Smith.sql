
SELECT "CLARITY_SER_SERVICE"."prov_name" as Performing_Provider, 	
       "clarity_tdl_tran"."performing_prov_id", 	
	   "CLARITY_SER_BILLING"."prov_name"  as Billing_Provider,
       "CLARITY_SER_BILLING"."prov_id", 	
	   "clarity_tdl_tran"."period" ,
	   pat_mrn_id,
	   clarity_tdl_tran.orig_service_date,
       "zc_fin_class"."name" as Financial_Class,	
	   "CLARITY_TDL_TRAN".tx_id,
	  case when detail_type in (1,10) then sum(amount) else 0 end as Charges,
	  case when detail_type in (2,5,11,20,22,32,33) then sum(patient_amount) else 0 end as Patient_Payments,
	   case when detail_type in (2,5,11,20,22,32,33) then sum(insurance_amount) else 0 end as Insurance_Payments,
	  case when detail_type in (2,5,11,20,22,32,33) then sum(amount) else 0 end as Payments,
	   detail_type,
	   pos.pos_name as Place_of_Service,
	   stat.title
FROM   ((((((("Clarity"."dbo"."clarity_tdl_tran" "CLARITY_TDL_TRAN" 	
              LEFT OUTER JOIN "Clarity"."dbo"."clarity_dep" "CLARITY_DEP" 	
                           ON 	
          "clarity_tdl_tran"."dept_id" = "clarity_dep"."department_id") 	
             LEFT OUTER JOIN "Clarity"."dbo"."clarity_eap" "CLARITY_EAP" 	
                          ON "clarity_tdl_tran"."proc_id" = 	
                             "clarity_eap"."proc_id") 	
            LEFT OUTER JOIN "Clarity"."dbo"."clarity_loc" "CLARITY_LOC" 	
                         ON 	
clarity_tdl_tran."loc_id" = "clarity_loc"."loc_id") 	
           LEFT OUTER JOIN "Clarity"."dbo"."clarity_sa" "CLARITY_SA" 	
                        ON "clarity_tdl_tran"."serv_area_id" = 	
                           "clarity_sa"."serv_area_id") 	
          LEFT OUTER JOIN "Clarity"."dbo"."clarity_ser" "CLARITY_SER_BILLING" 	
                       ON 	
          "clarity_tdl_tran"."billing_provider_id" = 	
          "CLARITY_SER_BILLING"."prov_id") 	
         LEFT OUTER JOIN "Clarity"."dbo"."clarity_ser" "CLARITY_SER_SERVICE" 	
                      ON "clarity_tdl_tran"."performing_prov_id" = 	
                         "CLARITY_SER_SERVICE"."prov_id") 	
        LEFT OUTER JOIN "Clarity"."dbo"."zc_fin_class" "ZC_FIN_CLASS" 	
                     ON "clarity_tdl_tran"."original_fin_class" = 	
                        "zc_fin_class"."fin_class_c") 	
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_ser_2" "CLARITY_SER_2" 	
                    ON "CLARITY_SER_BILLING"."prov_id" = 	
                       "clarity_ser_2"."prov_id" 	
	   left join clarity_pos pos on clarity_tdl_tran.pos_id = pos.pos_id
	   left join arpb_transactions2 arpb on "CLARITY_TDL_TRAN".tx_id = arpb.tx_id
	   left join ZC_OUTST_CLM_STAT stat on arpb.OUTST_CLM_STAT_C = stat.OUTST_CLM_STAT_C
	   left join patient pat on clarity_tdl_tran.int_pat_id = pat.pat_id
WHERE  ( "clarity_tdl_tran"."orig_post_date" >= {ts '2013-01-01 00:00:00'} 	
         AND "clarity_tdl_tran"."orig_post_date" < {ts '2013-04-01 00:00:00'} ) 	
       AND ( (( ( "clarity_tdl_tran"."cpt_code" >= '96150' 	
                  AND "clarity_tdl_tran"."cpt_code" <= '96154' ) 	
                 OR ( "clarity_tdl_tran"."cpt_code" >= '90800' 	
                      AND "clarity_tdl_tran"."cpt_code" <= '90899' ) 	
                 OR ( "clarity_tdl_tran"."cpt_code" >= '99024' 	
                      AND "clarity_tdl_tran"."cpt_code" <= '99480' ) )) 	
              OR 	
( "clarity_eap"."proc_cat" = 'PR EVALUATION AND MANAGEMENT SERVICES' ) ) 	
AND "clarity_ser_2"."npi" = '1942203765'  	
and "zc_fin_class"."name" in ('Medicaid','Medicaid Managed')	
and "CLARITY_TDL_TRAN".tx_id not in (24349692)	
and "CLARITY_SER_SERVICE"."prov_name" in ('Smith, Kenneth E','Smith, Kenneth')	

group by  "CLARITY_SER_SERVICE"."prov_name",	
       "clarity_tdl_tran"."performing_prov_id", 	
       "CLARITY_SER_BILLING"."prov_id",	
       "CLARITY_SER_BILLING"."prov_name", 	
	   "clarity_tdl_tran"."period" ,
	   pat_mrn_id,
	   clarity_tdl_tran.orig_service_date,
       "zc_fin_class"."name",	
	   "CLARITY_TDL_TRAN".tx_id,
	   detail_type,
	   pos_name,
	   stat.title

