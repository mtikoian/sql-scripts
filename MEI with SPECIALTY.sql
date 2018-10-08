-- MEI Population Query

SELECT DISTINCT
      enc.PAT_ENC_CSN_ID,
      enc.CONTACT_DATE,
      CONVERT(DATE,GETDATE(),101) as 'REPORT_DATE',
      enc.ENC_CLOSED_YN,
      enc.LOS_PROC_CODE,
      dep.SPECIALTY,
      enc.SERV_AREA_ID
      
FROM
      PAT_ENC enc 
      LEFT JOIN CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
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
      UNION
      -- Exclude Inpatient encounters.
         -- Using PAT_ENC_HSP as a first pass. May be better ways to do this!
      (SELECT
            PEHSP.PAT_ENC_CSN_ID
      FROM 
            PAT_ENC_HSP PEHSP
      WHERE
            PEHSP.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
      )
)
AND enc.APPT_STATUS_C in ('2','6')
AND enc.CONTACT_DATE >= '2014-10-01' -- Update if previous years are note desired.
AND enc.SERV_AREA_ID = 21 -- Limit to Healthspan
ORDER BY enc.PAT_ENC_CSN_ID, enc.CONTACT_DATE 
