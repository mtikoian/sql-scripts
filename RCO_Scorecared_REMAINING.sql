

( SELECT 
              case
                     when "CLARITY_LOC"."LOC_ID" in ('11106','11123','11124') then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'					 
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
					 when "CLARITY_SA"."SERV_AREA_ID" = '1312' then 'Summa'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_LOC"."LOC_ID" in ('19101','19102','19105','19106') then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end as "Market", 

-->>>>>>>>  Calculation for Total Charge Review Days  <<<<<<<<<<<

              sum(datediff(day, V_ARPB_CHG_REVIEW_WQ.ENTRY_DATE, V_ARPB_CHG_REVIEW_WQ.EXIT_DATE)) as "Total Charge Review Days",

-->>>>>>>>  Calculation for Distinct count Lag Charges  <<<<<<<<<<<

              Count("ARPB_TRANSACTIONS"."Account_ID") as "Distinct count Lag Charges",

-->>>>>>>>  Calculation for Lag Days  <<<<<<<<<<<

              sum(datediff(day, V_ARPB_CHG_REVIEW_WQ.ENTRY_DATE, V_ARPB_CHG_REVIEW_WQ.EXIT_DATE))/Count("ARPB_TRANSACTIONS"."Account_ID") as "Review Days"


 FROM "Clarity"."dbo"."ARPB_TRANSACTIONS" ARPB_TRANSACTIONS LEFT OUTER JOIN (select loc_id, loc_name from "Clarity"."dbo".CLARITY_LOC) CLARITY_LOC ON ARPB_TRANSACTIONS.LOC_ID=CLARITY_LOC.LOC_ID
LEFT OUTER JOIN (select proc_id,proc_code,proc_cat_id,proc_name from "Clarity"."dbo".CLARITY_EAP) CLARITY_EAP ON ARPB_TRANSACTIONS.PROC_ID=CLARITY_EAP.PROC_ID
LEFT OUTER JOIN (select proc_cat_id,proc_cat_name from "Clarity"."dbo".EDP_PROC_CAT_INFO) EDP_PROC_CAT_INFO ON CLARITY_EAP.PROC_CAT_ID=EDP_PROC_CAT_INFO.PROC_CAT_ID
LEFT OUTER JOIN (select pos_type_c,pos_id,pos_name from "Clarity"."dbo".CLARITY_POS) CLARITY_POS ON ARPB_TRANSACTIONS.POS_ID=CLARITY_POS.POS_ID
LEFT OUTER JOIN "Clarity"."dbo".ZC_POS_TYPE ZC_POS_TYPE ON CLARITY_POS.POS_TYPE_C=ZC_POS_TYPE.POS_TYPE_C
LEFT OUTER JOIN (select specialty_dep_c,department_id,department_name from "Clarity"."dbo".CLARITY_DEP) CLARITY_DEP ON ARPB_TRANSACTIONS.DEPARTMENT_ID=CLARITY_DEP.DEPARTMENT_ID
LEFT OUTER JOIN "Clarity"."dbo".ZC_SPECIALTY_DEP ZC_SPECIALTY_DEP ON CLARITY_DEP.SPECIALTY_DEP_C=ZC_SPECIALTY_DEP.SPECIALTY_DEP_C
LEFT OUTER JOIN (select prov_id,prov_name from "Clarity"."dbo".CLARITY_SER) BILLING_PROVIDER ON ARPB_TRANSACTIONS.BILLING_PROV_ID=BILLING_PROVIDER.PROV_ID
LEFT OUTER JOIN (select prov_id,prov_name from "Clarity"."dbo".CLARITY_SER) SERVICE_PROVIDER ON ARPB_TRANSACTIONS.SERV_PROVIDER_ID=SERVICE_PROVIDER.PROV_ID
LEFT OUTER JOIN (select serv_area_id,serv_area_name from "Clarity"."dbo".CLARITY_SA) CLARITY_SA ON ARPB_TRANSACTIONS.SERVICE_AREA_ID=CLARITY_SA.SERV_AREA_ID
LEFT OUTER JOIN "Clarity"."dbo".ARPB_TRANSACTIONS2 ARPB_TRANSACTIONS2 ON ARPB_TRANSACTIONS.TX_ID=ARPB_TRANSACTIONS2.TX_ID
LEFT OUTER JOIN (select fin_div_id,fin_div_nm from "Clarity"."dbo".FIN_DIV) FIN_DIV ON ARPB_TRANSACTIONS2.FIN_DIV_ID=FIN_DIV.FIN_DIV_ID
LEFT OUTER JOIN (select fin_subdiv_id,fin_subdiv_nm from "Clarity"."dbo".FIN_SUBDIV) FIN_SUBDIV ON ARPB_TRANSACTIONS2.FIN_SUBDIV_ID=FIN_SUBDIV.FIN_SUBDIV_ID
LEFT OUTER JOIN (select bill_area_id,record_name from "Clarity"."dbo".BILL_AREA) BILL_AREA ON ARPB_TRANSACTIONS.BILL_AREA_ID=BILL_AREA.BILL_AREA_ID
LEFT OUTER JOIN "Clarity"."dbo".ARPB_TX_MODERATE ARPB_TX_MODERATE ON ARPB_TX_MODERATE.TX_ID=ARPB_TRANSACTIONS.TX_ID /*need this to get TAR id to link to CR view */
LEFT OUTER JOIN "Clarity"."dbo".V_ARPB_CHG_REVIEW_WQ V_ARPB_CHG_REVIEW_WQ ON ARPB_TX_MODERATE.SOURCE_TAR_ID=V_ARPB_CHG_REVIEW_WQ.TAR_ID
LEFT OUTER JOIN "Clarity"."dbo".CLARITY_UCL CLARITY_UCL ON ARPB_TRANSACTIONS.CHG_ROUTER_SRC_ID=CLARITY_UCL.UCL_ID
LEFT OUTER JOIN "Clarity"."dbo".ZC_CHG_SOURCE_UCL ZC_CHG_SOURCE_UCL ON CLARITY_UCL.CHARGE_SOURCE_C=ZC_CHG_SOURCE_UCL.chg_source_ucl_c
LEFT OUTER JOIN "Clarity"."dbo".ZC_CHRG_SOURCE_TAR ZC_CHRG_SOURCE_TAR ON V_ARPB_CHG_REVIEW_WQ.SOURCE_C=ZC_CHRG_SOURCE_TAR.CHARGE_SOURCE_C
LEFT OUTER JOIN "Clarity"."dbo".DATE_DIMENSION dt on dt.CALENDAR_DT=ARPB_TRANSACTIONS.POST_DATE
LEFT OUTER JOIN "Clarity"."dbo".DATE_DIMENSION dts on dts.CALENDAR_DT=ARPB_TRANSACTIONS.SERVICE_DATE
LEFT OUTER JOIN "Clarity"."dbo".ARPB_TX_VOID ARPB_TX_VOID ON ARPB_TX_VOID.TX_ID=ARPB_TRANSACTIONS.TX_ID

       
WHERE  ARPB_TRANSACTIONS.TX_TYPE_C=1 
and (ARPB_TX_VOID.OLD_ETR_ID IS NULL and ARPB_TX_VOID.REPOSTED_ETR_ID IS NULL and ARPB_TX_VOID.REPOST_TYPE_C IS NULL and ARPB_TX_VOID.RETRO_CHARGE_ID IS NULL)
--and '{?Service or Post Date}'='Service Date'
--and ARPB_TRANSACTIONS.SERVICE_DATE between EPIC_UTIL.EFN_DIN('{?StartDate}') AND EPIC_UTIL.EFN_DIN('{?EndDate}')
and

--7/31/16 DSP Added 1312
("ARPB_TRANSACTIONS"."SERVICE_AREA_ID" in (11,13,16,17,18,19,21,1312)) and
("ARPB_TRANSACTIONS"."SERVICE_DATE">=@start_date AND 
 "ARPB_TRANSACTIONS"."SERVICE_DATE"<=@end_date)

GROUP BY (case
                     when "CLARITY_LOC"."LOC_ID" in ('11106','11123','11124') then 'Springfield Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '11' then 'Cincinnati Market'					 
                     when "CLARITY_SA"."SERV_AREA_ID" = '13' then 'Youngstown Market'
					 when "CLARITY_SA"."SERV_AREA_ID" = '1312' then 'Summa'
                     when "CLARITY_SA"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_LOC"."LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_LOC"."LOC_ID" = '18121' then 'Defiance Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_LOC"."LOC_ID" in ('19101','19102','19105','19106') then 'Kentucky Market'
                     when "CLARITY_SA"."SERV_AREA_ID" = '21' then 'Healthspan Market'
              end)
) as "Review",



(  SELECT 
              case
                     when "CLARITY_DEP"."REV_LOC_ID" in ('11106','11123','11124') then 'Springfield Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '11' then 'Cincinnati Market'					
                     when "PAT_ENC"."SERV_AREA_ID" = '13' then 'Youngstown Market'
					 when "PAT_ENC"."SERV_AREA_ID" = '1312' then 'Summa'
                     when "PAT_ENC"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18121' then 'Defiance Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_DEP"."REV_LOC_ID" in ('19101','19102','19105','19106') then 'Kentucky Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end as "Market", 

              sum(1) as "Total Encounter",

              sum(case when "ZC_REG_STATUS"."NAME"='Verified' then 1 end) as "Verified"



FROM   ((((("Clarity"."dbo"."PAT_ENC" "PAT_ENC" INNER JOIN "Clarity"."dbo"."PAT_ENC_2" "PAT_ENC_2" ON ("PAT_ENC"."PAT_ENC_CSN_ID"="PAT_ENC_2"."PAT_ENC_CSN_ID") AND ("PAT_ENC"."CONTACT_DATE"="PAT_ENC_2"."CONTACT_DATE")) 
                                                                                   INNER JOIN "Clarity"."dbo"."ZC_APPT_STATUS" "ZC_APPT_STATUS" ON "PAT_ENC"."APPT_STATUS_C"="ZC_APPT_STATUS"."APPT_STATUS_C") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."PATIENT" "PATIENT" ON "PAT_ENC"."PAT_ID"="PATIENT"."PAT_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" "CLARITY_DEP" ON "PAT_ENC"."DEPARTMENT_ID"="CLARITY_DEP"."DEPARTMENT_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."VERIFICATION" "VERIFICATION" ON "PAT_ENC_2"."ENC_VERIFICATION_ID"="VERIFICATION"."RECORD_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."ZC_REG_STATUS" "ZC_REG_STATUS" ON "VERIFICATION"."VERIF_STATUS_C"="ZC_REG_STATUS"."REG_STATUS_C"

 WHERE  ("CLARITY_DEP"."DEPARTMENT_ID" <> 16102050 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16106108 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16106112 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16107104 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16108104 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16109113 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16109115 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16111101 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16102042 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16102028 and
              "CLARITY_DEP"."DEPARTMENT_ID" <> 16102043) and
              (("CLARITY_DEP"."REV_LOC_ID"=11101 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11102 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11103 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11104 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11105 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11106 OR 
			   "CLARITY_DEP"."REV_LOC_ID"=11123 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11124 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11132 OR 
               "CLARITY_DEP"."REV_LOC_ID"=11138 OR 
               "CLARITY_DEP"."REV_LOC_ID"=13104 OR 
               "CLARITY_DEP"."REV_LOC_ID"=13105 OR             
               "CLARITY_DEP"."REV_LOC_ID"=16102 OR
               "CLARITY_DEP"."REV_LOC_ID"=16103 OR
               "CLARITY_DEP"."REV_LOC_ID"=17105 OR 
               "CLARITY_DEP"."REV_LOC_ID"=17106 OR 
               "CLARITY_DEP"."REV_LOC_ID"=17110 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18101 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18102 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18103 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18104 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18105 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18120 OR 
               "CLARITY_DEP"."REV_LOC_ID"=18121 OR 
               "CLARITY_DEP"."REV_LOC_ID"=19101 OR 
               "CLARITY_DEP"."REV_LOC_ID"=19102 OR 
               "CLARITY_DEP"."REV_LOC_ID"=19105 OR 
               "CLARITY_DEP"."REV_LOC_ID"=19106 OR 
               "CLARITY_DEP"."REV_LOC_ID"=19107 OR 
               "CLARITY_DEP"."REV_LOC_ID"=19108 OR 
               "CLARITY_DEP"."REV_LOC_ID"=21101 OR 
               "CLARITY_DEP"."REV_LOC_ID"=21102 OR 
               "CLARITY_DEP"."REV_LOC_ID"=21103 OR 
               "CLARITY_DEP"."REV_LOC_ID"=21104 OR 
			   "CLARITY_DEP"."REV_LOC_ID"=131201 OR
			   "CLARITY_DEP"."REV_LOC_ID"=131202 OR
               "CLARITY_DEP"."REV_LOC_ID"=11114111)) AND

			   --7/31 DSP added Service Area ID 1312
              ("PAT_ENC"."SERV_AREA_ID"=11 OR "PAT_ENC"."SERV_AREA_ID"=13 OR "PAT_ENC"."SERV_AREA_ID"=16 OR "PAT_ENC"."SERV_AREA_ID"=17 OR "PAT_ENC"."SERV_AREA_ID"=18 OR "PAT_ENC"."SERV_AREA_ID"=19 OR "PAT_ENC"."SERV_AREA_ID"=20 OR "PAT_ENC"."SERV_AREA_ID"=21 OR "PAT_ENC"."SERV_AREA_ID"=1312) AND
              ("PAT_ENC"."APPT_STATUS_C"=2 OR "PAT_ENC"."APPT_STATUS_C"=6) AND 
              ("PAT_ENC"."CONTACT_DATE">=@start_date AND 
               "PAT_ENC"."CONTACT_DATE"<=@end_date) AND 
              ("PAT_ENC"."ENC_TYPE_C"='1000' OR "PAT_ENC"."ENC_TYPE_C"='1001' OR "PAT_ENC"."ENC_TYPE_C"='1003' OR "PAT_ENC"."ENC_TYPE_C"='101' OR "PAT_ENC"."ENC_TYPE_C"='108' OR "PAT_ENC"."ENC_TYPE_C"='11' OR "PAT_ENC"."ENC_TYPE_C"='1200' OR "PAT_ENC"."ENC_TYPE_C"='1201' OR "PAT_ENC"."ENC_TYPE_C"='121' OR "PAT_ENC"."ENC_TYPE_C"='1214' OR "PAT_ENC"."ENC_TYPE_C"='2' OR "PAT_ENC"."ENC_TYPE_C"='201' OR "PAT_ENC"."ENC_TYPE_C"='21005' OR "PAT_ENC"."ENC_TYPE_C"='210177' OR "PAT_ENC"."ENC_TYPE_C"='2102' OR "PAT_ENC"."ENC_TYPE_C"='2501' OR "PAT_ENC"."ENC_TYPE_C"='2502' OR "PAT_ENC"."ENC_TYPE_C"='283' OR "PAT_ENC"."ENC_TYPE_C"='49' OR "PAT_ENC"."ENC_TYPE_C"='50' OR "PAT_ENC"."ENC_TYPE_C"='51' OR "PAT_ENC"."ENC_TYPE_C"='81')

---RUN BY ENCOUNTER TYPE, DO NOT FILTER ON ENCOUNTER TYPE

-- ORDER BY "PAT_ENC"."SERV_AREA_ID", "CLARITY_DEP"."REV_LOC_ID", "PATIENT"."PAT_MRN_ID"

GROUP BY 
               Case
                     when "CLARITY_DEP"."REV_LOC_ID" in ('11106','11123','11124') then 'Springfield Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '11' then 'Cincinnati Market'					 
                     when "PAT_ENC"."SERV_AREA_ID" = '13' then 'Youngstown Market'
					 when "PAT_ENC"."SERV_AREA_ID" = '1312' then 'Summa'
                     when "PAT_ENC"."SERV_AREA_ID" = '16' then 'Lima Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '17' then 'Lorain Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18120' then 'Defiance Market'
                     when "CLARITY_DEP"."REV_LOC_ID" = '18121' then 'Defiance Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '18' then 'Toledo Market'
                     when "CLARITY_DEP"."REV_LOC_ID" in ('19101','19102','19105','19106') then 'Kentucky Market'
                     when "PAT_ENC"."SERV_AREA_ID" = '21' then 'Healthspan Market'
        end

) as "Ver"


where main.market = sub.market and main.market = copay.market and main.market = ENC.market and main.market = Lag.market  and main.market = Ver.market  and main.market = Review.market


