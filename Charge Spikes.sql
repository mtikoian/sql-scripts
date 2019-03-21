-- CHARGES AND PAYMENTS

select 
 date.YEAR_MONTH_STR
,sum(case when detail_type in (1,10) then amount else 0 end) as 'Charges'
,sum(case when detail_type in (2,5,11,20,22,32,33) then amount else 0 end) * -1 as 'Payments'
from clarity_tdl_tran
left join date_dimension date on date.CALENDAR_DT = clarity_tdl_tran.post_date
where serv_area_id in (11,13,16,17,18,19)
and post_date >= '01/1/2018'
and post_date <= '12/31/2018'

group by year_month_str
order by year_month_str

-- MERCY VISITS

select 
 date.YEAR_MONTH_STR
,sum(case when detail_type = 1 then 1 when detail_type = 10 then -1 else 0 end) as Visits
from clarity_tdl_tran tdl
left join date_dimension date on date.CALENDAR_DT = tdl.post_date
left join clarity_eap eap on eap.proc_id = tdl.proc_id
where 
serv_area_id in (11,13,16,17,18,19)
and post_date >= '01/1/2018'
and post_date <= '12/31/2018'
and detail_type in (1,10)
and eap.proc_code in (
'90837',
'99184',
'99393',
'99235',
'99310',
'99467',
'99342',
'99288',
'G0404',
'99328',
'99411',
'99243',
'99202',
'99291',
'90792',
'99407',
'99460',
'99254',
'99350',
'99476',
'99344',
'99480',
'90832',
'99382',
'99234',
'99223',
'99213',
'99024',
'99335',
'99468',
'90833',
'99347',
'99379',
'99195',
'99406',
'99443',
'99283',
'99205',
'99221',
'99449',
'90801',
'99383',
'99471',
'99461',
'90847',
'99175',
'99219',
'99090',
'99201',
'99251',
'99325',
'90839',
'99357',
'99245',
'99356',
'96152',
'99284',
'99140',
'90806',
'99341',
'99252',
'99387',
'99358',
'99212',
'99396',
'96153',
'99174',
'99188',
'99318',
'99462',
'99401',
'99304',
'99446',
'99309',
'99232',
'99078',
'96150',
'99466',
'99441',
'99156',
'99148',
'99455',
'99472',
'99386',
'99241',
'99392',
'99058',
'99394',
'99348',
'99226',
'99444',
'99381',
'G0438',
'99215',
'99236',
'G0439',
'99242',
'99391',
'99475',
'99060',
'99204',
'99402',
'99380',
'99456',
'90840',
'99151',
'99395',
'99027',
'99327',
'99152',
'99479',
'99224',
'99155',
'99244',
'90846',
'99375',
'99239',
'99281',
'99464',
'99051',
'99053',
'90849',
'99225',
'99217',
'99429',
'99214',
'99404',
'99337',
'99143',
'99384',
'99359',
'99203',
'G0403',
'99211',
'99334',
'90875',
'99465',
'99403',
'99355',
'G0402',
'99448',
'99343',
'99222',
'99496',
'90836',
'99285',
'99397',
'99339',
'96154',
'99220',
'99255',
'96151',
'99144',
'99408',
'99336',
'99307',
'99477',
'99305',
'99183',
'99218',
'99478',
'99308',
'99345',
'99306',
'99349',
'99316',
'99153',
'90870',
'90838',
'99282',
'99420',
'90834',
'99253',
'99385',
'99463',
'99469',
'90863',
'99157',
'99149',
'99444',
'99324',
'99050',
'99495',
'99238',
'99231',
'99233',
'99442',
'99340',
'99354',
'G0405',
'90853',
'90791',
'99315',
'99326'
)

group by year_month_str
order by year_month_str

-- DENIALS COUNT AND DOLLARS

select 
 date.year_month_str
,count(varc.MATCH_CHG_TX_ID) as Count
,sum(varc.REMIT_AMOUNT) as Sum
	
from 

clarity.dbo.V_ARPB_REMIT_CODES varc
left join clarity.dbo.PMT_EOB_INFO_I eob on eob.TX_ID = varc.PAYMENT_TX_ID and eob.LINE = varc.EOB_LINE
left join clarity.dbo.CLARITY_RMC rmc on rmc.REMIT_CODE_ID = varc.REMIT_CODE_ID
left join clarity.dbo.CLARITY_RMC rmc1 on rmc1.REMIT_CODE_ID = varc.REMARK_CODE_1_ID
left join clarity.dbo.CLARITY_DEP dep on dep.department_id = varc.DEPARTMENT_ID
left join clarity.dbo.CLARITY_LOC loc on loc.loc_id = varc.LOC_ID
left join clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT_STR = varc.PAYMENT_POST_DATE
left join clarity.dbo.PATIENT pat on pat.pat_id = varc.pat_id
left join clarity.dbo.CLARITY_EAP eap on eap.proc_id = varc.proc_id
left join clarity.dbo.ARPB_TRANSACTIONS arpb_tx on arpb_tx.tx_id = varc.match_chg_tx_id
left join clarity.dbo.clarity_eap eap_chg on eap_chg.proc_id = arpb_tx.proc_id
left join clarity.dbo.ZC_RMC_CODE_CAT zrcc on zrcc.RMC_CODE_CAT_C = rmc1.CODE_CAT_C
where 
varc.PAYMENT_POST_DATE >= '1/1/2018'
and varc.PAYMENT_POST_DATE <= '12/31/2018'
and loc.rpt_grp_ten in (1,11,13,16,17,18,19)
and varc.REMIT_ACTION in (9,14)
and varc.REMIT_AMOUNT >= 0

group by date.year_month_str

order by date.year_month_str
