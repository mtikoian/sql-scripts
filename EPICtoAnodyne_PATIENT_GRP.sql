SELECT "PATIENT"."PAT_ID", 
		"PATIENT"."PAT_LAST_NAME", 
		"PATIENT"."PAT_FIRST_NAME", 
		"PATIENT"."PAT_MIDDLE_NAME", 
		"PATIENT"."ZIP", 
		"PATIENT"."BIRTH_DATE", 
		"PATIENT"."PAT_MRN_ID", 
		"PATIENT"."CITY", 
		"ZC_COUNTY"."NAME" as "COUNTY_NAME", 
		"ZC_STATE"."NAME" as "STATE_NAME", 
		'' as 'CUR_PRIM_LOC_ID',
		"ZC_SEX".NAME AS SEX,
		"patient".ADD_LINE_1,
		"patient".ADD_LINE_2,
		"Patient".PAT_STATUS,
		loc.rpt_grp_ten as Service_Area
 FROM   "Clarity"."dbo"."PATIENT" "PATIENT" 
		LEFT OUTER JOIN "Clarity"."dbo"."ZC_COUNTY" "ZC_COUNTY" 
				ON "PATIENT"."COUNTY_C"="ZC_COUNTY"."COUNTY_C"
		LEFT OUTER JOIN "Clarity"."dbo"."ZC_STATE" "ZC_STATE" 
				ON "PATIENT"."STATE_C"="ZC_STATE"."STATE_C"
		LEFT OUTER JOIN "Clarity"."dbo"."ZC_Sex" "ZC_Sex" 
				ON "PATIENT".SEX_C="ZC_sex".INTERNAL_ID
		left join clarity_loc loc on loc.loc_id = patient.cur_prim_loc_id
WHERE PATIENT.PAT_ID LIKE '[A-Z]%'

