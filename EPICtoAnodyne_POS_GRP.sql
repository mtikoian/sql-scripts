USE CLARITY

SELECT DISTINCT

 cast(pos.rpt_grp_one as numeric) as POS_ID
,upper(pos.rpt_grp_two) as POS_NAME
,'' as POS_GROUP
,pos.POS_TYPE
,'' as ADDRESS_LINE_1
,'' as ADDRESS_LINE_2
,'' as CITY
,'' as STATE_C
,'' as ZIP
,'' as AREA_CODE
,'' as PHONE

FROM clarity_pos pos

where pos.rpt_grp_one is not null
