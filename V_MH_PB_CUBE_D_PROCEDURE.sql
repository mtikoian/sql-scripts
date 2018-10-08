/*Copyright (C) 2015 MERCY HEALTH
********************************************************************************
TITLE:   V_MH_PB_CUBE_D_PROCEDURE
PURPOSE: Dimension table view for Procedure with SSAS Cubes
AUTHOR:  Dustin Plowman
REVISION HISTORY: 
*dsp 4/19/16 - created
********************************************************************************
*/
select 
 eap.PROC_ID as 'PROCEDURE ID'
,coalesce(eap.PROC_CODE,'UNSPECIFIED PROCEDURE CODE') as 'PROCEDURE CODE'
,case when eap.PROC_CODE is null then 'UNSPECIFIED PROCEDURE' else coalesce(eap.PROC_NAME,'UNSPECIFIED PROCEDURE NAME') + ' [' + eap.PROC_CODE + ']' end as 'PROCEDURE NAME'
,coalesce(typ.NAME,'Unspecified Procedure Type') as 'PROCEDURE TYPE'
,coalesce(edp.PROC_CAT_NAME,'UNSPECIFIED PROCEDURE CATEGORY') as 'PROCEDURE CATEGORY'
,coalesce(deb.NAME,'UNSPECIFIED DEBIT OR CREDIT') as 'DEBIT OR CREDIT'

from CLARITY_EAP eap
left outer join ZC_PROCEDURE_TYPE typ on typ.PROC_TYPE = eap.TYPE_C
left outer join EDP_PROC_CAT_INFO edp on edp.PROC_CAT_ID = eap.PROC_CAT_ID
left outer join ZC_DEBIT_OR_CREDIT deb on deb.DEBIT_OR_CREDIT_C = eap.DEBIT_OR_CREDIT_C

UNION ALL
SELECT
   -1,
   'UNSPECIFIED PROCEDURE CODE',
   'UNSPECIFIED PROCEDURE',
   'Unspecified Procedure Type',
   'UNSPECIFIED PROCEDURE CATEGORY',
   'UNSPECIFIED DEBIT OR CREDIT'
