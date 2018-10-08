USE [ClarityCHPUtil]
GO

/****** Object:  View [Rpt].[V_MERCY_CUBE_D_LOCATION]    Script Date: 1/30/2016 8:37:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [Rpt].[V_MERCY_CUBE_D_LOCATION]
(
 [LOCATION_ID]
,[LOCATION_NAME]
,[LOCATION_NAME ID_DISPLAY]
,[GL_LOCATION_NAME_DISPLAY]

)
AS
/*Copyright (C) 2011 Epic Systems Corporation
********************************************************************************
TITLE:   V_MERCY_CUBE_D_LOCATION
PURPOSE: SSAS related cube for locations
AUTHOR:  Andrew Hilfiger
REVISION HISTORY: 
*dsp 5/13/15 - created
********************************************************************************
*/
SELECT
   loc.LOC_ID,
   loc.LOC_NAME,
   loc.LOC_NAME + ' [' + CAST(loc.LOC_ID as VARCHAR) + ']',
   case when loc.gl_prefix is null then loc.loc_name else coalesce(loc.gl_prefix,'NO GL') + ' - ' + loc.loc_name end
FROM [CLARITY]..CLARITY_LOC loc
UNION ALL
SELECT 
  -1,
  'Unspecified Location',
  'Unspecified Location',
  'Unspecified Location'



GO


