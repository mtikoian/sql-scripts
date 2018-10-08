/*
1.	Date Range Filter (Date Psych Consult Ordered) It should be concrete data when the order is signed.
We can get this in RWB - criteria
2.	Response Time: Time from Psych Consult Ordered to Start Time of Psych Consult Is it concrete data when the note is started?
We may be able to get this in RWB – CON53 / CON19 / CON90 / CON91 – criteria / display – how do we pull start time of consult HNO 17106?
3.	Psych Consult Order Type: Routine or Stat Is there an order for Routine and Stat? 
We can get this  -   ORD 120 - display
4.	Patient Location: Location from the Psych Consult Service (what MHN location). If cannot get that granular, then what options exist (ER, Acute, Medical IP) Admitted location? This is in the record
We can get this – UCL 513 - display
5. Payer Type of Pscyh Consult: COB1,COB2 This is not easily pulled by Clarity and not sure how to pull for RBW
                                We can get this in RWB - display
6.	Length of Stay ER (Admit to D/C)  - we can get this - display
We can get this EPT 10296/10297 (ER); EPT 10290/10291 (IP); ADT arrival time / date EPT 10815/10820
a.	Medical Dx Only No idea how to limit without significant build by Clarity
Admission DX 10150/10151 - display
All DX for Visit EPT 18400
b. Psych Dx Only No idea how to limit without significant build by Clarity
c. Co-Occurring Dx (Medical and Psych) No idea how to limit without significant build by Clarity
7. Length of Stay Acute
                We can get this – EPT 10595/10596/10597 – does this mean same thing as item below?
a. Medical Dx Only
b. Co-Occurring Dx (Medical and Psych
8. Length of Stay Inpatient (Medical)
a. Medical Dx Ony
b. Co-Occurring Dx (Medical and Psych)
9. Sitter Use: (Is sitter only used for Psych? How tracked in CarePath?)
                No idea what this means???
a. ER
b. Acute
c. Medical Inpatient
*/


select 
 nei.NOTE_FILE_TIME_DTTM
,nei.NOTE_ID
,ni.PAT_ENC_CSN_ID
,peh.PAT_ID
,pat.PAT_NAME
,peh.INP_ADM_DATE
,peh.HOSP_ADMSN_TIME
,peh.HOSP_DISCH_TIME
,los.LENGTH_OF_STAY_DAYS
,los.LENGTH_OF_STAY_MINS
,nei.AUTHOR_SERVICE_C
,zcs.NAME as AUTHOR_SERVICE
,nei.AUTHOR_USER_ID
,emp.NAME as AUTHOR_USER
,hcoi.CONSULT_ORDER_ID
,op.ORDERING_DATE
,op.ORDER_TIME
,op.PROC_ID -- join EAP
,op.ORDER_PRIORITY_C -- join zc_priority
,op2.PAT_LOC_ID	
,pe.ACCOUNT_ID
,pe.COVERAGE_ID

from
NOTE_ENC_INFO nei 
left join HNO_INFO ni on ni.NOTE_ID = nei.NOTE_ID
left join PAT_ENC_HSP peh on peh.PAT_ENC_CSN_ID = ni.PAT_ENC_CSN_ID
left join LENGTH_OF_STAY los on los.PAT_ENC_CSN_ID = ni.PAT_ENC_CSN_ID
left join CLARITY_EMP emp on emp.USER_ID = nei.AUTHOR_USER_ID
left join ZC_CLINICAL_SVC zcs on zcs.CLINICAL_SVC_C = nei.AUTHOR_SERVICE_C
left join PATIENT pat on pat.PAT_ID = peh.PAT_ID
left join HNO_CONSULT_ORD_ID hcoi on hcoi.NOTE_ID = nei.NOTE_ID
left join ORDER_PROC op on op.ORDER_PROC_ID = hcoi.CONSULT_ORDER_ID
left join ORDER_PROC_2 op2 on op2.ORDER_PROC_ID = op.ORDER_PROC_ID
left join PAT_ENC pe on pe.PAT_ENC_CSN_ID = peh.PAT_ENC_CSN_ID


where AUTHOR_SERVICE_C = 382 -- Telepsych
--and AUTHOR_USER_ID in ('IA04704')

/*
Ahmed, Irfan, MD - IA04704
Janjua, Ahmed  MD - JANJ000
Qureishi, Bushra, MD - QURE003
Gorcos, Monica MD - GORC001
Johns, Nathaniel, MD - JOHN823
Stump, Frank, MD - STUM014
Carrick, Janice    DO - CARR177
Sadehh, Abdulmalek, MD - SADE002
Williams, George, MD - WILL920
Wright, Shana, CNP - WRIG194
Clark, Amy, CNS - CLAR272
Beroske, Marcie, CNP - BERO000 
Munson, Sheena, CNP - MUNS016
*/