-- MEI Population Query

SELECT DISTINCT
      id.identity_id as PAT_MRN, 
	  p.PAT_NAME,
      --enc.PAT_ENC_CSN_ID,
      disp.name as 'ENC_TYPE',
      enc.CONTACT_DATE,
      CONVERT(DATE,GETDATE(),101) as 'REPORT_DATE',
      enc.ENC_CLOSED_YN,
      enc.LOS_PROC_CODE,
      dep.SPECIALTY,
	  dep.DEPARTMENT_NAME,
	  ser.prov_name as VISIT_PROVIDER,
	  ser2.prov_name as CLOSE_PROVIDER,
	  enc.ENC_TYPE_TITLE,
	  enc.CHARGE_SLIP_NUMBER,
	  appt.name as 'APPT STATUS',
	  enc.SERV_AREA_ID,
	  -- Aging MEI data 
	  DATEDIFF (day, enc.contact_date, getdate()) AS Days 
	  ,CASE WHEN DATEDIFF (day, enc.contact_date, getdate()) <=30       THEN ' 0 thru  30' 
            WHEN DATEDIFF (day, enc.contact_date, getdate()) <=60       THEN '31 thru  60' 
            WHEN DATEDIFF (day, enc.contact_date, getdate()) <=90       THEN '61 thru  90' 
            WHEN DATEDIFF (day, enc.contact_date, getdate()) <=120      THEN '91 thru 120' 
                                    ELSE 'Greater than 120'     END AS Age 

FROM
      PAT_ENC enc 
	  left outer join patient p on enc.pat_id = p.pat_id
	  left outer join identity_id id on p.pat_id = id.pat_id
	  left outer join clarity_ser ser on enc.visit_prov_id = ser.prov_id
	  left outer join clarity_emp emp on enc.enc_closed_user_id = emp.user_id 
	  left outer join clarity_ser ser2 on emp.prov_id = ser2.prov_id
	  left outer join zc_appt_status appt on enc.appt_status_c = appt.appt_status_c
	  LEFT outer JOIN CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
	  left outer join ZC_DISP_ENC_TYPE disp on enc.enc_type_c = disp.disp_enc_type_c
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
and id.identity_type_id = 1057
ORDER BY pat_mrn, enc.CONTACT_DATE 
