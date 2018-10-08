-- MEI Population Query

SELECT DISTINCT
	enc.PAT_ENC_CSN_ID,
	enc.CONTACT_DATE,
	CONVERT(DATE,GETDATE(),101) as 'REPORT_DATE',
	enc.ENC_CLOSED_YN,
	enc.LOS_PROC_CODE
FROM
	PAT_ENC enc
WHERE NOT EXISTS
(
	 --Appointment considered reconciled if one of the criterias below are met. If met do not count as MEI.
	 
	(SELECT 
		tdl.PAT_ENC_CSN_ID
	 FROM
		CLARITY_TDL_TRAN tdl
		INNER JOIN ARPB_TRANSACTIONS arpb on tdl.TX_ID = arpb.TX_ID
	 WHERE 
		tdl.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID AND
		tdl.DETAIL_TYPE = '1' AND
		arpb.VOID_DATE IS NULL
	)
	UNION
	-- Use either the PRE_AR_CHG or CHG_REVIEW table.
	
	(SELECT
		chg.PAT_ENC_CSN
	 FROM 
		PRE_AR_CHG chg
	 WHERE
		chg.PAT_ENC_CSN = enc.PAT_ENC_CSN_ID AND
		chg.CHARGE_STATUS_C = '3'
	)
)
AND enc.APPT_STATUS_C in ('2','6')
AND YEAR(enc.CONTACT_DATE) >= '2012' -- Update if previous years are note desired.
ORDER BY enc.PAT_ENC_CSN_ID, enc.CONTACT_DATE


/* 
Daily Query (custom_table)
Stored procedure (query) Custom table in database that runs nightly captures the basic MEI inventory as it’s most simplistic. Runs daily as an append to custom table. After nightly ETL are completed. 
SELECT
 PAT_ENC.PAT_ENC_CSN_ID
,CONTACT_DATE
,REPORT_DATE (date sql ran)
,ENC_CLOSED_YN
,LOS_PROC_CODE

Anything that changes overtime that is beneficial for MEI reporting. 
*/


