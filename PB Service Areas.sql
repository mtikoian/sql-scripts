
SELECT *

FROM (
SELECT DEP.DEPARTMENT_ID                                                                                                                                                                           
,      DEP.DEPARTMENT_NAME                                                                                                                                                                         
,      COALESCE(DEP.GL_PREFIX,'')                                                                                                                                                                   as 'DEP_GL_PREFIX'
,      LOC.LOC_ID                                                                                                                                                                                  
,      LOC_NAME                                                                                                                                                                                    
,      COALESCE(LOC.GL_PREFIX,'')                                                                                                                                                                   as 'LOC_GL_PREFIX'
,      COALESCE(LOC.RPT_GRP_TEN,'')                                                                                                                                                                 as 'RPT_GRP_TEN'
,      SA.SERV_AREA_ID                                                                                                                                                                             
,      Case when LOC.LOC_ID in ('11106','11123','11124')                                                                                                                      then 'SPRINGFIELD'
            when LOC.LOC_ID in ('11101','11102','11103','11104','11105','11115','11116','11122','11132','11138','11139','11140','11141','11142','11143','11144','11146') then 'CINCINNATI' --11106, 11121, 11151
            when LOC.LOC_ID in ('13104','13105')                                                                                                                              then 'YOUNGSTOWN'
            when LOC.LOC_ID in ('16102','16103','16104')                                                                                                                      then 'LIMA'
            when LOC.LOC_ID in ('17105','17106','17107','17108','17109','17110','17112','17113')                                                                              then 'LORAIN'
            when LOC.LOC_ID in ('18120','18121')                                                                                                                              then 'DEFIANCE'
            when LOC.LOC_ID in ('18101','18102','18103','18104','18105','18110','18130','18131','18132','18133')                                                              then 'TOLEDO' --18109, 18112, 18120, 18121
            when LOC.LOC_ID in ('19101','19102','19105','19106','19107','19116','19118')                                                                                      then 'KENTUCKY' --19108
            when LOC.LOC_ID in ('131201','131206', '131216')                                                                                                                              then 'SUMMA'
            when LOC.LOC_ID in ('21101','21102','21104', '21901')                                                                                                                      then 'HEALTHSPAN' end as "MARKET"
FROM      CLARITY_DEP DEP
LEFT JOIN CLARITY_LOC LOC ON LOC.LOC_ID = DEP.REV_LOC_ID
LEFT JOIN CLARITY_SA  SA  on SA.SERV_AREA_ID = LOC.SERV_AREA_ID

)a

WHERE MARKET IS NOT NULL

UNION

SELECT DEP.DEPARTMENT_ID           
,      DEP.DEPARTMENT_NAME         
,      COALESCE(DEP.GL_PREFIX,'')   as 'DEP_GL_PREFIX'
,      LOC.LOC_ID                  
,      LOC_NAME                    
,      COALESCE(LOC.GL_PREFIX,'')   as 'LOC_GL_PREFIX'
,      COALESCE(LOC.RPT_GRP_TEN,'') as 'RPT_GRP_TEN'
,      SA.SERV_AREA_ID             
,      SA.SERV_AREA_NAME           

FROM      CLARITY_DEP DEP
LEFT JOIN CLARITY_LOC LOC ON LOC.LOC_ID = DEP.REV_LOC_ID
LEFT JOIN CLARITY_SA  SA  on SA.SERV_AREA_ID = LOC.SERV_AREA_ID

WHERE SA.SERV_AREA_ID > 21
	and SA.SERV_AREA_ID not in (99, 1312, 2120000001,2120000003)
