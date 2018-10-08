DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

--DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
--DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select distinct
 'E' + tdl.INVOICE_NUMBER as 'SUBMITTERS ID'
,LEFT(tdl.INVOICE_NUMBER, LEN(tdl.INVOICE_NUMBER) - 1) as 'ACTUAL PATIENT ID'
,'P' as 'SERVICE CATEGORY'
,loc.GL_PREFIX + 'P'  as 'FACILITY ID'
from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
where tdl.ORIG_SERVICE_DATE >= '01/01/2017'
and tdl.POST_DATE >= @start_date
and tdl.POST_DATE <= @end_date
and tdl.DETAIL_TYPE = 50 -- INSURANCE CLAIMS
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and dep.GL_PREFIX not in ('6327')

--and tdl.DEPT_ID not in (19102101,19102102,19102105,19102103,19102104,17110102,19290068,17110101,19290020,11106133)	-- exclude Rural Health

order by 'E' + tdl.INVOICE_NUMBER