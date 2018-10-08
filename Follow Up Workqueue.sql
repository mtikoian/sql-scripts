/*
Possible logic would look first if WQ Service Area = [Actual Service Area Name], 
then pull details that will be specified (such as owning area, supervisor, department, enter WQ date, etc...); 
Next level would look if WQ Service Area = Mercy Health - and - WQ name contains [4 letter prefix for new Service Area], 
then pull specific details (see above); OR
Third level would look if WQ Service Area = Mercy Health - and WQ name = [any one within a designated list of WQ names containing
 claims from multiple Service Areas] - and - Location in WQ claim details contains [4 letter prefix for new Service Area]; 
 then pull specific details (see above)
 fol_status_c
*/
select
 fi.WORKQUEUE_ID
,fw.WORKQUEUE_NAME
,oa.NAME as OWNING_AREA
,fw.OWNINGSUPERVISOR_ID
,emp.NAME
,dep.DEPARTMENT_NAME
,fi.SERVICE_AREA_ID
,sa.NAME as MARKET
,sum(case when fi.FOL_WQ_TABS_C = 0 then fi.OUTSTANDING_AMOUNT else 0 end ) as 'ACTIVE_AMT' 
,sum(case when fi.FOL_WQ_TABS_C = 0 then 1 else 0 end ) as 'ACTIVE_COUNT' 
,sum(case when fi.FOL_WQ_TABS_C = 1 then fi.OUTSTANDING_AMOUNT else 0 end ) as 'USER_DEFERRED_AMT' 
,sum(case when fi.FOL_WQ_TABS_C = 1 then 1 else 0 end ) as 'USER_DEFERRED_COUNT' 
,sum(case when fi.FOL_WQ_TABS_C = 2 then fi.OUTSTANDING_AMOUNT else 0 end ) as 'SYSTEM_DEFERRED_AMT' 
,sum(case when fi.FOL_WQ_TABS_C = 2 then 1 else 0 end ) as 'SYSTEM_DEFFERRED_COUNT' 

from FOL_INFO fi
left join FOL_WQ fw on fw.WORKQUEUE_ID = fi.WORKQUEUE_ID
left join ZC_OWNING_AREA_2 oa on oa.OWNING_AREA_2_C = fw.OWNING_AREA_C
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = fi.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = fi.LOCATION_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EMP emp on emp.USER_ID = fw.OWNINGSUPERVISOR_ID

where --fi.WORKQUEUE_ID in (252,828)
fi.SERVICE_AREA_ID in (11,13,16,17,18,19)
and fi.FOL_WQ_TABS_C <> 3 -- EXCLUDE COMPLETED
group by fi.WORKQUEUE_ID, fw.WORKQUEUE_NAME, oa.NAME,fw.OWNINGSUPERVISOR_ID,emp.NAME,dep.DEPARTMENT_NAME, fi.SERVICE_AREA_ID, sa.NAME
order by fi.WORKQUEUE_ID