select 
 loc.GL_PREFIX + ' - ' + loc.LOC_NAME 'Location'
,dep.GL_PREFIX + ' - ' + dep.DEPARTMENT_NAME 'Department'
,pos.POS_NAME 'Place of Service'
,pos.POS_TYPE 'POS Type'
,ser.PROV_NAME 'Service Provider'
,fc.FINANCIAL_CLASS_NAME 'Original Financial Class'
,tdl.TX_ID as 'Transaction ID'
,tdl.DETAIL_TYPE 'Detail Type'
,pat.PAT_MRN_ID 'Patient MRN'
,pat.PAT_NAME 'Patient Name'
,cast(tdl.ORIG_SERVICE_DATE as date) 'Original Service Date'
,cast(tdl.POST_DATE as date) 'Post Date'
,date.YEAR_MONTH 'Post Month'
,tdl.ACCOUNT_ID 'Account ID'
,eap.PROC_CODE 'CPT Code'
,eap.PROC_NAME 'Procedure Desc'
,tdl.MODIFIER_ONE 'Modifier 1'
,tdl.MODIFIER_TWO 'Modifier 2'
,tdl.MODIFIER_THREE 'Modifier 3'
,tdl.MODIFIER_FOUR 'Modifier 4'
,case when tdl.DETAIL_TYPE in (1,10) then tdl.AMOUNT else 0 end as 'Charge Amount'
,case when tdl.DETAIL_TYPE in (1,10) then tdl.PROCEDURE_QUANTITY else 0 end as 'Procedure Quantity'
,case when tdl.DETAIL_TYPE in (20) then tdl.AMOUNT else 0 end as 'Matched Payment'
,case when tdl.DETAIL_TYPE in (21) then tdl.AMOUNT else 0 end as 'Matched Adjustment'
,case when tdl.DETAIL_TYPE = 10 then tdl.RVU_WORK * -1 
      when tdl.DETAIL_TYPE = 1 then tdl.RVU_WORK end 'Ajdusted WRVU'


from CLARITY_TDL_TRAN tdl
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.PERFORMING_PROV_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = tdl.ORIGINAL_FIN_CLASS
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.POST_DATE
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_POS pos on pos.POS_ID = tdl.POS_ID

where tdl.DETAIL_TYPE in (1,10,20,21)
and tdl.POST_DATE >= '9/1/2018'
and tdl.POST_DATE <= '2/28/2019'
and tdl.PERFORMING_PROV_ID in
(
 '12010121'
,'1751371'
,'1680887'
,'1003204'
,'1658363'
,'1004208'
,'1000404'
,'1644197'
,'1005545'
,'1005698'
,'1010615'
,'1713892'
,'1000520'
,'1006356'
,'1006705'
,'1007279'
,'1007660'
,'1602936'
,'1008490'
,'1658545'
,'1644006'
,'1008788'
,'1639044'
,'1000690'
,'1675085'
,'1645950'
,'1740710'
,'1000734'
,'1010044'
)

order by tdl.TX_ID

