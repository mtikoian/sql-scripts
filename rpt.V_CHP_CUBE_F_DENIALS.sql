USE [ClarityCHPUtil]
GO

/****** Object:  View [Rpt].[V_CHP_CUBE_F_DENIALS]    Script Date: 1/30/2016 8:35:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER view [Rpt].[V_CHP_CUBE_F_DENIALS] as

SELECT 
	   NEWID() as ID,
	   "v_arpb_remit_codes"."match_chg_tx_id", 
       "v_arpb_remit_codes"."pat_id", 
       "v_arpb_remit_codes"."account_id", 
       "v_arpb_remit_codes"."match_chg_tx_num", 
       "v_arpb_remit_codes"."dept_nm_wid", 
       "v_arpb_remit_codes"."loc_nm_wid", 
       "v_arpb_remit_codes"."match_chg_orig_amt", 
       "v_arpb_remit_codes"."billing_prov_nm_wid", 
       "v_arpb_remit_codes"."cpt_code", 
       "v_arpb_remit_codes"."payment_post_date", 
       "v_arpb_remit_codes"."payment_tx_id", 
       "v_arpb_remit_codes"."invoice_num", 
       "v_arpb_remit_codes"."eob_codes", 
       "v_arpb_remit_codes"."remit_code_name", 
       "v_arpb_remit_codes"."remit_action_name", 
       "v_arpb_remit_codes"."remit_code_cat_name", 
       "v_arpb_remit_codes"."remit_code_type_name", 
       "PMT_EOB_INFO_I_1"."denial_codes", 
       "v_arpb_remit_codes"."payor_nm_wid", 
       "v_arpb_remit_codes"."payor_fin_class_nm_wid", 
       "v_arpb_remit_codes"."plan_nm_wid", 
       "v_arpb_remit_codes"."non_primary_yn", 
       "v_arpb_remit_codes"."eob_icn", 
       "v_arpb_remit_codes"."serv_area_id", 
       "v_arpb_remit_codes"."remit_action", 
       "v_arpb_remit_codes"."remit_code_type_c", 
       "v_arpb_remit_codes"."remit_amount", 
       "v_arpb_remit_codes"."service_date", 
       "clarity_dep"."department_name", 
       "clarity_dep"."department_id", 
       "v_arpb_remit_codes"."appt_dept_id", 
       "v_arpb_remit_codes"."source_area_name", 
       "REMARK_1"."remit_code_name" as remark_code_1, 
       "REMARK_2"."remit_code_name" as remark_code_2, 
       "REMARK_3"."remit_code_name" as remark_code_3, 
       "REMARK_4"."remit_code_name" as remark_code_4, 
       "v_arpb_remit_codes"."bill_area_nm_wid", 
       "v_arpb_remit_codes"."fin_subdiv_nm_wid", 
       "v_arpb_remit_codes"."fin_div_nm_wid", 
       "REMARK_4"."rmc_external_id" as rmc_external_id_4, 
       "REMARK_1"."rmc_external_id" as rmc_external_id_1, 
       "REMARK_2"."rmc_external_id" as rmc_external_id_2, 
       "REMARK_3"."rmc_external_id" as rmc_external_id_3, 
       "v_arpb_remit_codes"."pos_nm_wid", 
       "v_arpb_remit_codes"."service_area_nm_wid", 
       "clarity_rmc"."preventable_yn",
	   getdate() as extract_date
FROM   (((((("Clarity"."dbo"."v_arpb_remit_codes" "V_ARPB_REMIT_CODES" 
             LEFT OUTER JOIN "Clarity"."dbo"."pmt_eob_info_i" "PMT_EOB_INFO_I_1" 
                          ON ( "v_arpb_remit_codes"."payment_tx_id" = 
                               "PMT_EOB_INFO_I_1"."tx_id" ) 
                             AND ( "v_arpb_remit_codes"."eob_line" = 
                                   "PMT_EOB_INFO_I_1"."line" )) 
            LEFT OUTER JOIN "Clarity"."dbo"."clarity_rmc" "REMARK_1" 
                         ON "v_arpb_remit_codes"."remark_code_1_id" = 
                            "REMARK_1"."remit_code_id") 
           LEFT OUTER JOIN "Clarity"."dbo"."clarity_rmc" "REMARK_2" 
                        ON "v_arpb_remit_codes"."remark_code_2_id" = 
                           "REMARK_2"."remit_code_id") 
          LEFT OUTER JOIN "Clarity"."dbo"."clarity_rmc" "REMARK_3" 
                       ON "v_arpb_remit_codes"."remark_code_3_id" = 
                          "REMARK_3"."remit_code_id") 
         LEFT OUTER JOIN "Clarity"."dbo"."clarity_rmc" "REMARK_4" 
                      ON "v_arpb_remit_codes"."remark_code_4_id" = 
                         "REMARK_4"."remit_code_id") 
        LEFT OUTER JOIN "Clarity"."dbo"."clarity_dep" "CLARITY_DEP" 
                     ON "v_arpb_remit_codes"."appt_dept_id" = 
                        "clarity_dep"."department_id") 
       LEFT OUTER JOIN "Clarity"."dbo"."clarity_rmc" "CLARITY_RMC" 
                    ON "v_arpb_remit_codes"."remit_code_id" = 
                       "clarity_rmc"."remit_code_id" 
WHERE  ( "v_arpb_remit_codes"."payment_post_date" >= {ts '2015-09-29 00:00:00'} 
         AND 
"v_arpb_remit_codes"."payment_post_date" < {ts '2015-10-01 00:00:00'} ) 
       AND "v_arpb_remit_codes"."serv_area_id" < 30 


GO


