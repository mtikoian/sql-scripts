USE ClarityCHPUTil

select 
 LOC_ID
,LOC_NAME
,'' as 'LOCATION_GROUP'
,'' as 'POS_TYPE'
,'' as 'LOCATION_ABBR'
,SERV_AREA_ID
 from v_pb_location

