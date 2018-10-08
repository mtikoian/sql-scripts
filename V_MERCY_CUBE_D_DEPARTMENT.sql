USE [ClarityCHPUtil]
GO

/****** Object:  View [Rpt].[V_MERCY_CUBE_D_DEPARTMENT]    Script Date: 1/30/2016 8:37:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER VIEW [Rpt].[V_MERCY_CUBE_D_DEPARTMENT]
(
 [DEPARTMENT_ID]
,[DEPARTMENT_NAME]
,[DEPARTMENT_NAME ID_DISPLAY]
,[GL_DEPARTMENT_NAME_DISPLAY]
,[SPECIALTY]

)
AS
/*Copyright (C) 2011 Epic Systems Corporation
********************************************************************************
TITLE:   V_MERCY_CUBE_D_DEPARTMENT
PURPOSE: SSAS related cube for departments
AUTHOR:  DUSTIN PLOWMAN
REVISION HISTORY: 
*5/12/2015 - created
********************************************************************************
*/
SELECT 
   dep.DEPARTMENT_ID,
   dep.DEPARTMENT_NAME,
   dep.DEPARTMENT_NAME + ' [' + CAST(dep.DEPARTMENT_ID as VARCHAR) + ']',
   case when dep.gl_prefix is null then dep.DEPARTMENT_NAME else coalesce(dep.gl_prefix,'NO GL') + ' - ' + dep.DEPARTMENT_NAME end,
   coalesce(spec.NAME,'Unspecified Specialty')
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
   'Unspecified Department',
   'Unspecified Specialty'




GO


