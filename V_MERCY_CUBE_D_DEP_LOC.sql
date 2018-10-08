USE [ClarityCHPUtil]
GO

/****** Object:  View [dbo].[V_MERCY_CUBE_D_DEP_LOC]    Script Date: 1/30/2016 8:32:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[V_MERCY_CUBE_D_DEP_LOC]
(
 [DEPARTMENT_ID]
,[DEPARTMENT_NAME]
,[DEPARTMENT_DISPLAY_NAME]
,[DEPARTMENT_SPECIALTY]
,[LOCATION_ID]
,[LOCATION_NAME]
,[LOCATION_DISPLAY_NAME]
,[POS_NAME_ABBR]
,[DEPT_ABBR]
,[LOCATION_TYPE]
,[POS_TYPE]
,[SERVICE_AREA_ID]
)
AS
/*Copyright (C) 2015 Epic Systems Corporation
********************************************************************************
TITLE:   V_MERCY_CUBE_D_DEPARTMENT_LOCATION
PURPOSE: This view contains data from the CLARITY_DEP and CLARITY_POS table, optimized for use in SSAS Cubes.
AUTHOR:  Seth Van Orden
REVISION HISTORY: 
*SVO 05/15 DLG#I8129605 - created
********************************************************************************
*/
SELECT
   dep.DEPARTMENT_ID as DEPARTMENT_ID,
   coalesce(dep.DEPARTMENT_NAME,'*Unspecified Department') as DEPARTMENT_NAME,
   CASE
      WHEN dep.DEPARTMENT_NAME IS NULL THEN '*Unspecified Department'
      ELSE CONCAT(CONCAT(CONCAT(dep.DEPARTMENT_NAME,' ['),dep.DEPARTMENT_ID),']')
   END as DEPARTMENT_DISPLAY_NAME,
   coalesce(spec.NAME,'*Unspecified Specialty') as DEPARTMENT_SPECIALTY,
   coalesce(dep.REV_LOC_ID,-1) as LOCATION_ID,
   coalesce(CLARITY_POS.POS_NAME,'*Unspecified Location') as LOCATION_NAME,
   CASE
      WHEN CLARITY_POS.POS_NAME IS NULL THEN '*Unspecified Location'
      ELSE CONCAT(CONCAT(CONCAT(CLARITY_POS.POS_NAME,' ['),CLARITY_POS.POS_ID),']')
   END as LOCATION_DISPLAY_NAME,
  COALESCE([CLARITY_POS].[POS_NAME_ABBR],'*Unspecified POS NAME ABBR') AS 'POS_NAME_ABBR', 
   COALESCE(dep.[DEPT_ABBREVIATION],'*Unspecified DEPT ABBR') AS 'DEPT_ABBR',
   coalesce(zc.NAME,'*Unspecified Facility Type') as LOCATION_TYPE,
   coalesce(zcPOS.NAME,'*Unspecified POS Type') as POS_TYPE,
   CASE
       WHEN CLARITY_POS.LOC_TYPE_C=4 THEN CLARITY_POS.POS_ID
       ELSE coalesce(CLARITY_POS.SERVICE_AREA_ID,-1)
   END as SERVICE_AREA_ID
FROM [CLARITY]..CLARITY_DEP dep
LEFT OUTER JOIN [CLARITY]..ZC_DEP_SPECIALTY spec on dep.SPECIALTY_DEP_C = spec.DEP_SPECIALTY_C
LEFT OUTER JOIN [CLARITY]..CLARITY_POS on dep.REV_LOC_ID = CLARITY_POS.POS_ID
LEFT OUTER JOIN [CLARITY]..ZC_LOC_TYPE zc on CLARITY_POS.LOC_TYPE_C = zc.LOC_TYPE_C
LEFT OUTER JOIN [CLARITY]..ZC_POS_TYPE zcPOS on CLARITY_POS.POS_TYPE_C = zcPOS.POS_TYPE_C
WHERE dep.DEPARTMENT_ID = 11108166  -- filtering on one department for example
UNION ALL
SELECT
   -1,
   '*Unspecified Department',
   '*Unspecified Department',
   '*Unspecified Specialty',
   -1,
   '*Unspecified Location',
   '*Unspecified Location',
  '*Unspecified Location ABBR', 
   '*Unspecified DEPT ABBR',
   '*Unspecified Facility Type',
   '*Unspecified POS Type',
   -1
;



GO


