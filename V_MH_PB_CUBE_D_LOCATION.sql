/*Copyright (C) 2015 MERCY HEALTH
********************************************************************************
TITLE:   V_MH_PB_CUBE_D_LOCATION
PURPOSE: Dimension table view for Locations with SSAS Cubes
AUTHOR:  Dustin Plowman
REVISION HISTORY: 
*dsp 4/19/16 - created
********************************************************************************
*/

SELECT
   loc.LOC_ID as 'LOCATION ID'
   ,coalesce(loc.GL_PREFIX,'UNSPECIFIED LOCATION GL') as 'LOCATION GL'
   ,loc.LOC_NAME + ' [' + CAST(loc.LOC_ID as VARCHAR) + ']' as 'LOCATION NAME'
   ,coalesce(cast(loc.SERV_AREA_ID as VARCHAR),'UNSPECIFIED SERVICE AREA') as 'SERVICE AREA ID'
FROM CLARITY_LOC loc
where loc.serv_area_id in (11,13,16,17,18,19)

UNION ALL
SELECT 
  -1
  ,'UNSPECIFIED LOCATION GL'
  ,'UNSPECIFIED LOCATION'
  ,'UNSPECIFIED SERVICE AREA'
 