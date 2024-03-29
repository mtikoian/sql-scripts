SELECT CLARITY_SER.PROV_ID, 
       CLARITY_SER.PROV_NAME,
       CLARITY_SER.PROV_TYPE,
       CLARITY_SER.IS_RESIDENT, 
       CLARITY_SER_2.NPI, 
       CLARITY_SER.CLINICIAN_TITLE, 
       CLARITY_SER.ACTIVE_STATUS, 
       CLARITY_SER.SER_REF_SRCE_ID,
       GRP8.NAME as 'AMA_SPECIALTY',
	   GRP9.NAME as 'AMA_SUB_SPECIALTY',
       CRED_SPEC.NAME AS 'CREDENTIALED SPECIALTY'
FROM   Clarity.dbo.CLARITY_SER CLARITY_SER (NOLOCK)
LEFT OUTER JOIN Clarity.dbo.CLARITY_SER_2 CLARITY_SER_2 (NOLOCK) ON CLARITY_SER.PROV_ID=CLARITY_SER_2.PROV_ID
LEFT OUTER JOIN Clarity.dbo.ZC_SER_RPT_GRP_8 GRP8 (NOLOCK) ON GRP8.RPT_GRP_EIGHT = CLARITY_SER.RPT_GRP_EIGHT
LEFT OUTER JOIN Clarity.dbo.ZC_SER_RPT_GRP_9 GRP9 (NOLOCK) ON GRP9.RPT_GRP_NINE = CLARITY_SER.RPT_GRP_NINE
LEFT OUTER JOIN CLARITY_SER_SPEC P2 ON P2.PROV_ID = CLARITY_SER.PROV_ID AND P2.LINE = 1
LEFT OUTER JOIN Clarity.dbo.ZC_SPECIALTY CRED_SPEC (NOLOCK) ON CRED_SPEC.SPECIALTY_C = P2.SPECIALTY_C

