USE [ClarityCHPAdHoc]
GO
/****** Object:  StoredProcedure [RPT].[sp_PB_COPR_Open_Encounters_Weekly]    Script Date: 10/2/2018 9:19:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [RPT].[sp_PB_COPR_Open_Encounters_Weekly] 
AS


/*
*********************************************************************************
TITLE:  sp_PB_COPR_Open_Encounters
PURPOSE: COPR
AUTHOR:  Dustin Plowman
PROPERTIES: None
REVISION HISTORY: V1.1
CREATE DATE: 04/27/2017 BY Dustin Plowman
********************************************************************************
*/
delete from ClarityCHPAdHoc.rpt.PB_COPR_Encounters_Weekly

DECLARE @start_date as date = CLARITY.EPIC_UTIL.EFN_DIN('wb-1')
		,@end_date as date = CLARITY.EPIC_UTIL.EFN_DIN('we-1')

WHILE (@start_date < = @end_date)
BEGIN
    PRINT @start_date
	insert into ClarityCHPAdHoc.rpt.PB_COPR_Encounters_Weekly
	  -- Perform your operations here
	select 
	 DISTINCT
	 REGION
	,VISIT_PROVIDER_ID
	,VISIT_PROVIDER
	,DATE
	,YEAR_MONTH
	,MONTH_YEAR
	,count(*) as 'OPEN_ENCOUNTERS'

	from
	(
	select 
	 REGION
	,VISIT_PROVIDER_ID
	,VISIT_PROVIDER
	,DATE
	,YEAR_MONTH
	,MONTH_YEAR
	,case when days_open > 7 then 'y' else 'n' end as open_count
	from (
	select 
	 case when loc.loc_id in ('11106','11124','11149' -- OLD SPRINGFIELD
							  ,'19147')  then 'SPRINGFIELD' -- NEW SPRINGFIELD
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138' -- OLD CINCINNATI
						,'19151','19154','19148','19155','19156','19149','19150') then 'CINCINNATI' -- NEW CINCINNATI
	 when loc.loc_id in ('13104','13105','13116' -- OLD YOUNGSTOWN
						,'19142','19143','19144','19145') then 'YOUNGSTOWN' -- NEW YOUNGSTOWN
	 when loc.loc_id in ('16102','16103','16104', -- OLD LIMA
					     '19132','19133') then 'LIMA' -- NEW LIMA
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113' -- OLD LORAIN
						 ,'19135','19136','19137','19138','19139','19140','19141') then 'LORAIN' -- NEW LORAIN
	 when loc.loc_id in ('18120','18121', -- OLD DEFIANCE
						 '19120','19127') then 'TOLEDO' -- NEW DEFIANCE
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133', -- OLD TOLEDO
						 '19119','19121','19122','19123','19124','19128','19129','19130','19131')  then 'TOLEDO' -- NEW TOLEDO
	 when loc.loc_id in ('18110', -- OLD MRG
						 '19126') then 'TOLEDO' -- NEW MRG
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY' -- KY OTHER ENTITIES
	 end as 'REGION'
	,ser.prov_id as 'VISIT_PROVIDER_ID'
	,ser.prov_name as 'VISIT_PROVIDER'
	,dd.YEAR_MONTH as 'YEAR_MONTH'
	,dd.MONTHNAME_YEAR as 'MONTH_YEAR'
	,@start_date as DATE
	,case when enc_closed_yn = 'n' then datediff(dd,contact_date,@start_date)
	     when enc_closed_yn = 'y' and enc_close_date > @start_date then datediff(dd,contact_date,@start_date)
		 end as days_open
	from clarity.dbo.pat_enc enc
	left join clarity.dbo.clarity_ser ser on ser.prov_id = enc.visit_prov_id
	left join clarity.dbo.clarity_ser_2 ser2 on ser2.prov_id = ser.prov_id
    left join clarity.dbo.patient pat on pat.pat_id = enc.pat_id
	left join clarity.dbo.clarity_dep dep on dep.department_id = enc.department_id
	--left join clarity.dbo.clarity_loc loc on loc.rpt_grp_two= dep.rpt_grp_three
	left join clarity.dbo.clarity_loc loc on loc.loc_id = dep.rev_loc_id
	left join clarity.dbo.zc_disp_enc_type enc_type on enc_type.disp_enc_type_c = enc.enc_type_c
	left join clarity.dbo.date_dimension dd on dd.calendar_dt_str = @start_date
	where (enc_closed_yn = 'n' or (enc_closed_yn = 'y' and enc_close_date > @start_date))
	--and visit_prov_id = '1605843'
	and ser.prov_type in ('Physician','Nurse Practitioner','Physician Assistant','Certified Nurse Midwife','Podiatrist')
	and disp_enc_type_c in ('1000','1003','101','1200','1201','1214','2502','62','72','210177','2','2501')
	/*
	disp_enc_type_c	name
	1000      Initial Consult
	1003      Procedure Visit
	101        Office Visit
	1200      Routine Prenatal
	1201      Initial Prenatal
	1214      Postpartum Visit
	2502      Follow Up
	62           E-Visit
	72           E-Consult
	210177  OB Office Visit
	2             Walk In
	2501       Evaluation
	*/
	and contact_date <= @start_date
	and contact_date >= dateadd(yy,-1,datediff(d,0,@start_date)) 
	and enc.appt_status_c in (2,6)
	and loc.loc_id in ('11106','11124','11149' -- OLD SPRINGFILED
	,'19147' -- NEW SPRINGFIELD
	,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138' -- OLD CINCINNATI
	,'19151','19154','19148','19155','19156','19149','19150' -- NEW CINCINNATI
	,'13104','13105','13116' -- OLD YOUNGSTOWN
	,'19142','19143','19144','19145' -- NEW YOUNGSTOWN
	,'16102','16103','16104' -- OLD LIMA
	,'19132','19133'-- NEW LIMA
	,'17105','17106','17107','17108','17109','17110','17112','17113' -- OLD LORAIN
	,'19135','19136','19137','19138','19139','19140','19141'-- NEW LORAIN
	,'18120','18121'-- OLD DEFIANCE
	,'19120','19127' -- NEW DEFIANCE
	,'18101','18102','18103','18104','18105','18130','18131','18132','18133' -- OLD TOLEDO
	,'19119','19121','19122','19123','19124','19128','19129','19130','19131' -- NEW TOLEDO
	,'18110' -- OLD TOLEDO MRG
	,'19126' -- NEW TOLEDO MRG
	,'19101','19102','19106' -- KENTUCKY
	,'19107','19108','19116','19118' -- KENTUCKY - OTHER ENTITIES
	)
--TERMED PROVIDERS by NPI
and ser2.npi not in (
'1154390615'
,'1598747792'
,'1639334816'
,'1013901735'
,'1285688143'
,'1639105414'
,'1033472386'
,'1821041674'
,'1235233792'
,'1659698579'
,'1588871826'
,'1134557291'
,'1922061910'
,'1942256755'
,'1508900739'
,'1386661163'
,'1508833039'
,'1659685857'
,'1437122082'
,'1730564345'
,'1538154422'
,'1467754267'
,'1093911166'
,'1194701557'
,'1750526141'
,'1962610329'
,'1518912799'
,'1396744025'
,'1003013079'
,'1023237344'
,'1922259217'
,'1487711909'
,'1841302551'
,'1053631192'
,'1619171360'
,'1609865823'
,'1619958410'
,'1205813151'
,'1124000815'
,'1417182106'
,'1326041245'
,'1518123421'
,'1538166541'
,'1013131721'
,'1376582221'
,'1932502705'
,'1154355790'
,'1801140587'
,'1538547666'
,'1083749998'
,'1760873939'
,'1467774034'
,'1831117506'
,'1891801403'
,'1558747105'
,'1780030007'
,'1649229766'
,'1245545243'
,'1033577564'
,'1033324439'
,'1336146570'
,'1508825803'
,'1134122294'
,'1508974650'
,'1962478560'
,'1194884957'
,'1629408307'
,'1568702678'
,'1710972302'
,'1154359685'
,'1033343728'
,'1811997109'
,'1700862828'
,'1235184680'
,'1518183284'
,'1972501997'
,'1982809828'
,'1548565385'
,'1417383217'
,'1528371499'
,'1457398588'
,'1346251725'
,'1467443846'
,'1366542433'
,'1215982541'
,'1982607438'
,'1245632611'
,'1578792800'
,'1194809012'
,'1144543299'
,'1245324961'
,'1851373120'
,'1750569133'
,'1700047412'
,'1831355882'
,'1407954340'
,'1053487108'
,'1538130265'
,'1194863563'
,'1710909866'
,'1457754566'
,'1073595328'
,'1487635207'
,'1811999352'
,'1104822287'
,'1669458576'
,'1497719199'
,'1649408543'
,'1568787604'
,'1255445607'
,'1083695951'
,'1801037163'
,'1922008457'
,'1205803814'
,'1659334290'
,'1275630667'
,'1588628879'
,'1831212307'
,'1568439172'
,'1477748648'
,'1538118104'
,'1861444614'
,'1245229640'
,'1225470651'
,'1770637449'
,'1255610648'
,'1134290810'
,'1003238031'
,'1003832940'
,'1114049475'
,'1760422646'
,'1447397799'
,'1982609871'
,'1093714750'
,'1447488622'
,'1578683231'
,'1104809904'
,'1073573218'
,'1669877163'
,'1821080946'
,'1629089685'
,'1013926021'
,'1588622260'
,'1801881602'
,'1093828600'
,'1689705816'
,'1124373964'
,'1134350333'
,'1255330676'
,'1790939924'
,'1578648812'
,'1316993686'
,'1861589806'
,'1083613780'
,'1831231372'
,'1013145853'
,'1528456803'
,'1871521674'
,'1740260660'
,'1700994779'
,'1972595890'
,'1952537060'
,'1366677437'
,'1033229380'
,'1376537407'
,'1417939950'
,'1003818519'
,'1194797506'
,'1114152121'
,'1770575615'
,'1134177231'
,'1609006279'
,'1679725808'
,'1972525046'
,'1164445417'
,'1952535908'
,'1134120348'
,'1699022582'
,'1609090935'
,'1083793624'
,'1942292156'
,'1104046606'
,'1760621759'
,'1730181553'
,'1366416679'
,'1609836865'
,'1427298082'
,'1295920320'
,'1104149566'
,'1295796449'
,'1689896482'
,'1457355323'
,'1184610362'
,'1356316889'
,'1811292659'
,'1760448476'
,'1285785709'
,'1457345415'
,'1760416341'
,'1184989394'
,'1497877187'
,'1700888161'
,'1184608770'
,'1831338219'
,'1275703969'
,'1649269325'
,'1942207097'
,'1538190715'
,'1174576482'
,'1366824401'
,'1619968492'
,'1467429399'
,'1346237385'
,'1629003678'
,'1588035604'
,'1457520348'
,'1912950361'
,'1144367566'
,'1265870687'
,'1578754933'
,'1881670206'
,'1205040136'
,'1235542200'
,'1710960679'
,'1437417011'
,'1275534232'
,'1629318480'
,'1619107943'
,'1821197666'
,'1659547768'
,'1295727618'
,'1487871349'
,'1457369712'
,'1063409324'
,'1083808844'
,'1467410423'
,'1043316904'
,'1891065785'
,'1922260611'
,'1538167572'
,'1609257005'
,'1558430181'
,'1225359748'
,'1740397629'
,'1154508687'
,'1982916763'
,'1629399696'
,'1831124460'
,'1083698799'
,'1861473910'
,'1487691549'
,'1407228505'
,'1306812680'
,'1831183391'
,'1265750632'
,'1275735250'
,'1053412023'
,'1639573694'
,'1669490140'
,'1063672806'
,'1710272026'
,'1336309053'
,'1972571099'
,'1982729752'
,'1841446408'
,'1205800414'
,'1245226638'
,'1891707642'
,'1336470624'
,'1386930121'
,'1538473616'
,'1487748406'
,'1679510838'
,'1942418447'
,'1144470584'
,'1669603239'
,'1427286368'
,'1912285230'
,'1205163169'
,'1386913960'
,'1437211307'
,'1154530368'
,'1851387294'
,'1013916345'
,'1386865988'
,'1003179821'
,'1811055189'
,'1306001383'
,'1427099118'
,'1700870664'
,'1093719502'
,'1407133325'
,'1235189044'
,'1861435554'
,'1841263803'
,'1013911098'
,'1598945834'
,'1972738474'
,'1124330774'
,'1023089026'
,'1811968233'
,'1366428849'
,'1720215254'
,'1003233222'
,'1033102215'
,'1861494478'
,'1780832980'
,'1194719054'
,'1386683068'
,'1295082790'
,'1538241369'
,'1053460691'
,'1104872837'
,'1467526897'
,'1780992818'
,'1629367420'
,'1578858742'
,'1548242605'
,'1811089048'
,'1659719367'
,'1710217013'
,'1760722144'
,'1730253683'
,'1487657326'
,'1174514657'
,'1750758959'
,'1477503464'
,'1740520402'
,'1194792143'
,'1376865469'
,'1063410496'
,'1871588731'
,'1336147321'
,'1306069562'
,'1821074162'
,'1134392269'
,'1477986115'
,'1487720157'
,'1851770887'
,'1962504290'
,'1134510506'
,'1790926640'
,'1114076429'
,'1962485011'
,'1093763369'
,'1043201718'
,'1972700276'
,'1124231154'
,'1689949257'
,'1760681720'
,'1447231626'
,'1336146513'
,'1558461582'
,'1023032273'
,'1144531864'
,'1871779371'
,'1316116338'
,'1952397853'
,'1962692483'
,'1164402772'
,'1124168984'
,'1033147772'
,'1093714297'
,'1609193606'
,'1780659276'
,'1043473598'
,'1154347011'
,'1326129461'
,'1699175315'
,'1881810489'
,'1740684729'
,'1568652147'
,'1801061502'
,'1528004256'
,'1245225911'
,'1043268170'
,'1780693192'
,'1881821940'
,'1609128750'
,'1982635132'
,'1538326913'
,'1922011998'
,'1346486347'
,'1447415641'
,'1528024841'
,'1033449657'
,'1568469609'
,'1851671093'
)
and dep.department_id not in
('11101450',
'11104101',
'11105102',
'11107101',
'11107119',
'11107147',
'11108120',
'11108135',
'11108140',
'11108145',
'11108162',
'11108164',
'11110110',
'11110122',
'11110143',
'11111122',
'11114118',
'11114129',
'11114133',
'11114152',
'11115000',
'11115001',
'11117102',
'11121001',
'11121003',
'11139001',
'11140001',
'11101408',
'11104103',
'11146001',
'11101185',
195000230,
195000240,
195000250,
195000255,
195000260,
195000262,
195000277,
195000287,
195100211,
195100218,
195100239,
195200206,
195200210,
195200249,
195200298,
195300217,
195300236,
195300237,
195300257,
195300278,
195300292,
195400239,
195400290
)
and (ser.prov_id not in
('1100199',
'1007831',
'1000645',
'1000242',
'1005602',
'1008668',
'1008696',
'1000732',
'1611492',
'1000045',
'1009542'
) or ser.prov_id is null)
	)a
	where days_open > 7
	)b
	where open_count = 'y'

	group by
	 REGION
	,VISIT_PROVIDER_ID
	,VISIT_PROVIDER
	,DATE
	,YEAR_MONTH
	,MONTH_YEAR

    --Incrementing to next date
    SELECT @start_date = DATEADD(DAY, 1, @start_date)

END

select 
distinct *,
case when open_encounters >= 30 then '30 or Greater' else 'Less than 30' end as 'ENCOUNTER_BUCKET'
from ClarityCHPAdHoc.rpt.PB_COPR_Encounters_Weekly
order by region, visit_provider_id, date

