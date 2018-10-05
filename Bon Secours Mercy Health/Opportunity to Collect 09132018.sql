--version 9/13/18
-- Negative and Positive PB Balances are displayed
-- Data is displayed by Encounter department
-- Encounters with blank accounts ids have been removed


--declare @startdate date  = dateadd(d,0,datediff(d,0,getdate())-7) 
declare @startdate date  = '8/15/2018' 
		,@enddate date = dateadd(d,0,datediff(d,0,getdate())-1); ---yesterday

with cteCopay as
(
		select 

			--	 enc.DEPARTMENT_ID
			--	,dep.DEPARTMENT_NAME
				--,pat_enc.PAT_ENC_CSN_ID
				 enc.ACCOUNT_ID
				,acct.ACCOUNT_NAME
				--,enc.PAT_ID
				,cast(enc.CONTACT_DATE as date) CONTACT_DATE
				,min(isnull(bal.PATIENT_BALANCE, 0)) as PB_BALANCE
				,min(isnull(bal.HB_SELFPAY_BALANCE, 0)) as HB_BALANCE
				,sum(case when prc.benefit_group in ('Office Visit','PB Copay','Copay') then enc.COPAY_DUE else 0 end) as Copay_Due
				,sum(case when prc.benefit_group in ('Office Visit','PB Copay','Copay') then enc.COPAY_COLLECTED else 0 end) as Copay_Collected
			--	,patient.PAT_MRN_ID
			--	,patient.PAT_NAME
			--	,patient.BIRTH_DATE
			--	,enc.ENC_TYPE_C
				--,ZC_DISP_ENC_TYPE.name

		from 
				PAT_ENC enc
				left join CLARITY_DEP dep on enc.DEPARTMENT_ID= dep.DEPARTMENT_ID 
				left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
				left join CLARITY_EAP on CLARITY_EAP.PROC_Code = enc.LOS_PROC_CODE 
                left join ACCOUNT acct on acct.ACCOUNT_ID = enc.ACCOUNT_ID 
				left join  claritychputil.rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE bal ON enc.ACCOUNT_ID =  bal.ACCOUNT_ID
						   AND enc.CONTACT_DATE = bal.UPDATE_DATE
			--	left join PATIENT on patient.PAT_ID = enc.PAT_ID  
				Left join ZC_DISP_ENC_TYPE on ZC_DISP_ENC_TYPE.INTERNAL_ID = enc.ENC_TYPE_C
				left join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID
		where 
				enc.APPT_STATUS_C in (2,6) -- Arrived or Completed 
				and convert(int, enc.ENC_TYPE_C) in (50, 101, 1001, 1003, 1200, 1214, 2)  
			    /*Included Encounter Types
				Anti-coag visit
				Procedure visit
				Office Visit
				Routine Prenatal
				Postpartum Visit
				Walk-In
				Clinical Support -- removed 9/11/18
				PAT Telephone -- removed 9/11/18
				Post-op Telephone --- removed 9/11/18
				Appointment
				*/
				and enc.CANCEL_REASON_C is null 
				and enc.CONTACT_DATE between @startdate and @enddate
				and loc.RPT_GRP_TEN in (11,13,16,17,18,19)
				and enc.ACCOUNT_ID is not null
				--and pat_enc.ACCOUNT_ID in (101280805)

group by
 enc.ACCOUNT_ID
,acct.ACCOUNT_NAME
,enc.CONTACT_DATE

)
,
ctePayment as
(		
				
select 
	--	 dep.DEPARTMENT_ID 
	--	,dep.DEPARTMENT_NAME
		cteCopay.ACCOUNT_ID
	--	,arpb_tx.POST_DATE
		,arpb_tx.SERVICE_DATE
		,sum(isnull(arpb_tx.AMOUNT,0)*-1) as Amount
	--	,arpb_tx.TX_ID
FROM  
		cteCopay 
		inner join claritychputil.rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE bal on bal.ACCOUNT_ID = cteCopay.ACCOUNT_ID and bal.UPDATE_DATE = cteCopay.CONTACT_DATE
		left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.ACCOUNT_ID = bal.ACCOUNT_ID
				and arpb_tx.SERVICE_DATE = bal.UPDATE_DATE and arpb_tx.PROC_ID in (7084)
				/*Included Payment Codes
				PATIENT PAYMENT (ACCOUNT)
				PRE-PAYMENT ELECTIVE (ACCOUNT) -- REMOVED 9/10/18
				PRE-PAYMENT (ACCOUNT) -- REMOVED 9/10/18
				OB PRE-PAYMENT (ACCOUNT) -- REMOVED 9/10/18
				HC THERAPY NO SHOW COUNTER [3040196] -- REMOVED 9/10/18
				*/
		--left join CLARITY_DEP dep on dep.DEPARTMENT_ID = cteCOPAY.DEPARTMENT_ID

WHERE 
		--ARPB_TRANSACTIONS.proc_id in (7084,7332,7334,36263,84726) --IS THIS NEEDED?   ---Jan 2015 added payments - proc code 1004 and 1002
		arpb_tx.SERVICE_DATE between @startdate and @enddate 
		and arpb_tx.VOID_DATE is null
		--and ARPB_TRANSACTIONS.TX_TYPE_C = 2 -- IS THIS NEEDED?
		--and ARPB_TRANSACTIONS.ACCOUNT_ID in (101280805)
		 ---------------------------------------------------------------------------------------------------test data
				
group by 
	
 cteCopay.ACCOUNT_ID
,arpb_tx.SERVICE_DATE

)


select 
 *
 from cteCopay
left join ctePayment on ctepayment.ACCOUNT_ID = ctecopay.ACCOUNT_ID and ctePayment.SERVICE_DATE = ctecopay.CONTACT_DATE
order by cteCopay.ACCOUNT_ID, cteCopay.CONTACT_DATE