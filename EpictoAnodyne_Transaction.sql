SELECT clarity_tdl_tran.tdl_id, 
       CLARITY_TDL_TRAN.detail_type, 
	   CLARITY_TDL_TRAN.post_date, 
	   CLARITY_TDL_TRAN.orig_post_date, 
	   CLARITY_TDL_TRAN.orig_service_date, 
	   CLARITY_TDL_TRAN.tx_id, 
	   CLARITY_TDL_TRAN.tran_type, 
	   CLARITY_TDL_TRAN.match_trx_id, 
	   CLARITY_TDL_TRAN.account_id, 
	   CLARITY_TDL_TRAN.pat_id, 
	   CLARITY_TDL_TRAN.amount, 
	   CLARITY_TDL_TRAN.patient_amount, 
	   CLARITY_TDL_TRAN.insurance_amount, 
	   CLARITY_TDL_TRAN.relative_value_unit, 
	   CLARITY_TDL_TRAN.cur_payor_id,
	   CLARITY_TDL_TRAN.cur_plan_id, 
	   CLARITY_TDL_TRAN.proc_id, 
	   CLARITY_TDL_TRAN.performing_prov_id, 
	   CLARITY_TDL_TRAN.billing_provider_id, 
	   CLARITY_TDL_TRAN.original_payor_id, 
	   CLARITY_TDL_TRAN.original_plan_id, 
	   CLARITY_TDL_TRAN.procedure_quantity, 
	   CLARITY_TDL_TRAN.cpt_code, 
	   CLARITY_TDL_TRAN.modifier_one, 
	   CLARITY_TDL_TRAN.modifier_two, 
	   CLARITY_TDL_TRAN.modifier_three, 
	   CLARITY_TDL_TRAN.modifier_four, 
	   CLARITY_TDL_TRAN.dx_one_id, 
	   CLARITY_TDL_TRAN.dx_two_id, 
	   CLARITY_TDL_TRAN.dx_three_id, 
	   CLARITY_TDL_TRAN.dx_four_id, 
	   CLARITY_TDL_TRAN.dx_five_id, 
	   CLARITY_TDL_TRAN.dx_six_id, 
	   CLARITY_TDL_TRAN.serv_area_id, 
	   CLARITY_TDL_TRAN.loc_id, 
	   CLARITY_TDL_TRAN.dept_id, 
	   CLARITY_TDL_TRAN.pos_id, 
	   CLARITY_TDL_TRAN.invoice_number, 
	   CLARITY_TDL_TRAN.clm_claim_id, 
	   CLARITY_TDL_TRAN.pat_aging_days, 
	   CLARITY_TDL_TRAN.ins_aging_days, 
	   CLARITY_TDL_TRAN.action_payor_id, 
	   CLARITY_TDL_TRAN.reason_code_id, 
	   LEFT(clarity_tdl_tran.user_id,18), 
	   CLARITY_TDL_TRAN.tx_num, 
	   CLARITY_TDL_TRAN.int_pat_id, 
	   CLARITY_TDL_TRAN.rvu_work, 
	   CLARITY_TDL_TRAN.rvu_overhead, 
	   CLARITY_TDL_TRAN.rvu_malpractice, 
	   CLARITY_TDL_TRAN.referral_source_id, 
	   CLARITY_TDL_TRAN.referral_id, 
	   CLARITY_TDL_TRAN.match_payor_id,
	   CLARITY_TDL_TRAN.visit_number, 
	   CLARITY_TDL_TRAN.charge_slip_number, 
	   CLARITY_TDL_TRAN.period,ZC_SPECIALTY.NAME,

/* USE PRE 4/1/2014 FORMULA WHEN POST_DATE <= 3/31/14. */
	   CASE WHEN clarity_tdl_tran.post_date <= '2014-03-31' 
			THEN CASE WHEN ( 
					clarity_tdl_tran.detail_type IN (1,10)
						   ) 
    AND 

    ( 
      cpt_code NOT IN ('90460', '90461', '90471', '90472', '90473', '90474') 
     
	  OR 
      cpt_code IS NULL 
    ) 

    THEN 

    CASE WHEN COALESCE(clarity_tdl_tran.rvu_work,0) > 0 THEN 
      clarity_tdl_tran.rvu_work * COALESCE(clarity_tdl_tran.procedure_quantity,0)ELSE COALESCE(clarity_tdl_tran.relative_value_unit,0)END ELSE 0 END
      /* USE POST 4/1/2014 FORMULA WHEN ORIG_POST_DATE > 3/31/14. */ELSE CASE WHEN (
          clarity_tdl_tran.detail_type IN (1, 
                                           10) 
        ) 
        AND 
        ( 
          cpt_code NOT IN ('90460', '90461','90471', '90472', '90473', '90474',  '96360', '96365',  '96401', '96413', '96415', '96420',  '96422', '96423',  '96425',  '96440', '96446',   '96450',  '96542', 
                           '96361',  '96366',  '96367',  '96368', '96369',  '96370', '96371',  '96372', '96373','96374',  '96375',   '96376',  '96379', '96402',   '96405',   '96406', '96409',   '96411', 
                           '96416',   '96417',   '96523') 
          OR 
          cpt_code IS NULL 
        ) 
        THEN 
        CASE WHEN COALESCE(clarity_tdl_tran.rvu_work,0) > 0  THEN 

          clarity_tdl_tran.rvu_work * COALESCE(clarity_tdl_tran.procedure_quantity,0)ELSE COALESCE(clarity_tdl_tran.relative_value_unit,0) END ELSE 0 END
       
	    END 

      AS sub_rvu,COALESCE( 
                ( 
                SELECT m.adjustpct 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_one),1.00) AS modifier_adjustment1,
      COALESCE( 
                ( 
                SELECT m.adjustpct 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_two),1.00) AS modifier_adjustment2,
      COALESCE( 
                ( 
                SELECT m.adjustpct 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_three),1.00) AS modifier_adjustment3,
      COALESCE( 
                ( 
                SELECT m.adjustpct 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_four),1.00) AS modifier_adjustment4,
      COALESCE( 
                ( 
                SELECT 1 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_one),0) +COALESCE( 
                ( 
                SELECT 1 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_two),0) + COALESCE( 
                ( 
                SELECT 1 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_three),0) + COALESCE( 
                ( 
                SELECT 1 
                FROM   ssis.dbo.chpit_anodyne_modifier_adjustments_for_rvu m 
                WHERE  m.modifier = clarity_tdl_tran.modifier_four),0) AS modifier_found_count FROM clarity.dbo.clarity_tdl_tran clarity_tdl_tran 
				LEFT OUTER JOIN clarity.dbo.zc_specialty zc_specialty ON clarity_tdl_tran.prov_specialty_c = zc_specialty.specialty_c WHERE clarity_tdl_tran.serv_area_id IN (11,13, 16, 17, 18, 19) 
						AND 
						 	tx_id = 87312577
         
     --)SET final_adjustpct = modifier_adjustment1 * modifier_adjustment2 * modifier_adjustment3 *

