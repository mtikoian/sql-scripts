select
 pat.PAT_FIRST_NAME as 'First Name'
,pat.PAT_MIDDLE_NAME as 'Middle Initial'
,pat.PAT_LAST_NAME as 'Last Name'
,pat.ADD_LINE_1 as 'Address 1'
,pat.ADD_LINE_2 as 'Address 2'
,pat.CITY as 'City'
,pat.ZIP as 'Zip'
,zs.ABBR as 'State'
,cast(pat.BIRTH_DATE as date) as 'DOB'
,ser.PROV_NAME as 'Current PCP'
,cast(pat.DEATH_DATE as date) as 'Deceased Date'


from PATIENT pat
left join CLARITY_SER ser on ser.PROV_ID = pat.CUR_PCP_PROV_ID
left join ZC_STATE zs on zs.STATE_C = pat.STATE_C


where pat.CUR_PCP_PROV_ID = '1612911'

order by pat.PAT_FIRST_NAME