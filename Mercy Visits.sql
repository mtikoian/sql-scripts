declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2017') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('12/31/2017') 

select
 upper(sa.NAME) as 'REGION'
,loc.LOC_NAME as 'LOCATION'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,dd.YEAR_MONTH_STR as 'YEAR-MONTH'
,sum(case when tdl.detail_type in (1,10) 
	and (tdl.cpt_code>='96150' and tdl.cpt_code<='96154' or 
                tdl.cpt_code>='90800' and tdl.cpt_code<='90884' or 
                tdl.cpt_code>='90886' and tdl.cpt_code<='90899' or 
                tdl.cpt_code>='99024' and tdl.cpt_code<='99069' or 
                tdl.cpt_code>='99071' and tdl.cpt_code<='99079' or 
                tdl.cpt_code>='99081' and tdl.cpt_code<='99144' or 
                tdl.cpt_code>='99146' and tdl.cpt_code<='99149' or 
                tdl.cpt_code>='99151' and tdl.cpt_code<='99172' or 
                tdl.cpt_code>='99174' and tdl.cpt_code<='99291' or 
                tdl.cpt_code>='99293' and tdl.cpt_code<='99359' or 
                tdl.cpt_code>='99375' and tdl.cpt_code<='99480' or 
				tdl.cpt_code='98969' or
                tdl.cpt_code='99361' or 
                tdl.cpt_code='99373' or 
				tdl.cpt_code='90791' or 
				tdl.cpt_code='90792' or 
				tdl.cpt_code='99495' or 
				tdl.cpt_code='99496' or 
                tdl.cpt_code='G0402' or 
                tdl.cpt_code='G0406' or 
                tdl.cpt_code='G0407' or 
                tdl.cpt_code='G0408' or 
                tdl.cpt_code='G0409' or 
                tdl.cpt_code='G0438' or 
                tdl.cpt_code='G0439'
				)
then tdl.procedure_quantity end) as 'MERCY VISITS'

from clarity_tdl_tran tdl
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join DATE_DIMENSION dd on dd.CALENDAR_DT = tdl.POST_DATE

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)
and tdl.DETAIL_TYPE in (1,10)

group by 
 sa.NAME
,loc.LOC_NAME
,dep.DEPARTMENT_NAME
,dd.YEAR_MONTH_STR

order by 
 sa.NAME
,loc.LOC_NAME
,dep.DEPARTMENT_NAME
,dd.YEAR_MONTH_STR