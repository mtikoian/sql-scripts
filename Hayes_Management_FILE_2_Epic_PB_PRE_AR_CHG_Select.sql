
-- FILE_2_Epic_PB_PRE_AR_CHG_Select
--	NOTES : 
		-- 1. Use script to create Pipe delimited file with header record
			-- Filename = 'clientname_CCYYMMDD_CODE.txt'
		-- 2. HARDCODE Charge Review Work Queue #s in 'FROM' statement
		-- 3. HARDCODE 'ClientId' column per MDEnterprixe client code


SELECT DISTINCT
						'24' as ClientId,
						CHG_DX.TAR_ID As ProspectiveClaimId,	-- Unique identifier to link  3 files
						CASE CHG_DX.LINE			
							WHEN '1' THEN 'ABK'	
								ELSE
								'ABF'
						END AS CodeQualifier,
						CHG_DX.LINE AS CodePos,
						EDG.REF_BILL_CODE AS CodeValue,
						NULL AS CodeFromDate,
						NULL AS CodeToDate,
						NULL AS CodeAmnt,
						NULL AS POAInd

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

					  INNER JOIN dbo.CHG_REVIEW_DX CHG_DX ON CHG_DX.TAR_ID = CHG.TAR_ID

					  LEFT JOIN dbo.CLARITY_EDG EDG ON CHG_DX.DX_ID = EDG.DX_ID
						
					  INNER JOIN dbo.PATIENT PAT ON (CHG.PAT_ID = PAT.PAT_ID)

	WHERE			  CHG.CHARGE_STATUS_C IN (3,5)  --3 = 'In Review' or 5 = 'Created'
