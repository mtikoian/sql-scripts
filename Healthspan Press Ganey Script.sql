SELECT PG.SERVICE_DESIGNATOR AS "SURVEY"
,'17710' AS "CLIENT_ID"
,COALESCE ( PG.PAT_LAST_NAME,'')  AS "LAST_NAME"
,COALESCE ( PG.PAT_MIDDLE_NAME,'')  AS "MIDDLE"
,COALESCE ( PG.PAT_FIRST_NAME,'')  AS "FIRST_NAME"
--,PG.PAT_NAME AS "PATIENT NAME"
,COALESCE ( PG.ADD_LINE_1,'')  AS "ADDR1"
,COALESCE ( PG.ADD_LINE_2,'')  AS "ADDR2"
,COALESCE ( PG.CITY,'')  AS "CITY"
,COALESCE ( PG.STATE,'')  AS "STATE"
,COALESCE ( CAST( PG.ZIP AS CHAR(10)) ,'')  AS "ZIP"
,COALESCE ( PG.HOME_PHONE,'') AS "PHONE"
,COALESCE ( PG.EMAIL_ADDRESS,'') AS "EMAIL" 
,COALESCE ( PG.SEX,'')  AS "GENDER"
-- Patient Race is a Varchar 254 field
,COALESCE (  PG.RACE,'') AS "RACE"	

--, COALESCE (  CAST( CAST(  PG.BIRTH_DATE  AS FORMAT 'MMDDYYYY')  AS CHAR(8)  ),'') AS "DOB"
--,PG.BIRTH_DATE AS "DOB"
, CONVERT(VARCHAR(10),PG.BIRTH_DATE,101) AS "DOB"

--,COALESCE ( PG.LANG,'')  AS "LANGUAGE"
,COALESCE ( PG.SPOKEN_LANG,'')  AS "LANGUAGE"
--,COALESCE ( PG.WRITTEN_LANG,'')  AS "WRITTEN_LANGUAGE"

,COALESCE ( PG.PAT_MRN_ID,'')  AS "MEDREC"
,PG.PAT_ENC_CSN_ID  AS "UNIQUE_ID"
,PG.LOC_ID AS "LOCATION ID"
,COALESCE ( PG.LOC_NAME,'') AS "LOCATION NAME"

--,COALESCE (  CAST( CAST( PG.CHECKIN_TIME AS FORMAT 'HH:MI:SS')  AS CHAR(8)  ) ,'')   AS "ADM_TIME"
--,COALESCE (  CAST( CAST( PG.CHECKIN_TIME AS FORMAT 'MMDDYYYY')  AS CHAR(10)  ) ,'')   AS "ADM_DATE"

,CONVERT(VARCHAR(10),PG.CHECKIN_TIME,101) AS "ADM_DATE"


--,COALESCE (  CAST( CAST( PG.CHECKOUT_TIME AS FORMAT 'HH:MI:SS')  AS CHAR(8)  ),''  )  AS "DCG_TIME"
--,COALESCE (  CAST( CAST( PG.CHECKOUT_TIME AS FORMAT 'MMDDYYYY' )  AS CHAR(10)  ),''  )  AS "DCG_DATE"

,CONVERT(VARCHAR(10),PG.CHECKIN_TIME,101) AS "DCG_DATE"

,COALESCE ( CAST ( PG.CONTACT_DATE AS CHAR(10)  ) ,'')  AS "SVCDATE"
,COALESCE (  PG.VISIT_PROV_ID,'') AS "PROVIDER ID"
,COALESCE ( PG.VISITPROVNAME,'') AS "PROVIDER NAME"
,COALESCE (PG.VISITPROVTYPE,'') AS "PROVIDER TYPE"
,COALESCE ( PG.ENC_TYPE_TITLE,'') AS "ENCOUNTER TYPE"
,COALESCE ( PG.CONTACT_TYPE,'') AS "CONTACT TYPE"
,COALESCE ( PG.PRC_NAME,'')  AS "PRC NAME"
,PG.DEPARTMENT_ID  AS "DEPARTMENT ID"
,COALESCE ( PG.DEPARTMENT_NAME,'') AS "DEPARTMENT NAME"
,COALESCE( PG.SPECIALTY, '') AS "SPECIALTY"
,COALESCE( PG.TEAM, '') AS "TEAM"
,'' AS "PAYOR"
,'' AS "PROGRAM"
,'$'  AS EOR
--,count(1)

FROM
(
SELECT

-- The DISTINCT keyword here is redundant if using UNION. Leaving it in however
-- to make it clear that this pare of the select is doing a distinct operation. Note: there
-- are numerous cases where the same patient sees the same provider in multiple
-- Encounters  on the same day in the same specialty. From the perspective of the PG
-- group, these are indistinguishable from each other and don't need to be sent
-- inidividiaully
DISTINCT
PE.PAT_ENC_CSN_ID
-- ADD CASE DESIGNATOR HERE!!!!

-- SERVICE DESIGNATORS
-- ER0101 - ER Visits showing MD Providers - Specialty of 12017 or 120101
-- ER0102 - ER Visits showing Ancillary Providers - Specialty of 12017 or 120101 ...see subclause after union
-- OU0101 - Rehab (PT) 12074, Occupational Therapy (OT) 12045, Speech Therapy (ST) - 12088
-- OU0102 - Radiology 12083, Nuclear Medicine 12038, Interventional Radiology1215
-- AS0101 - Ambulatory Surgery - Specialty of 12097 
-- MD0101 - Medical Visits - Most encounters including Hospital Services

,CASE
 WHEN CDEP.SPECIALTY_DEP_C IN (   '12017' ,  '120101'  ) THEN 'ER0101'  -- Urgent Care and Emergency
 WHEN CDEP.SPECIALTY_DEP_C IN ( '12074','12045','12088') THEN 'OU0101'  -- Rehab (PT) 12074, Occupational Therapy (OT) 12045, Speech Therapy (ST) - 12088
 WHEN CDEP.SPECIALTY_DEP_C IN ( '12038', '12083','1215' ) THEN 'OU0102' -- Radiology 12083, Nuclear Medicine 12038, Interventional Radiology1215
 WHEN CDEP.SPECIALTY_DEP_C IN ( '12097' ) THEN 'AS0101' 
 ELSE  'MD0101'-- Am Surg
END AS "SERVICE_DESIGNATOR"

--,'ER0101' AS "SERVICE_DESIGNATOR"
--PRACE.*,
,ZPR.NAME AS "RACE"

--P.PAT_NAME
,P.PAT_LAST_NAME
,P.PAT_FIRST_NAME
,P.PAT_MIDDLE_NAME
,P.BIRTH_DATE
,P.SEX
--,P.PAT_STATUS
,P.ADD_LINE_1
,P.ADD_LINE_2
,P.CITY
,ZS.ABBR AS "STATE"

,P.ZIP
,P.HOME_PHONE
,P.EMAIL_ADDRESS

,ZL.NAME AS "LANG"
--,ZPWL.NAME AS "WRITTEN_LANG"
,ZLS.NAME AS "SPOKEN_LANG"

,PE.CONTACT_DATE 
,CLOC_DEP.LOC_ID
,CLOC_DEP.LOC_NAME
,PE.VISIT_PROV_ID
,PE.DEPARTMENT_ID
,CDEP.DEPARTMENT_NAME
,CDEP.SPECIALTY
,CSER_PCP.PROV_ID as "PCP PROV_ID"

--,pe.ENC_CLOSED_YN
,PE.APPT_STATUS_C
,P.PAT_MRN_ID

 -- coverage from PAT_CVG_BEN_OT
 ,COV.CVG_EFF_DT
 --,pcbo.PAT_ID
 ,PCBO.EARLIEST_DATE
 ,ZAS.NAME			-- Appt Status name
,CSER.PROV_NAME as "VISITPROVNAME"
,CSER.PROV_TYPE as "VISITPROVTYPE"
,CSER_PCP.PROV_NAME as "PCPPROVIDERNAME"
--,PA_NOTE.PA_PROVIDER as "PAPROVIDERNAME"
--,PA_NOTE.PROV_ID as "PAPROV_ID"
,PE.ENC_TYPE_TITLE

-- We're  flagging the type of visit by PA , Hosptialist,  APPT
,'PHYSICIAN' AS "CONTACT_TYPE"

,CP.PRC_NAME
,PE.CHECKIN_TIME
,PE.CHECKOUT_TIME

-- Team Designations
-- These are only germaine in the scope of the Press Ganey Survey
-- NOT putting these into infrastructure as they're not usable in another context
-- AND so that anyone who knows Crystal can fix or update them
--
,CASE
 WHEN PE.DEPARTMENT_ID IN (   '1211600200002' ,  '1211600200003'  ) THEN 'Avon Med/Ped'  -- Avon Med/Ped
 WHEN PE.DEPARTMENT_ID IN (   '1211600030012'  ) THEN 'Bedford Med' -- Bedford Med
 WHEN PE.DEPARTMENT_ID IN (   '1201600030003' ,  '1211600030009'  ) THEN 'Bedford Ped' -- Bedford Ped
 WHEN PE.DEPARTMENT_ID IN (   '1211600100017' ,  '1211600100015'  ) THEN 'Chapel Hill Med' -- Chapel Hill Med
 WHEN PE.DEPARTMENT_ID IN (   '1201600100007'   ) THEN 'Chapel Hill Ped'  -- Chapel Hill Ped
 WHEN PE.DEPARTMENT_ID IN (   '1201600050014'   ) THEN 'Cleveland Hts Med' --Cleveland Hts Med
 WHEN PE.DEPARTMENT_ID IN (   '1211600050042' ,  '1211600050033'  ) THEN 'Cleveland Hts Ped' -- Cleveland Hts Ped
 WHEN PE.DEPARTMENT_ID IN (   '180587' ,  '180589'  ) THEN 'Concord Med/Ped' --Concord Med Ped
 WHEN PE.DEPARTMENT_ID IN (   '1211600110011' ,  '1211600110015'  ) THEN 'Fairlawn Med' -- Fairlawn Med
 WHEN PE.DEPARTMENT_ID IN (   '180596' ,  '180598'  ) THEN 'Kent Med/Ped' --Kent Med/Ped
 WHEN PE.DEPARTMENT_ID IN (   '180603' ,  '180605'  ) THEN 'Medina Med/Ped' --Medina Med/Ped
 WHEN PE.DEPARTMENT_ID IN (   '180580' ,  '180582'  ) THEN 'Mentor Med' -- Mentor Med
 WHEN PE.DEPARTMENT_ID IN (   '180583'   ) THEN 'Mentor Ped' -- Mentor Ped
 WHEN PE.DEPARTMENT_ID IN (   '180573' ,  '180575'  ) THEN 'North Canton Med/Ped' -- North Canton Med/Ped
 WHEN PE.DEPARTMENT_ID IN (   '1211600140054'  ) THEN 'Parma Med' -- Parma Med
 WHEN PE.DEPARTMENT_ID IN (   '1801600050089' ,  '1211600140067'  ) THEN 'Parma Ped' -- Parma Ped
 WHEN PE.DEPARTMENT_ID IN (   '180542' ,  '180544'  ) THEN 'Rocky River Med/Ped'  -- Rocky River Med/Ped 
 WHEN PE.DEPARTMENT_ID IN (   '1211600160004' ,  '1211600160009'  ,  '1201600160002'  ) THEN 'Strongsville Med/Ped' --Strongsville Med/Ped
 WHEN PE.DEPARTMENT_ID IN (   '1211600120007' ,  '1211600120010' ,  '180517'  ,  '1201600120001'   ) THEN 'Twinsburg Med/Ped' --Twinsburg Med/Ped
 WHEN PE.DEPARTMENT_ID IN (   '1211600060028' ,  '1201600060010'  ) THEN 'Willoughby Med' -- Willoughby Med
 ELSE  ''-- No Team
END AS "TEAM"


/*
1211600200002	Avon Med/Ped
1211600200003	Avon Med/Ped
1211600030012	Bedford Med
1201600030003	Bedford Ped
1211600030009	Bedford Ped
1211600100017	Chapel Hill Med
1211600100015	Chapel Hill Med
1201600100007	Chapel Hill Ped
1201600050014	Cleveland Hts Med
1211600050042	Cleveland Hts Ped
1211600050033	Cleveland Hts Ped
180587	Concord Med/Ped
180589	Concord Med/Ped
1211600110011	Fairlawn Med
1211600110015	Fairlawn Med
180596	Kent Med/Ped
180598	Kent Med/Ped
180603	Medina Med/Ped
180605	Medina Med/Ped
180580	Mentor Med
180582	Mentor Med
180583	Mentor Ped
180573	North Canton Med/Ped
180575	North Canton Med/Ped
1211600140054	Parma Med
1801600050089	Parma Ped
1211600140067	Parma Ped
180542	Rocky River Med/Ped
180544	Rocky River Med/Ped
1211600160004	Strongsville Med/Ped
1211600160009	Strongsville Med/Ped
1201600160002	Strongsville Med/Ped
1211600120007	Twinsburg Med/Ped
1211600120010	Twinsburg Med/Ped
180517	Twinsburg Med/Ped
1201600120001	Twinsburg Med/Ped
1211600060028	Willoughby Med
1201600060010	Willoughby Ped
*/

FROM

PAT_ENC PE

Left Outer Join 
PATIENT P				
ON 
PE.PAT_ID = P.PAT_ID

Left Outer Join
ZC_LANGUAGE ZL
ON
ZL.LANGUAGE_C = P.LANGUAGE_C


/* Language Table joinss */
Left Outer Join
PAT_SPOKEN_LANG PSL
ON
PSL.PAT_ID = PE.PAT_ID

Left Outer Join
ZC_LANGUAGE ZLS
ON
ZLS.LANGUAGE_C = PSL.PAT_SPOKEN_LANG_C
     
/* end of language joins*/


Left Outer Join 
CLARITY_SER CSER 	
ON 
PE.VISIT_PROV_ID = CSER.PROV_ID

Left Outer Join
ZC_STATE ZS 
ON
ZS.STATE_C = P.STATE_C

Left Outer Join 
COVERAGE COV		 	
ON	 
P.PRIM_CVG_ID=cov.COVERAGE_ID

LEFT OUTER JOIN
CLARITY_DEP CDEP
ON
PE.DEPARTMENT_ID = CDEP.DEPARTMENT_ID

LEFT OUTER JOIN
CLARITY_LOC CLOC_DEP ON
CLOC_DEP.LOC_ID = CDEP.REV_LOC_ID 

LEFT OUTER JOIN
CLARITY_PRC CP
ON
CP.PRC_ID = PE.APPT_PRC_ID

LEFT OUTER JOIN
CLARITY_SER CSER_PCP
ON
CSER_PCP.PROV_ID = P.CUR_PCP_PROV_ID

LEFT OUTER JOIN
ZC_APPT_STATUS ZAS
ON
ZAS.APPT_STATUS_C = PE.APPT_STATUS_C


LEFT OUTER JOIN
PATIENT_RACE PRACE
ON
PRACE.PAT_ID = P.PAT_ID

LEFT OUTER JOIN
ZC_PATIENT_RACE	 ZPR 
ON 
PRACE.PATIENT_RACE_C = ZPR.PATIENT_RACE_C


LEFT OUTER JOIN
	(
	SELECT
	PAT_ID,
	MIN( PCB.CVG_EFF_DATE) AS "Earliest_Date"
	FROM PAT_CVG_BEN_OT PCB
	--GROUP BY 1
	-- do not want dates of 01/01/1900
	-- as they're dummy values
	-- anything sooner should be ok
	WHERE 	
	PCB.CVG_EFF_DATE IS NOT NULL
	AND
	PCB.CVG_EFF_DATE >  '19000101'
	
	) AS PCBO
	ON
	PCBO.PAT_ID= PE.PAT_ID

WHERE


-- DO NOT REMOVE  PARENS UNLESS YOU KNOW WHAT YOU'RE DOING!!!!!!!
-- No, you probably don't know what you're doing. Just leave them alone.
-- Don't even think of moving the parens either
--
-- No it's not a good idea to put any of this into parameters in crystal. Too hard to validate
-- the complex logic and does not reduce time to make changes, plus it's portable and
-- can be dropped back into teradata tools.
--
(
                   (                   
                    PE.CONTACT_DATE >=   getdate() - 1 --{?Report Days}
                    AND PE.CONTACT_DATE <= getdate()
                    AND 
                    PE.APPT_STATUS_C IN ('2','6') -- We only want Encounters with an  APPT_STATUS of 2  or 6
					AND
					(	
					-- OU0101 PT, OT, ST
					-- ER01010 Urgent Care and Emergency (for MD providers)
					-- MD0101 		
					-- No generic providers for these groups			
					  -- Generally will include Office Visit, Appointments.  OB Office Visit,  and Procedure					
					  -- NO Addiction medicine !!!! Specialty 1201
					  -- NO Behavioral Health !!! Specialty 1207
					  -- NO Pyschiatry -- 12078
					  -- NO Psychology  -- 12080
					  -- 
					   (      CDEP.SPECIALTY_DEP_C  NOT IN ( '12017','120101','12038', '12083','1215', '1201','1207','12078','12080','12097'   ) AND 
								    PE.ENC_TYPE_C IN ( 
										   '101', --     Office Visit	
										   '50', --		Appointment	50	
										   '121250',  --	 OB Office Visit	121250	
										   '121222'  -- Procedure Only '121222'
					         		 )	
					         		 -- Generic Exlcusions
					         		 -- CSER.REF_SRC_
					         		 AND
					         		 ( 
					         		  -- effectively this clause filters  out encounters where the provider is generic
					         		  -- Assuming generic is a provider is who is "Non Referral Source" AND has no SEX designator (male/female)
					         		  -- NOTE: including a few provider that appear to be bogus (generic providers listed as "provider" in ref source
					         		  -- provider records that are not "Non Referral Source" are generally NOT generic (aka "provider")
					         		  (
					         		   CSER.REFERRAL_SRCE_TYPE <> 'Non Referral Source'  OR CSER.REFERRAL_SRCE_TYPE IS NULL 
					         		   OR 
					         		   CSER.SEX  IN ('1','2')  -- If provider record says you're male or female then we assume you're not generic provider
					         		  )
					         		  
					         		   -- these generic providers are not listed as non referral sources / probably they're bum records
					         		   -- but regardless, we're going to filter them out
					         		   --	180136397	OSTEOPOROSIS CLASS WLBY
										-- 180135403	MEDICARE WELLNESS PARMA
										-- 180134836	OSTEOPOROSIS CLASS PARMA
										-- 180135402	MEDICARE WELLNESS CLHTS
										-- 180135377	OSTEOPOROSIS CLASS CLHTS
					         		   AND CSER.PROV_ID NOT IN ( '180136397', '180135403', '180134836', '180135402', '180135377' )
					         		 
					         		 ) -- end of AND clause for generic provider exclusions
					         		 
					         		 
					         		 		          
					    ) 
					OR
					 -- ER0101 - Emergency Room Doctors 
					 -- Only include live bodies, no generics 
					 -- APPT TYPE 101 and Specialty in (12017, 120101) 
					 -- 
						(     PE.ENC_TYPE_C = '101'	 
						      AND
							  CDEP.SPECIALTY_DEP_C IN (  
											'12017' ,   -- Emergency  Medicine
						 					'120101'   -- Urgent Care
										    ) 
						         		 -- Generic Exlcusions
					         		 -- CSER.REF_SRC_
					         		 AND
					         		 ( 
					         		  -- effectively this clause filters  out encounters where the provider is generic
					         		  -- Assuming generic is a provider is who is "Non Referral Source" AND has no SEX designator (male/female)
					         		  -- NOTE: including a few provider that appear to be bogus (generic providers listed as "provider" in ref source
					         		  -- provider records that are not "Non Referral Source" are generally NOT generic (aka "provider")
					         		  (
					         		   CSER.REFERRAL_SRCE_TYPE <> 'Non Referral Source'  OR CSER.REFERRAL_SRCE_TYPE IS NULL 
					         		   OR 
					         		   CSER.SEX  IN ('1','2')  -- If provider record says you're male or female then we assume you're not generic provider
					         		  )
					         		  
					         		   -- these generic providers are not listed as non referral sources / probably they're bum records
					         		   -- but regardless, we're going to filter them out
					         		   --	180136397	OSTEOPOROSIS CLASS WLBY
										-- 180135403	MEDICARE WELLNESS PARMA
										-- 180134836	OSTEOPOROSIS CLASS PARMA
										-- 180135402	MEDICARE WELLNESS CLHTS
										-- 180135377	OSTEOPOROSIS CLASS CLHTS
					         		   AND CSER.PROV_ID NOT IN ( '180136397', '180135403', '180134836', '180135402', '180135377' )
					         		 
					         		 ) -- end of AND clause for generic provider exclusions
					
		
					    ) -- end of ER0101 
					   					    
					       -- OU0102 radiology 
					       -- ENC_TYPE_C = '50'
					       -- Send all providers for radiology including generics
					       -- only want appointments for radiology   
					      OR
					       ( 
					       PE.ENC_TYPE_C = '50'	AND
					       CDEP.SPECIALTY_DEP_C IN ( '12038', '12083','1215' ) 			     					      
					      )    -- end of or for radiology
					    
					    	-- AS0101 Ambulatory Surgery
					       -- Speciality 12097
					       -- Send all providers including generics

					      OR
					       ( 
					       CDEP.SPECIALTY_DEP_C IN ( '12097' ) 			     					      
							AND 
								    PE.ENC_TYPE_C IN ( 
										   '101', --     Office Visit	
										   '50', --		Appointment	50	
										   '121222'  -- Procedure Only '121222'
					          )			          

					       
					      )    -- end of  AS0101 / 12097 Amb Surg clause
					    
					    
					    
	
						)
						
						

						
						) 
						
				-- Per the BP 1/6/2014 - Don't need hospitalist encounters anymore
				-- we only want to look at hospitalist encounters  if they're older than 14 days
				-- Hospital Services Encounters don't have APPT_STATUS (it's null) so you have to
				-- directly ask for those. Also we don't care about appt status with these
/*					OR
					(
						( PE.CONTACT_DATE >= current_date - 4 - 14 AND PE.CONTACT_DATE <= current_date -14)
						AND PE.ENC_TYPE_C = '1805' -- Hospital Services		
					)*/
											    				  

)

AND  (PRACE.LINE IS NULL  OR PRACE.LINE = 1 )

AND ( P.PAT_STATUS = 'Alive' OR P.PAT_STATUS IS NULL )

-- exclude test patients
AND P.PAT_ID NOT IN  ( SELECT PT.PAT_ID FROM PATIENT_TYPE PT  WHERE PT.PATIENT_TYPE_C = '1214' )


UNION -- UNION causes a DISTINCT operation  to be applied to the entire  result set

--
-- This next section produces a set of records that show the PA who worked
-- with a patient. We're basing this on the premise that the PA is the one who
-- created a note. The output is exactly the same as the encounter detail above
-- except we're putting the PA in place of the visit provider
--

SELECT
DISTINCT -- Have to do distinct because of looking at ENI note table
--pe.PAT_ENC_CSN_ID

--PRACE.*

PE.PAT_ENC_CSN_ID
,'ER0102' AS "SERVICE_DESIGNATOR"
,ZPR.NAME AS "RACE"
--P.PAT_NAME
,P.PAT_LAST_NAME
,P.PAT_FIRST_NAME
,P.PAT_MIDDLE_NAME
--,(CURRENT_DATE -  CAST(p.BIRTH_DATE AS DATE) ) /365.25  as AGE
--,  CAST (   (current_date -  CAST(p.BIRTH_DATE AS DATE) ) /365.25  AS INT)                  as  "AGE"
,P.BIRTH_DATE
,P.SEX
--,P.PAT_STATUS
,P.ADD_LINE_1
,P.ADD_LINE_2
,P.CITY
,ZS.ABBR AS "STATE"
,P.ZIP
,P.HOME_PHONE
,P.EMAIL_ADDRESS
,ZL.NAME AS "LANG"
--,ZPWL.NAME AS "WRITTEN_LANG"
,ZLS.NAME AS "SPOKEN_LANG"
,PE.CONTACT_DATE 
,CLOC_DEP.LOC_ID
,CLOC_DEP.LOC_NAME
--,pe.VISIT_PROV_ID
,CEMP.PROV_ID AS "VISIT_PROV_ID"-- This one is really the PA Provider
,PE.DEPARTMENT_ID
,CDEP.DEPARTMENT_NAME
,CDEP.SPECIALTY
,CSER_PCP.PROV_ID as "PCP PROV_ID"

--,pe.ENC_CLOSED_YN
,PE.APPT_STATUS_C
,P.PAT_MRN_ID

 -- coverage from PAT_CVG_BEN_OT
 ,COV.CVG_EFF_DT
 --,pcbo.PAT_ID
 ,PCBO.EARLIEST_DATE
 ,ZAS.NAME			-- Appt Status name

,CEMP.NAME AS  "VISITPROVNAME"
,'' as "VISITPROVTYPE"
--,CSER.PROV_NAME as "VISITPROVNAME"
,CSER_PCP.PROV_NAME as "PCPPROVIDERNAME"

,PE.ENC_TYPE_TITLE

-- We're  flagging the type of visit by PA , Hosptialist,  APPT
,'PA' AS "CONTACT_TYPE"

,CP.PRC_NAME
,PE.CHECKIN_TIME
,PE.CHECKOUT_TIME
,'' AS "TEAM"

--,  Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))

--,CSER.PROV_NAME

FROM

PAT_ENC PE

Left Outer Join 
PATIENT P				
ON 
PE.PAT_ID = P.PAT_ID

Left Outer Join
ZC_LANGUAGE ZL
ON
ZL.LANGUAGE_C = P.LANGUAGE_C

/* Language Table joins */
Left Outer Join
PAT_SPOKEN_LANG PSL
ON
PSL.PAT_ID = PE.PAT_ID

Left Outer Join
ZC_LANGUAGE ZLS
ON
ZLS.LANGUAGE_C = PSL.PAT_SPOKEN_LANG_C

/* end of language joins*/

Left Outer Join 
CLARITY_SER CSER 	
ON 
PE.VISIT_PROV_ID = CSER.PROV_ID

Left Outer Join 
COVERAGE COV		 	
ON	 
P.PRIM_CVG_ID = COV.COVERAGE_ID

Left Outer Join
ZC_STATE ZS 
ON
ZS.STATE_C = P.STATE_C

LEFT OUTER JOIN
CLARITY_DEP CDEP
ON
PE.DEPARTMENT_ID = CDEP.DEPARTMENT_ID

LEFT OUTER JOIN
CLARITY_LOC CLOC_DEP ON
CLOC_DEP.LOC_ID = CDEP.REV_LOC_ID 

LEFT OUTER JOIN
CLARITY_PRC CP
ON
CP.PRC_ID = PE.APPT_PRC_ID

LEFT OUTER JOIN
CLARITY_SER CSER_PCP
ON
CSER_PCP.PROV_ID = P.CUR_PCP_PROV_ID

LEFT OUTER JOIN
ZC_APPT_STATUS ZAS
ON
ZAS.APPT_STATUS_C = PE.APPT_STATUS_C

LEFT OUTER JOIN
	(
	SELECT
	PAT_ID,
	MIN( PCB.CVG_EFF_DATE) AS "Earliest_Date"
	FROM PAT_CVG_BEN_OT PCB
	--GROUP BY 1
	-- do not want dates of 01/01/1900
	-- as they're dummy values
	-- anything sooner should be ok
	WHERE 	
	PCB.CVG_EFF_DATE IS NOT NULL
	AND
	PCB.CVG_EFF_DATE >  '19000101'
	) AS PCBO
	ON
	PCBO.PAT_ID = PE.PAT_ID
	
/*INNER  JOIN
ENC_NOTE_INFO ENI
ON
ENI.PAT_ENC_CSN_ID = PE.PAT_ENC_CSN_ID*/

INNER JOIN
HNO_INFO HI 
ON
HI.PAT_ENC_CSN_ID = PE.PAT_ENC_CSN_ID

INNER JOIN
NOTE_ENC_INFO NEI
ON
NEI.NOTE_ID = HI.NOTE_ID


LEFT OUTER JOIN
CLARITY_EMP CEMP
ON
CEMP.USER_ID = NEI.AUTHOR_USER_ID	


LEFT OUTER JOIN
PATIENT_RACE PRACE
ON
PRACE.PAT_ID = P.PAT_ID

LEFT OUTER JOIN
ZC_PATIENT_RACE	 ZPR 
ON 
PRACE.PATIENT_RACE_C = ZPR.PATIENT_RACE_C
	
WHERE
PE.CONTACT_DATE >= getdate() -1 --- {?Report Days}

AND
PE.CONTACT_DATE <= getdate()
AND
(
  -- Must include these types of visits. Using the category values to avoid being affected by
 -- changes in the  text
--     Office Visit	101	

        PE.ENC_TYPE_C IN ( '101')
)
-- We only want Encounters with an  APPT_STATUS of 2 or 6
AND
(
		PE.APPT_STATUS_C IN (  '2', '6')
)
AND
(
P.PAT_STATUS = 'Alive'
OR
P.PAT_STATUS IS NULL
)
AND
	NEI.AUTHOR_PRVD_TYPE_C = '12047'

AND 
(PRACE.LINE IS NULL OR PRACE.LINE = 1)

AND
CDEP.SPECIALTY_DEP_C IN ( 
	 '12017' ,   -- Emergency  Medicine
	 '120101'   -- Urgent Care
 ) 
 
 -- exclude test patients
AND P.PAT_ID NOT IN   ( SELECT PT.PAT_ID FROM PATIENT_TYPE PT  WHERE PT.PATIENT_TYPE_C = '1214' )

-- Do NOT like putting depts in like this. last minute change to accomodate how
-- specialties are being used
/*CDEP.DEPARTMENT_ID IN (
'1801600050075' , 
'1801600050076' , 
--'1201600070001', NO CCF
 '1201600140034',
 '1201600140035',
 '180636' ,
 '180637',
 '1211600140087' ,
 '180521'
)*/

/*
1801600050075	EMER CL HTS
1801600050076	CDU CL HTS
1201600140034	CDU PARMA
1201600140035	EMER PARMA
180636	EMERGENCY SVC PARMA
180637	EMERGENCY SVC CL HTS
1211600140087	UCC PARMA
180521	UCC CLHTS
*/

) AS PG

--group by 1,2,3,4,5,6,7,8,9,10

--ORDER BY 1
ORDER BY "SURVEY","UNIQUE_ID"
