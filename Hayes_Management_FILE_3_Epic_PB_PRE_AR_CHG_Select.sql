--FILE_3_Epic_PB_PRE_AR_CHG_Select_
--	NOTES : 
		-- 1. Use script to create Pipe delimited file with header record
			-- Filename = 'clientname_CCYYMMDD_LINE.txt'
		-- 2. HARDCODE Charge Review Work Queue #s in 'FROM' statement
		-- 3. HARDCODE 'ClientId' column per MDEnterprixe client code
		-- 4. [EPIC_UTIL].[EFN_PIECE] needs to be accessible


SELECT DISTINCT 
							'24' as ClientId,
							CHG.TAR_ID AS ProspectiveClaimId,		-- Unique identifier to link  3 files
							CHG.CHARGE_LINE AS LinePos,
							NULL AS RevCode, 
							EAP_OT.CPT_CODE AS HCPCS,
							MOD1.EXT_MODIFIER AS MODIFIER1,
							MOD2.EXT_MODIFIER AS MODIFIER2,
							MOD3.EXT_MODIFIER AS MODIFIER3,
							MOD4.EXT_MODIFIER AS MODIFIER4,						
							CHG2.DX_ID AS DxMapDelim,
							-- ** Usage With [EPIC_UTIL].[EFN_PIECE] Built in function ** 
							DxMap1 = NULLIF([EPIC_UTIL].[EFN_PIECE](DX_ID,',',1),''), 
							DxMap2 = NULLIF([EPIC_UTIL].[EFN_PIECE](DX_ID,',',2),''),
							DxMap3 = NULLIF([EPIC_UTIL].[EFN_PIECE](DX_ID,',',3),''),
							DxMap4 = NULLIF([EPIC_UTIL].[EFN_PIECE](DX_ID,',',4),''),
							-- ** Usage With [EPIC_UTIL].[EFN_PIECE] Built in function  END ** 
						
							CHG.SERVICE_DATE AS ServiceDate,
							CHG.SERVICE_DATE As ServiceThruDate,
							CHG.QTY As Units,
							CHG.AMOUNT AS Charges,
							POS.POS_CODE AS PlaceOfService,
							NULL AS NDC,
							NULL AS NDCUnits,
							NULL AS NDCRx,
							Null AS NDCUnitQualifier,
							SER2_B.NPI AS RenderingProvNPI, -- further tdb
							NULL AS CoderId,
							NULL AS CodeName,
							EAP.PROC_CODE AS ClientProcedureCode,
							EAP.PROC_NAME AS ClientProcedureName
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
										    ,'27493'
											,'27503'
											,'27505'
											,'27501'
											)		--******CLIENT SPECIFIC Charge Review Work Queues HARDCODED ***********
							GROUP BY TAR_ID 
						) AS WQ

                                INNER JOIN dbo.PRE_AR_CHG CHG ON (WQ.TAR_ID = CHG.TAR_ID)

                                INNER JOIN dbo.PRE_AR_CHG_2 CHG2 ON 
													CHG.TAR_ID = CHG2.TAR_ID AND 
													CHG.CHARGE_LINE = CHG2.CHARGE_LINE 

                                INNER JOIN  dbo.PATIENT ON (CHG.PAT_ID = PATIENT.PAT_ID)

								LEFT JOIN dbo.CLARITY_EPM EPM ON EPM.PAYOR_ID = CHG.PAYOR_ID
												
								LEFT JOIN dbo.CLARITY_SER SER_B ON SER_B.PROV_ID = CHG.PERF_PROV_ID

								LEFT JOIN dbo.CLARITY_SER_2 SER2_B ON SER_B.PROV_ID = SER2_B.PROV_ID

								INNER JOIN  dbo.CLARITY_EAP EAP ON (CHG.PROC_ID = EAP.PROC_ID)

                                LEFT JOIN dbo.CHG_REVIEW_MODS MOD1 ON
                                                    MOD1.TAR_ID = CHG.TAR_ID AND
                                                    MOD1.LINE_COUNT = CHG.CHARGE_LINE AND
                                                    MOD1.MOD_LINE_COUNT = 1

                                LEFT JOIN dbo.CHG_REVIEW_MODS MOD2 ON
                                                    MOD2.TAR_ID = CHG.TAR_ID AND
                                                    MOD2.LINE_COUNT = CHG.CHARGE_LINE AND
                                                    MOD2.MOD_LINE_COUNT = 2
                                LEFT JOIN dbo.CHG_REVIEW_MODS MOD3 ON
                                                    MOD3.TAR_ID = CHG.TAR_ID AND
                                                    MOD3.LINE_COUNT = CHG.CHARGE_LINE AND
                                                    MOD3.MOD_LINE_COUNT = 3

								LEFT JOIN  dbo.CHG_REVIEW_MODS MOD4 ON
                                                    MOD4.TAR_ID = CHG.TAR_ID AND
                                                    MOD4.LINE_COUNT = CHG.CHARGE_LINE AND
                                                    MOD4.MOD_LINE_COUNT = 4

								LEFT JOIN CLARITY_POS POS ON (CHG.PROC_POS_ID = POS.POS_ID)


								LEFT JOIN	 (
                                                SELECT  EAP_OT_I.PROC_ID, 
                                                        MAX(EAP_OT_I.CONTACT_DATE) AS CONTACT_DATE,
                                                        MAX(EAP_OT_I.CONTACT_TYPE_C) AS CONTACT_TYPE_C
                                                FROM   dbo.CLARITY_EAP_OT EAP_OT_I
                                                GROUP BY 
                                                        EAP_OT_I.PROC_ID
											) AS EAP_OT_MAX ON
                                                    CHG.PROC_ID = EAP_OT_MAX.PROC_ID
                                LEFT JOIN  dbo.CLARITY_EAP_OT EAP_OT ON 
                                                    EAP_OT_MAX.PROC_ID = EAP_OT.PROC_ID  
                                                    AND EAP_OT_MAX.CONTACT_DATE = EAP_OT.CONTACT_DATE 
                                                    AND EAP_OT_MAX.CONTACT_TYPE_C = EAP_OT.CONTACT_TYPE_C


WHERE							CHG.CHARGE_STATUS_C IN (3,5)  --3 = 'In Review' and 5= 'Created'
								








