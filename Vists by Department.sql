with visits as
(
select 
 dd.YEAR_MONTH_STR as 'Month of Service'
,upper(sa.NAME) as 'Service Area'
,dep.DEPARTMENT_NAME as 'Department'
,dep.SPECIALTY as 'Department Specialty'
,coalesce(dep.GL_PREFIX,'') as 'Department GL'
,eap.PROC_CODE as 'Procedure Code'
,eap.PROC_NAME as 'Procedure Desc'
,fc.FINANCIAL_CLASS_NAME as 'Original FC'
,coalesce(epm.PAYOR_NAME,'') as 'Original Payor'
,addr.ADDRESS as 'Address'
,dep2.ADDRESS_CITY as 'City'
,state.NAME as 'State'
,dep2.ADDRESS_ZIP_CODE as 'Zip'
,arpb_tx.TX_ID
,arpb_tx.PROCEDURE_QUANTITY as 'Visits'
from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = arpb_tx.ORIGINAL_FC_C
left join CLARITY_EPM epm on epm.PAYOR_ID = arpb_tx.ORIGINAL_EPM_ID
left join DATE_DIMENSION dd on dd.CALENDAR_DT = arpb_tx.SERVICE_DATE
left join CLARITY_DEP_ADDR addr on addr.DEPARTMENT_ID = dep.DEPARTMENT_ID and addr.LINE = 1
left join CLARITY_DEP_2 dep2 on dep2.DEPARTMENT_ID = dep.DEPARTMENT_ID
left join ZC_STATE state on state.STATE_C = dep2.ADDRESS_STATE_C
where arpb_tx.TX_TYPE_C = 1
and eap.PROC_CODE between '99201' and '99214'
and arpb_tx.SERVICE_DATE >= '1/1/2017'
and arpb_tx.SERVICE_DATE <= '12/31/2017'
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and arpb_tx.VOID_DATE is null
--and arpb_tx.TX_ID = 152721212
),

match as
(select tdl.TDL_ID
,tdl.TX_ID
,tdl.MATCH_TRX_ID
,tdl.POST_DATE
,tdl.AMOUNT*-1 as 'Payment Amount'
,eob.CVD_AMT as 'Allowed Amount'
,eob.PAID_AMT as 'Paid Amount'
,ROW_NUMBER() OVER(PARTITION BY tdl.TX_ID ORDER BY tdl.TDL_ID ASC) AS RowNumber
from visits 
inner join CLARITY_TDL_TRAN tdl on tdl.TX_ID = visits.TX_ID
inner join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID
where tdl.DETAIL_TYPE = 20
--and tdl.TX_ID = 153653173
)

select 
 [Month of Service]
,[Service Area]
,[Department]
,[Department Specialty]
,[Department GL]
,[Procedure Code]
,[Procedure Desc]
,[Original FC]
,[Original Payor]
,[Address]
,[City]
,[State]
,[Zip]
,coalesce(sum([Visits]),0) as 'Visits'
,coalesce(sum([Allowed Amount]),0) as 'Allowed Amount'
,coalesce(sum([Paid Amount]),0) as 'Paid Amount'
from visits
left join match on match.TX_ID = visits.TX_ID
where (RowNumber = 1 or RowNumber is null)
--and [Department] = 'FAIRFIELD OB'
group by 
 [Month of Service]
,[Service Area]
,[Department]
,[Department Specialty]
,[Department GL]
,[Procedure Code]
,[Procedure Desc]
,[Original FC]
,[Original Payor]
,[Address]
,[City]
,[State]
,[Zip]

order by
 [Month of Service]
,[Service Area]
,[Department]
,[Department Specialty]
,[Department GL]
,[Procedure Code]
,[Procedure Desc]
,[Original FC]
,[Original Payor]
,[Address]
,[City]
,[State]
,[Zip]