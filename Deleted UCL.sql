/*
Need a clarity report to capture UCLs that were deleted due to action 100719:
The action is in UCL, item 723 - so where UCL, item 723 intersects 100719 & 
The deleted status is UCL, item 104 = 2 (deleted) & 
Need this for procedure codes 99201-99205 and 99211-99215 (need to only see these codes that were deleted)

Additionally, from this initial report, would like to see if we can identify if a LOS was added on the same DOS after the fact 
(in charge review or manually posted). So, need to take the results from the initial query and pull any ETRs that were posted for 
the patients (from the original query results) on the same DOS as the deleted LOS (from the original query results). 

I submitted REQ0985344 today and asked Jessica to approve it. Assuming that we may need to meet on this. If you or Scott could expedite, 
would appreciate it. Forgot to include in the request that we can probably limit the time frame of report from DOS 5/1/18 to current. Need it across all Mercy SAs (11, 13, 16, 17, 18 & 19)

From a basic report that I ran over a short time period, there were quite a few LOSs that were deleted. We want to get the analysis under way as soon as we can since we may be bumping into some timely filing deadlines.

Hey Dustin,

We don’t need UCL 100719, 100719 is what we wanted to find in UCL 723. Since that is not available, I think we can just roll with the deleted UCL in item 104. From there, I can export all of them to see what 
was actually deleted by the action within item 723. 

I may need to circle back to this to see if we can do the second part of the request. Once we get your results and I can confirm and update the list from my export, May need to take what’s
left and then do a dump of transactions. More to come. If you can just do the query based on the CPTs I have in there and UCL 104 = deleted, and from DOS 5/1/18 to current across all Mercy SAs 
(11, 13, 16, 17, 18 & 19), think we’re good to start.
*/


select

 cast(ucl.SERVICE_DATE_DT as date) as SERVICE_DATE
,upper(sa.NAME) as REGION
,ucl.UCL_ID
,ucl.PROCEDURE_ID
,eap.PROC_NAME
,flag.NAME as SYSTEM_FLAG


from CLARITY_UCL ucl
left join CLARITY_EAP eap on eap.PROC_ID = ucl.PROCEDURE_ID
left join CLARITY_LOC loc on loc.LOC_ID = ucl.REVENUE_LOCATION_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join ZC_SYSTEM_FLAG flag on flag.SYSTEM_FLAG_C = ucl.SYSTEM_FLAG_C

where ucl.SERVICE_DATE_DT >= '5/1/2018'
and ucl.SERVICE_AREA_ID in (11,13,16,17,18,19)
and ucl.SYSTEM_FLAG_C = 2 -- DELETED
and eap.PROC_CODE in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')

order by 
 ucl.UCL_ID
