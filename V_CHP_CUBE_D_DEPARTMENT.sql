USE [ClarityCHPUtil]
GO

/****** Object:  View [dbo].[V_CHP_CUBE_D_DEPARTMENT]    Script Date: 1/30/2016 8:30:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[V_CHP_CUBE_D_DEPARTMENT]
(
 [DEPARTMENT_ID]
,[DEPARTMENT_NAME]
,[DEPARTMENT_DISPLAY_NAME]
,[SPECIALTY]
,[LOCATION_ID]
)
AS
/*Copyright (C) 2011 Epic Systems Corporation
********************************************************************************
TITLE:   V_CHP_CUBE_D_DEPARTMENT
PURPOSE: SSAS related cube for departments
AUTHOR:  AJITA PATIL
REVISION HISTORY: 
*4/24/2015 - created
*EYZ 06/14 DLG#I8113943 - append unknown department columns for each location
********************************************************************************
*/
SELECT 
   dep.DEPARTMENT_ID,
   dep.DEPARTMENT_NAME,
   dep.DEPARTMENT_NAME + ' [' + CAST(dep.DEPARTMENT_ID as VARCHAR) + ']',
   coalesce(spec.NAME,'Unspecified Specialty'),
   coalesce(dep.REV_LOC_ID,-2)
FROM [CLARITY]..CLARITY_DEP dep
LEFT OUTER JOIN [CLARITY]..ZC_DEP_SPECIALTY spec
on dep.SPECIALTY_DEP_C = spec.DEP_SPECIALTY_C
----UNION ALL
----SELECT 
----   -1,
----   'Unspecified Department',
----   'Unspecified Department',
----   'Unspecified Specialty',
----   coalesce(pos.POS_ID,-2)
----   FROM [CLARITY]..CLARITY_POS pos
UNION ALL
SELECT 
   -1,
   'Unspecified Department',
   'Unspecified Department',
   'Unspecified Specialty',
   -2




GO


