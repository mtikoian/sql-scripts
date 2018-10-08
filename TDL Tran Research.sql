declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}');

SELECT DISTINCT  
				 ZC_LOC_RPT_GRP_10.name,
				 pop_health_patients.payor as 'Pop Health',
				 DATEDIFF(day,pat_enc_hsp.hosp_disch_time,pat_enc.appt_time) as 'DC to FU Days',
				 CLARITY_DEP_emp_pcp.rev_loc_id,
				 CLARITY_DEP_fu_visit.rev_loc_id 'FU Loc ID',
				 pat_enc_hsp.hosp_disch_time 'DC Time', 
                 f_ip_hsp_pat_days.pat_enc_csn_id  'CSN', 
                 f_ip_hsp_pat_days.pat_id 'PAT ID', 
                 pat_enc_hsp.bill_num  , 
                 pat_enc_hsp.hsp_account_id , 
                 pat_enc_hsp.hosp_admsn_time 'ADM Time', 
                 clarity_loc.loc_id 'Location ID', 
                 clarity_loc.loc_name 'Location',				 
                 zc_acct_class_ha.name 'Acct Class', 
                 zc_acct_basecls_ha.name 'Acct Base Class', 
                 patient.pat_name 'Pt Name', 
                 patient.birth_date 'DOB', 
                 clarity_fc.financial_class , 
                 clarity_fc.financial_class_name , 
                 pat_enc.appt_time 'FU Appt Time', 
                 pat_enc.pat_enc_csn_id 'FU CSN ID', 
                 clarity_ucl.charge_source_c , 
                 clarity_ucl.procedure_id 'Chg Proc ID', 
                 clarity_ucl.service_date_dt 'Chg Svc Date', 
                 zc_charge_source.name 'Chg Source',
	             clarity_eap.proc_code 'CPT Code', 
                 clarity_eap.proc_name 'Chg Name', 
                 CLARITY_LOC_fu_visit.loc_name 'FU Location', 
                 clarity_ser.prov_name 'FU Provider', 
                 clarity_ser.prov_type 'FU Provider Type', 
                 pat_enc.enc_type_c , 
                 zc_disp_enc_type.name 'FU Encounter Tpye', 
                 CLARITY_SER_pcp.prov_name 'PCP', 
                 CLARITY_SER_pcp.prov_type 'PCP Type',

				 clarity_tdl_tran.orig_service_date,
                 clarity_tdl_tran.orig_post_date,
                 clarity_tdl_tran.post_date,


				   (select top 1 
		meas.MEAS_VALUE 
		from ip_flwsht_rec rec
		left outer join pat_enc pe on rec.inpatient_data_id=pe.inpatient_data_id
		left outer join ip_flwsht_meas meas on rec.fsd_id=meas.fsd_id
		left outer join ip_flo_gp_data gp on meas.FLO_MEAS_ID=gp.flo_meas_id
		where meas.flo_meas_id = '3042014710'
		and pe.pat_enc_csn_id=F_IP_HSP_PAT_DAYS.pat_enc_csn_id
		and meas.recorded_time = (SELECT MAX(RECORDED_TIME)
			FROM IP_FLWSHT_MEAS meas2,IP_FLWSHT_REC rec2, PAT_ENC pe2
            WHERE meas2.FSD_ID=rec2.FSD_ID
                  AND rec2.INPATIENT_DATA_ID=Pe2.INPATIENT_DATA_ID
                  and pe2.pat_enc_csn_id=pat_enc_hsp.pat_enc_csn_id
                  AND meas2.FLO_MEAS_ID='3042014710') order by meas.recorded_time desc) 
			as "Readmission_Score"

				 
				  
FROM	Clarity.dbo.f_ip_hsp_pat_days   F_IP_HSP_PAT_DAYS  
			LEFT OUTER JOIN  Clarity.dbo.patient   PATIENT  
				ON  f_ip_hsp_pat_days.pat_id  =  patient.pat_id   
            LEFT OUTER JOIN  Clarity.dbo.pat_enc_hsp PAT_ENC_HSP  
                ON  f_ip_hsp_pat_days.pat_enc_csn_id  = pat_enc_hsp.pat_enc_csn_id   
            LEFT OUTER JOIN  Clarity.dbo.pat_enc   PAT_ENC  
                ON f_ip_hsp_pat_days.pat_id  =  pat_enc.pat_id
				   AND pat_enc.appt_time > pat_enc_hsp.hosp_disch_time  
				   AND DATEDIFF(day,pat_enc_hsp.hosp_disch_time,pat_enc.appt_time) < 31
                   AND pat_enc.appt_status_c = 2 
			 Left Outer JOIN  Clarity.dbo.clarity_dep  CLARITY_DEP_fu_visit  
                ON  pat_enc.department_id  = CLARITY_DEP_fu_visit.department_id
				AND CLARITY_DEP_fu_visit.rev_loc_id in   (11101, 11124, 11132, 11121,
					    11125, 11138, 19102, 19101, 19105, 11106, 13104, 13105, 13111,
						16102, 17105, 17106, 17110, 17112, 18101, 18102, 18103, 18104,
						18105, 18120, 18130, 18131, 18132) 
			 LEFT OUTER JOIN  Clarity.dbo.clarity_loc  CLARITY_LOC_fu_visit  
                ON  CLARITY_DEP_fu_visit.rev_loc_id  = CLARITY_LOC_fu_visit.loc_id
				/* AND CLARITY_DEP_fu_visit.rev_loc_id in   (11101, 11124, 11132, 11121,
					    11125, 11138, 19102, 19101, 19105, 11106, 13104, 13105, 13111,
						16102, 17105, 17106, 17110, 17112, 18101, 18102, 18103, 18104,
						18105, 18120, 18130, 18131, 18132) */


            LEFT OUTER JOIN  Clarity.dbo.pat_enc   PAT_ENC_pcp  
                ON f_ip_hsp_pat_days.pat_enc_csn_id  = PAT_ENC_pcp.pat_enc_csn_id   
--------------------------------------------------------------------------------------------------------------------------

            LEFT OUTER JOIN  Clarity.dbo.clarity_ucl   CLARITY_UCL  
                ON pat_enc.pat_enc_csn_id  =  clarity_ucl.ept_csn
				  AND clarity_ucl.procedure_id in ('1117', '1121', '1125', '1129', '1133', '1137', 
                             '1141', '23646', '23648', '23650', '23652', '23654', '23656', '23658', 
							 '23660', '23662', '23664', '23668', '23670', '23672', '23674', '23676', 
							 '23678', '23680', '23682', '23684', '23696', '23698', '23700', '23702', 
							 '23704', '23714', '23748', '23776', '23778', '23846', '23848', '23852', 
							 '23854', '23856', '23860', '23862', '23864', '23866', '23868', '23870', 
							 '23872', '23874', '65228', '67175', '67183', '78317', '78319', '78321', 
							 '90121', '90123') 
				 AND CLARITY_DEP_fu_visit.rev_loc_id is not null  



		  LEFT JOIN  Clarity.dbo.clarity_tdl_tran   clarity_tdl_tran  
                ON pat_enc.pat_enc_csn_id  =  clarity_tdl_tran.pat_enc_csn_id
				  AND clarity_tdl_tran.proc_id in ('1117', '1121', '1125', '1129', '1133', '1137', 
                             '1141', '23646', '23648', '23650', '23652', '23654', '23656', '23658', 
							 '23660', '23662', '23664', '23668', '23670', '23672', '23674', '23676', 
							 '23678', '23680', '23682', '23684', '23696', '23698', '23700', '23702', 
							 '23704', '23714', '23748', '23776', '23778', '23846', '23848', '23852', 
							 '23854', '23856', '23860', '23862', '23864', '23866', '23868', '23870', 
							 '23872', '23874', '65228', '67175', '67183', '78317', '78319', '78321', 
							 '90121', '90123') 
				 AND CLARITY_DEP_fu_visit.rev_loc_id is not null  
				 and clarity_tdl_tran.detail_type in (1,10)
				 --filter on date








-----------------------------------------------------------------------------------------------------------------------------------------
             
         Left Outer JOIN  Clarity.dbo.clarity_ser   CLARITY_SER  
                ON  pat_enc.visit_prov_id  = clarity_ser.prov_id
                                            --AND clarity_ser.STAFF_RESOURCE_C <> 2
				AND CLARITY_DEP_fu_visit.rev_loc_id is not null  
              
              
            LEFT OUTER JOIN  Clarity.dbo.zc_disp_enc_type ZC_DISP_ENC_TYPE  
                ON  pat_enc.enc_type_c  = zc_disp_enc_type.disp_enc_type_c 
				AND CLARITY_DEP_fu_visit.rev_loc_id is not null  
           
            LEFT OUTER JOIN  Clarity.dbo.zc_charge_source  ZC_CHARGE_SOURCE  
                ON  clarity_ucl.charge_source_c  = zc_charge_source.charge_source_c   
            LEFT OUTER JOIN  Clarity.dbo.clarity_eap   CLARITY_EAP  
                ON  clarity_ucl.procedure_id  = clarity_eap.proc_id   
            LEFT OUTER JOIN  Clarity.dbo.clarity_fc   CLARITY_FC  
                ON  patient.prim_fc  = clarity_fc.financial_class   
            LEFT OUTER JOIN  Clarity.dbo.clarity_dep   CLARITY_DEP  
                ON  pat_enc_hsp.department_id  =  clarity_dep.department_id   
           LEFT OUTER JOIN  Clarity.dbo.zc_acct_class_ha   ZC_ACCT_CLASS_HA  
                ON  pat_enc_hsp.adt_pat_class_c  = zc_acct_class_ha.acct_class_ha_c   
           LEFT OUTER JOIN  Clarity.dbo.hsd_base_class_map  HSD_BASE_CLASS_MAP  
                ON  pat_enc_hsp.adt_pat_class_c  = hsd_base_class_map.acct_class_map_c   
           LEFT OUTER JOIN  Clarity.dbo.zc_acct_basecls_ha  ZC_ACCT_BASECLS_HA  
                ON  hsd_base_class_map.base_class_map_c  = zc_acct_basecls_ha.acct_basecls_ha_c   
           LEFT OUTER JOIN  Clarity.dbo.clarity_loc   CLARITY_LOC  
                ON  clarity_dep.rev_loc_id  =  clarity_loc.loc_id 

		  LEFT OUTER JOIN  Clarity.dbo.ZC_LOC_RPT_GRP_10   ZC_LOC_RPT_GRP_10  
                ON  clarity_loc.rpt_grp_ten  =  ZC_LOC_RPT_GRP_10.rpt_grp_ten
				
				
				
				
				
		   LEFT OUTER JOIN  Clarity.dbo.clarity_ser   CLARITY_SER_pcp  
                ON  PAT_ENC_pcp.pcp_prov_id  =  CLARITY_SER_pcp.prov_id 

	    	left outer JOIN  Clarity.dbo.clarity_ser_dept   CLARITY_SER_dept 
                ON  CLARITY_SER_pcp.prov_id   =  CLARITY_SER_dept.prov_id 	
				

			left outer JOIN  Clarity.dbo.clarity_dep   CLARITY_DEP_emp_pcp  
                ON  CLARITY_SER_dept.department_id  =  clarity_dep_emp_pcp.department_id 
				AND CLARITY_DEP_emp_pcp.rev_loc_id in   (11101, 11124, 11132, 11121,
					    11125, 11138, 19102, 19101, 19105, 11106, 13104, 13105, 13111,
						16102, 17105, 17106, 17110, 17112, 18101, 18102, 18103, 18104,
						18105, 18120, 18130, 18131, 18132)

			LEFT OUTER JOIN ClarityCHPUtil.ph.pop_health_patients pop_health_patients 
						   ON pat_enc_hsp.pat_id = pop_health_patients.pat_id 
						     AND pop_health_patients.php_inactive_date is null
			 
				
				 
          
				
				 
WHERE /*  (pat_enc_hsp.hosp_disch_time >=EPIC_UTIL.EFN_DIN('{?Start Date}') AND
         pat_enc_hsp.hosp_disch_time <= EPIC_UTIL.EFN_DIN('{?End Date}'))  */


         pat_enc_hsp.hosp_disch_time  >= {ts '2016-08-01 00:00:00'} 
         AND  pat_enc_hsp.hosp_disch_time  < {ts '2016-09-01 00:00:00'} 
		 
		 --and f_ip_hsp_pat_days.pat_enc_csn_id = 105826410-- 110035923
 

		 and clarity_fc.financial_class = 2

                              --  AND clarity_ser.STAFF_RESOURCE_C <> 2

		 --AND CLARITY_DEP_fu_visit.rev_loc_id is  null
		 
		 --AND clarity_ucl.procedure_id is not null 

		 AND  CLARITY_DEP_emp_pcp.rev_loc_id is not null

		 AND  pat_enc_hsp.adt_pat_class_c in(871, 777, 781, 776, 129, 101, 194, 359, 195, 
	      	   196, 342, 382, 475, 428, 478, 500, 538, 562, 801, 810, 327, 857, 390, 513, 
			   738, 739, 747, 771, 756, 764, 755, 616, 625, 627, 650, 660, 649, 717, 197, 
			   285, 603, 608, 602, 610, 778, 151, 329, 567, 802, 104, 256, 366, 257, 258, 
			   348, 404, 449, 487, 506, 744, 761, 621, 656, 259, 605)

--Order by
--DATEDIFF(day,pat_enc_hsp.hosp_disch_time,pat_enc.appt_time) desc,
--CLARITY_DEP_fu_visit.rev_loc_id,
--f_ip_hsp_pat_days.pat_enc_csn_id 


