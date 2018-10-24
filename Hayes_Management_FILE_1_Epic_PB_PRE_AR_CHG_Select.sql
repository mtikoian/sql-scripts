
-- FILE_1_Epic_PB_PRE_AR_CHG_Select
--	NOTES : 
		-- 1. Use script to create Pipe delimited file with header record 
			-- Filename = 'clientname_CCYYMMDD_HEADER.txt'
		-- 2. HARDCODE Charge Review Work Queue #s in 'FROM' statement
		-- 3. HARDCODE 'ClientId' column per MDEnterprixe client code
		-- 4. HARDCODE BillingProvFirstName with name of hospital or university.  I.e., 'XYZ Universtiy Hospital'
		-- 5. For 'BillingProviderNPI', are using table CL_EAF_ID (rev ids) to derive the 'organizational NPI'.  Note that this could differ between clients.
			  -- Use a default NPI provided by the client, as the CL_EAF is not always set up per LOC_ID
		-- 6. HARDCODE LEFT JOIN dbo.CL_EAF_ID	qualifier for MPI_ID_TYPE_ID (2 places)
		-- 7. mapping TAR_ID into ProspectiveClaimId and PatientAcctNo (info)
		-- 8. CFI code derivation by mapping values from Epic table ZC_FIN_CLASS to standard CFI codes
			/* Execute this query on Client Epic system to get table values
				select
				TITLE,ABBR
				from ZC_FIN_CLASS
				order by TITLE
			*/

SELECT DISTINCT 
						'24' as ClientId,
						CHG.TAR_ID AS ProspectiveClaimId,	-- Unique identifier to link  3 files
						'P' As ClaimType,						-- Professional

						-- Billing provider 
						CASE 
							WHEN ISNULL(EAF.MPI_ID,'') <> '' THEN EAF.MPI_ID
							ELSE '1205887023'
						END AS [BillingProviderNPI],		-- 2010AA — BILLING PROVIDER NAME (Organization)
						BillingProvFirstName = '',
						BillingProvLastName = null,

						-- Attending provider <for now the same as Rendering below>
						NULL AS [AttendingProviderNPI],		-- Use only for inpatient 
						AttendingProvFirstName = NULL,
						AttendingProvLastName = NULL,

						--Rendering provider <USE INDIVIDUAL 'BILLING PROV'>
						SER2.[NPI]  AS [RenderingProviderNPI],-- Use only if different from billing provider ??
						RenderingProvFirstName = CASE
							WHEN (CHARINDEX(', ',SER.PROV_NAME) > 0) THEN
								convert(varchar(30),RTRIM(SUBSTRING(SER.PROV_NAME,CHARINDEX(', ',SER.PROV_NAME)+2,LEN(SER.PROV_NAME) - CHARINDEX(', ',SER.PROV_NAME))))
							WHEN (CHARINDEX(',',SER.PROV_NAME) > 0) THEN
								convert(varchar(30),RTRIM(SUBSTRING(SER.PROV_NAME,CHARINDEX(',',SER.PROV_NAME)+1,LEN(SER.PROV_NAME) - CHARINDEX(',',SER.PROV_NAME))))
							ELSE
								NULL
						END,
						RenderingProvLastName = CASE
							WHEN (CHARINDEX(',',SER.PROV_NAME) > 0) THEN
								convert(varchar(30),RTRIM(LEFT(SER.PROV_NAME,CHARINDEX(',',SER.PROV_NAME)-1)))
							ELSE
								convert(varchar(30),RTRIM(SER.PROV_NAME))
						END,

						--Referring provider
						SER2_C.[NPI] AS [ReferringProviderNPI],
						ReferringProvFirstName = CASE
							WHEN (CHARINDEX(', ',SER_C.PROV_NAME) > 0) THEN
								convert(varchar(30),RTRIM(SUBSTRING(SER_C.PROV_NAME,CHARINDEX(', ',SER_C.PROV_NAME)+2,LEN(SER_C.PROV_NAME) - CHARINDEX(', ',SER_C.PROV_NAME))))
							WHEN (CHARINDEX(',',SER_C.PROV_NAME) > 0) THEN
								convert(varchar(30),RTRIM(SUBSTRING(SER_C.PROV_NAME,CHARINDEX(',',SER_C.PROV_NAME)+1,LEN(SER_C.PROV_NAME) - CHARINDEX(',',SER_C.PROV_NAME))))
							ELSE
								NULL
						END,
						ReferringProvLastName = CASE
							WHEN (CHARINDEX(',',SER_C.PROV_NAME) > 0) THEN
								convert(varchar(30),RTRIM(LEFT(SER_C.PROV_NAME,CHARINDEX(',',SER_C.PROV_NAME)-1)))
							ELSE
								convert(varchar(30),RTRIM(SER_C.PROV_NAME))
						END,

						--Operating provider
						NULL AS OperatingProviderNPI,
						NULL AS OperatingProvFirstName,
						NULL AS OperatingProvLastName,

						ServiceFromDate = (select MIN(SERVICE_DATE) from dbo.PRE_AR_CHG CHG2 where CHG2.TAR_ID=CHG.TAR_ID),
						ServiceToDate = (select MAX(SERVICE_DATE) from dbo.PRE_AR_CHG CHG2 where CHG2.TAR_ID=CHG.TAR_ID),
						--CHG.SERVICE_DATE AS ServiceFromDate,
						--CHG.SERVICE_DATE AS ServiceToDate,
						PATIENT.PAT_MRN_ID AS PatientMRN,
						CHG.TAR_ID AS PatientAcctNo,  --UCL.ACCOUNT_ID AS PatientAcctNo OR COV.MEM_NUMBER (member number)
						PATIENT.PAT_ID AS PatientId,
						PATIENT.PAT_FIRST_NAME AS PatientFirst,   
						PATIENT.PAT_MIDDLE_NAME AS PatientMiddle,  
						PATIENT.PAT_LAST_NAME AS PatientLast,    
						PATIENT.BIRTH_DATE AS PatientDOB, 
						CASE PATIENT.SEX_C         
								WHEN '1' THEN 'F'	---Female 
								WHEN '2' THEN 'M'	---Male
								WHEN '3' THEN 'U'	---Unknown
								WHEN '4' THEN 'OTH' --- Other
						END AS PatientSex,           
						EPM.[PAYOR_NAME] AS PrimaryPayerName,
						EPM.[PAYOR_ID] AS PrimaryPayerCode, 
						--Custom way of deriving a partial 'CFI' per client.  We use both fields in case of table updates
						PrimaryPayerCFI = CASE 
							WHEN FIN_CL.TITLE like 'BLUE SHIELD%'		or FIN_CL.ABBR like 'BS' then 'BL'
							WHEN FIN_CL.TITLE like 'BX MANAGED%'		or FIN_CL.ABBR like 'BX MNGD' then 'BL'
							WHEN FIN_CL.TITLE like 'BX TRADITIONAL%'	or FIN_CL.ABBR like 'BX TRAD' then 'BL'
							WHEN FIN_CL.TITLE like 'CHAMPVA%'			or FIN_CL.ABBR like 'CVA' then 'VA'
							WHEN FIN_CL.TITLE like 'COMMERCIAL%'		or FIN_CL.ABBR like 'COMM' then 'CI'
							WHEN FIN_CL.TITLE like 'DK REGIONAL%'		or FIN_CL.ABBR like 'DK Reg' then 'CI'
							WHEN FIN_CL.TITLE like 'FECA BLACK LUNG%'	or FIN_CL.ABBR like 'FECA BL' then 'FI'
							WHEN FIN_CL.TITLE like 'GROUP HEALTH PLAN%' or FIN_CL.ABBR like 'GHP' then 'CI'
							WHEN FIN_CL.TITLE like 'H1N1%'				or FIN_CL.ABBR like 'H1N1' then 'CI'
							WHEN FIN_CL.TITLE like 'MANAGED CARE%'		or FIN_CL.ABBR like 'MNGD CARE' then 'CI'
							WHEN FIN_CL.TITLE like 'MEDICAID'			or FIN_CL.ABBR like 'CAID' then 'MC'
							WHEN FIN_CL.TITLE like 'MEDICAID MANAGED%'	or FIN_CL.ABBR like 'MG CAID' then 'MC'
							WHEN FIN_CL.TITLE like 'MEDICARE'			or FIN_CL.ABBR like 'CARE'then 'MB'
							WHEN FIN_CL.TITLE like 'MEDICARE MANAGED%'	or FIN_CL.ABBR like 'MG MCARE' then 'MB'
							WHEN FIN_CL.TITLE like 'MEDIGAP%'			or FIN_CL.ABBR like 'MGAP' then 'CI'
							WHEN FIN_CL.TITLE like 'OTHER%'				or FIN_CL.ABBR like 'Other' then 'CI'
							WHEN FIN_CL.TITLE like 'PENDING MEDICAID%'	or FIN_CL.ABBR like 'Pending Medi' then 'MC'
							WHEN FIN_CL.TITLE like 'SELF-PAY%'			or FIN_CL.ABBR like 'SELF' then '09'
							WHEN FIN_CL.TITLE like 'SPLIT FEE PRICING FINANCIAL CLASS%' or FIN_CL.ABBR like 'Split Fee Pr' then 'CI'
							WHEN FIN_CL.TITLE like 'TRANSPLANT%'		or FIN_CL.ABBR like 'Transplant' then 'CI'
							WHEN FIN_CL.TITLE like 'TRICARE%'			or FIN_CL.ABBR like 'TCE' or FIN_CL.ABBR like '' then 'OF'
							WHEN FIN_CL.TITLE like 'WORKER%COMP%'		or FIN_CL.ABBR like 'WC' then 'WC'
							ELSE NULL
							END, 
						NULL AS SecondaryPayer, 
						NULL AS SecondaryPayerCode, 
						NULL AS SecondaryPayerCFI, 
						NULL AS TertianaryPayer, 
						NULL AS TertianaryPayerCode, 
						NULL AS TertianaryPayerCFI, 
						NULL AS DRG, 
						NULL AS AdmitType, 
						NULL AS DischargeStatus,  
						NULL AS AdmitDX,  
						LOC.LOC_NAME AS  Facility_Location,
						CHG.CODER_USER_ID AS CoderId,  
						CoderName = CASE
							WHEN ISNULL(EMP.name,'')<>'' THEN  EMP.name
							WHEN ISNULL(EMP2.name,'')<>'' THEN EMP2.name
							ELSE null
						END,
						--OPTIONAL CODER derivations- Depends where this is stored per client
						--CHG_REV.CHGENTRY_CODER_ID,
						--charge entry not Coder : CHG.ENTER_USER_ID as chargeEnterId,	EMP3.NAME AS chargeEnterName,
						--optional coder location : ARPB_CS_CH_GEN_ITM.CATEGORY_ITEM_3_C AS CODER_ID, 
						POS.POS_CODE AS PlaceOfService,
						WQI.WORKQUEUE_NAME AS WorkQueName,
						WQ.WQF_QUEUE_ID AS WorkQueId
						--4 new fields 8-28-2018
						,RSH.NCT_NUM as ClinicalTrialIdentifier
						,case 
							when isnull(REF_CVG.CARRIER_AUTH_CMT,'')<>'' then REF_CVG.CARRIER_AUTH_CMT
							when isnull(REF_CVG.EFF_CVG_PRECERT_NUM,'')<>'' then REF_CVG.EFF_CVG_PRECERT_NUM
						else null end as PriorAuthorizationNo
						,NULL as InvestDeviceExmptNo			-- Keep as placeholder for future need
						,REFERRAL.EXTERNAL_ID_NUM AS ReferralNo

FROM
						(
							SELECT  TAR_ID,MIN(WQF_QUEUE_ID) AS WQF_QUEUE_ID
							FROM   dbo.CHG_REVIEW_WORKQUE WQ_INT
							WHERE WQ_INT.WQF_QUEUE_ID in 
											(
											 '1665'
											,'14557'
											,'14583'
											,'14591'
											,'14592'
											,'14594'
											,'14596'
											,'14600'
											,'22457'
											,'22458'
											,'22904'
											,'22906'
											,'22907'
											,'22908'
											,'22910'
											,'24987'
											,'24988'
											,'24989'
											,'24990'
											,'24992'
											,'27109'
											,'27110'
											,'27112'
											,'27113'
											,'27492'
											,'27496'
											,'27497'
											,'27502'
											,'27504'
											)		--******CLIENT SPECIFIC Charge Review Work Queues HARDCODED ***********
							GROUP BY TAR_ID 
						) AS WQ

						-- Get the WorkQueue_Name
						LEFT  JOIN WORKQUEUE_INFO WQI ON WQI.WORKQUEUE_ID = WQ.WQF_QUEUE_ID

                        INNER JOIN dbo.PRE_AR_CHG CHG ON (WQ.TAR_ID = CHG.TAR_ID)

                        INNER JOIN dbo.PRE_AR_CHG_2 CHG2 ON CHG.TAR_ID = CHG2.TAR_ID AND CHG.CHARGE_LINE = CHG2.CHARGE_LINE 
								
                        INNER JOIN dbo.PATIENT ON CHG.PAT_ID = PATIENT.PAT_ID

						LEFT JOIN dbo.CLARITY_EPM EPM ON EPM.PAYOR_ID = CHG.PAYOR_ID
						
						--'billing provider' should be ORGANIZATION, EDI 837 2010AA						
						LEFT JOIN dbo.CLARITY_SER SER ON SER.[PROV_ID] = CHG.BILL_PROV_ID
						LEFT JOIN dbo.CLARITY_SER_2 SER2 ON SER.PROV_ID = SER2.PROV_ID
						
						-- performing or Rendering provider	Can be different PERF_PROV_ID per CHG LINE so use provider from 'first' LINE
						LEFT JOIN dbo.PRE_AR_CHG PARG ON PARG.TAR_ID = CHG.TAR_ID AND 
															PARG.CHARGE_LINE = (select min(CHARGE_LINE)
															from dbo.PRE_AR_CHG 
															where dbo.PRE_AR_CHG.TAR_ID = CHG.TAR_ID 
															)
						LEFT JOIN dbo.CLARITY_SER SER_B ON SER_B.PROV_ID = PARG.PERF_PROV_ID
						LEFT JOIN dbo.CLARITY_SER_2 SER2_B ON SER_B.PROV_ID = SER2_B.PROV_ID

						-- referring provider
						LEFT JOIN dbo.CLARITY_SER SER_C ON SER_C.PROV_ID = CHG.REFERRING_PROV_ID
						LEFT JOIN dbo.CLARITY_SER_2 SER2_C ON SER_C.PROV_ID = SER2_C.PROV_ID
						
                        INNER JOIN dbo.CLARITY_EAP EAP ON CHG.PROC_ID = EAP.PROC_ID

						-- POS (Place of Service)
						-- for 'header' record, use the first CHG_REV LINE for deriving POS and Member Number
						INNER JOIN dbo.CHG_REVIEW CHG_REV ON CHG.TAR_ID = CHG_REV.TAR_ID 
															AND CHG_REV.LINE = (select min(CR.LINE) 
																				from dbo.CHG_REVIEW CR 
																				where CHG.TAR_ID = CR.TAR_ID
																				)

						LEFT JOIN dbo.CLARITY_POS POS ON CHG_REV.CHARGE_POS_ID = POS.POS_ID

						-- Logic to Join in User Comment information
                        LEFT JOIN dbo.CLARITY_UCL UCL ON  CHG2.CHRG_ROUTER_SRC_ID = UCL.UCL_ID

						-- Logic to Join in Coder Information-- DEPENDENT on where client stores Coder info
						LEFT JOIN dbo.CLARITY_EMP emp ON UCL.CE_CODER_ID = EMP.user_id
						LEFT JOIN dbo.CLARITY_EMP emp2 ON CHG.CODER_USER_ID = EMP2.user_id
						LEFT JOIN dbo.CLARITY_EMP emp3 ON CHG.ENTER_USER_ID = EMP3.user_id	--optional join
								
						-- some clients may want coder info from these tables <OPTIONAL IF NECESSARY>
                        LEFT JOIN dbo.ARPB_CS_CH_GEN_ITM ARPB_CS_CH_GEN_ITM ON CHG.TAR_ID = ARPB_CS_CH_GEN_ITM.TAR_ID

                        LEFT JOIN dbo.ZC_CATEGORY_ITEM_3 ZC_CATEGORY_ITEM_3 ON ARPB_CS_CH_GEN_ITM.CATEGORY_ITEM_3_C = ZC_CATEGORY_ITEM_3.CATEGORY_ITEM_3_C

						-- CFI information (summary)
						LEFT OUTER JOIN dbo.ZC_FIN_CLASS FIN_CL ON FIN_CL.INTERNAL_ID = EPM.FINANCIAL_CLASS

						-- Location								
						LEFT JOIN dbo.CLARITY_LOC LOC ON CHG.LOC_ID = LOC.LOC_ID

						-- Group NPI
						LEFT JOIN dbo.CL_EAF_ID EAF ON EAF.FACILITY_ID = CHG.LOC_ID AND EAF.MPI_ID_TYPE_ID  = 100002 AND EAF.LINE = 
                                                       (select max(LINE) from CL_EAF_ID EAF2 where EAF2.FACILITY_ID = CHG.LOC_ID AND EAF2.MPI_ID_TYPE_ID  = 100002 )

						-- MEMBER NUMBER.  Multiple coverages and expired coverages.  Use the most 'recent' coverage
						LEFT JOIN dbo.COVERAGE_MEM_LIST COV ON COV.COVERAGE_ID = CHG_REV.COVERAGE_ID AND COV.PAT_ID = PATIENT.PAT_ID
																AND COV.LINE = ( SELECT MAX(LINE)
																				FROM COVERAGE_MEM_LIST
																				WHERE COVERAGE_ID=CHG_REV.COVERAGE_ID AND PAT_ID=PATIENT.PAT_ID
																				)

						---- use this for initiating one instance of a REFERRAL.  PAT_ENC_CSN_ID is a unique system generated ID for the Patient Encounter table PAT_ENC
						LEFT JOIN dbo.PAT_ENC PAT_ENC ON PAT_ENC.PAT_ENC_CSN_ID = CHG_REV.PAT_ENC_CSN_ID

						--	'using table AUTHORIZATIONS was causing duplicates'.  As alternative, use table REFERRAL_CVG to get auth #s.
						
						--REFERALL NUM (also incluses CARRIER_AUTH_CMT)									
						LEFT JOIN dbo.REFERRAL_CVG REF_CVG on
															REF_CVG.REFERRAL_ID = PAT_ENC.REFERRAL_ID AND
															REF_CVG.CVG_ID = PAT_ENC.COVERAGE_ID

						-- REFERRAL NUMBER
						LEFT JOIN dbo.REFERRAL REFERRAL on REFERRAL.REFERRAL_ID = PAT_ENC.REFERRAL_ID 

						--Clinical Trial # aka ‘Demonstration project indentifier’ or Medicare demonstration project
						LEFT JOIN  CLARITY_RSH RSH on RSH.RESEARCH_ID =  CHG.RESEARCH_STUDY_ID
WHERE                   CHG.CHARGE_STATUS_C IN (3,5)  --3 = 'In Review' or 5 = 'Created'

				







