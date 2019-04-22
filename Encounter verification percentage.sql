declare @start_date as date = EPIC_UTIL.EFN_DIN('wb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('we-1')

select

 sum(1) as 'Total Encounter'
,sum(case when stat.NAME ='Verified' then 1 end) as 'Verified'


from PAT_ENC enc
left join PAT_ENC_2 enc2 on enc2.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
left join VERIFICATION ver on ver.RECORD_ID = enc2.ENC_VERIFICATION_ID
left join ZC_REG_STATUS stat on stat.REG_STATUS_C = ver.VERIF_STATUS_C

where
enc.APPT_STATUS_C in (2,6)
and enc.ENC_TYPE_C in (1000,1001,1003,101,108,11,1200,1201,121,1214,2,201,21005,210177,2102,2501,2502,283,49,51,81)
and enc.CONTACT_DATE between @start_date and @end_date



