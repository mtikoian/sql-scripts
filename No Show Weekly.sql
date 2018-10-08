SELECT 
              case when loc.rpt_grp_two in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_two in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138') then 'CINCINNATI'
	 when loc.rpt_grp_two in ('13104','13105','13116') then 'YOUNGSTOWN'
	 when loc.rpt_grp_two in ('16102','16103','16104') then 'LIMA'
	 when loc.rpt_grp_two in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.rpt_grp_two in ('18120','18121') then 'DEFIANCE'
	 when loc.rpt_grp_two in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.rpt_grp_two in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.rpt_grp_two in ('131201','131202') then 'SUMMA'
	 end as 'REGION',

             -- sum(1) as "Total Encounter",

              -- sum(case when "ZC_REG_STATUS"."NAME"='Verified' then 1 end) as "Verified"

	patient.pat_name 'Patient'
	,patient.pat_mrn_id 'MRN'
	,pat_enc.PAT_ENC_CSN_ID 'CSN'
	,dep.DEPARTMENT_NAME 'Patient Dept'
	,cast(pat_enc.contact_date as date) 'Service Date'
	,ser.prov_name 'Visit Provider'
	,prc.prc_name 'Visit Type'
	,pat_enc.enc_type_c 'Encounter Type'
	,pat_enc.appt_status_c 'Appt Status'
	,case when pat_enc.appt_status_c = 2 or pat_enc.appt_status_c = 6 then 1 else 0 end 'Comp'
	,case when pat_enc.appt_status_c = 1 or pat_enc.appt_status_c = 4 then 1 else 0 end 'No Show'
	,case when pat_enc.contact_date is not null then 1 else 0 end 'Total'

	


FROM   ((((("Clarity"."dbo"."PAT_ENC" "PAT_ENC" INNER JOIN "Clarity"."dbo"."PAT_ENC_2" "PAT_ENC_2" ON ("PAT_ENC"."PAT_ENC_CSN_ID"="PAT_ENC_2"."PAT_ENC_CSN_ID") AND ("PAT_ENC"."CONTACT_DATE"="PAT_ENC_2"."CONTACT_DATE")) 
                                                                                   INNER JOIN "Clarity"."dbo"."ZC_APPT_STATUS" "ZC_APPT_STATUS" ON "PAT_ENC"."APPT_STATUS_C"="ZC_APPT_STATUS"."APPT_STATUS_C") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."PATIENT" "PATIENT" ON "PAT_ENC"."PAT_ID"="PATIENT"."PAT_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" dep ON "PAT_ENC"."DEPARTMENT_ID"=dep."DEPARTMENT_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."VERIFICATION" "VERIFICATION" ON "PAT_ENC_2"."ENC_VERIFICATION_ID"="VERIFICATION"."RECORD_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."ZC_REG_STATUS" "ZC_REG_STATUS" ON "VERIFICATION"."VERIF_STATUS_C"="ZC_REG_STATUS"."REG_STATUS_C"
																				   left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
																				   left join CLARITY_EMP emp on emp.user_id = pat_enc.checkin_user_id
																				   left join pat_enc_3 enc_3 on enc_3.pat_enc_csn = pat_enc.pat_enc_csn_id
																				   left join clarity_emp emp_chkout on emp_chkout.user_id = enc_3.CHKOUT_USER_ID
																				   left join clarity_ser ser on ser.prov_id = pat_enc.visit_prov_id
																				   left join clarity_prc prc on prc.prc_id = pat_enc.appt_prc_id
 
 WHERE loc.rpt_grp_two in (/*'11106','11124','11149' -- SPRINGFILED*/
'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146',/*'11149',*/'11151','11132','11138' -- CINCINNATI
--'13104','13105','13116' -- YOUNGSTOWN
--'16102','16103','16104' -- LIMA
--'17105','17106','17107','17108','17109','17110','17112','17113' -- LORAIN
--'18120','18121' -- DEFIANCE
--'18101','18102','18103','18104','18105','18130','18131','18132','18133' -- TOLEDO 
--'19101','19102','19106' -- KENTUCKY AND
/*,'131201','131202' -- SUMMA*/
) and
              ("PAT_ENC"."APPT_STATUS_C"=2 OR "PAT_ENC"."APPT_STATUS_C"=6 or "PAT_ENC"."APPT_STATUS_C"=1 or "PAT_ENC"."APPT_STATUS_C"=4) AND 
              ("PAT_ENC"."CONTACT_DATE">= '2017/11/01' AND 
               "PAT_ENC"."CONTACT_DATE"<= '2017/11/30') --AND 
            --  ("PAT_ENC"."ENC_TYPE_C"='1000' OR "PAT_ENC"."ENC_TYPE_C"='1001' OR "PAT_ENC"."ENC_TYPE_C"='1003' OR "PAT_ENC"."ENC_TYPE_C"='101' OR "PAT_ENC"."ENC_TYPE_C"='108' OR "PAT_ENC"."ENC_TYPE_C"='11' OR "PAT_ENC"."ENC_TYPE_C"='1200' OR "PAT_ENC"."ENC_TYPE_C"='1201' OR "PAT_ENC"."ENC_TYPE_C"='121' OR "PAT_ENC"."ENC_TYPE_C"='1214' OR "PAT_ENC"."ENC_TYPE_C"='2' OR "PAT_ENC"."ENC_TYPE_C"='201' OR "PAT_ENC"."ENC_TYPE_C"='21005' OR "PAT_ENC"."ENC_TYPE_C"='210177' OR "PAT_ENC"."ENC_TYPE_C"='2102' OR "PAT_ENC"."ENC_TYPE_C"='2501' OR "PAT_ENC"."ENC_TYPE_C"='2502' OR "PAT_ENC"."ENC_TYPE_C"='283' OR "PAT_ENC"."ENC_TYPE_C"='49' OR "PAT_ENC"."ENC_TYPE_C"='51' OR "PAT_ENC"."ENC_TYPE_C"='81')

-- ORDER BY "PAT_ENC"."SERV_AREA_ID", "CLARITY_DEP"."REV_LOC_ID", "PATIENT"."PAT_MRN_ID"

--GROUP BY 
--     case when loc.rpt_grp_two in ('11106','11124','11149')  then 'SPRINGFIELD'
--	 when loc.rpt_grp_two in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138') then 'CINCINNATI'
--	 when loc.rpt_grp_two in ('13104','13105','13116') then 'YOUNGSTOWN'
--	 when loc.rpt_grp_two in ('16102','16103','16104') then 'LIMA'
--	 when loc.rpt_grp_two in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
--	 when loc.rpt_grp_two in ('18120','18121') then 'DEFIANCE'
--	 when loc.rpt_grp_two in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
--	 when loc.rpt_grp_two in ('19101','19102','19106') then 'KENTUCKY'  
--	 when loc.rpt_grp_two in ('131201','131202') then 'SUMMA'
--	end