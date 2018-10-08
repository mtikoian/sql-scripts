select ser.prov_id, prov_name, dep.department_id, department_name
from clarity_ser ser
left join clarity_ser_dept csd on ser.prov_id = csd.prov_id
inner join clarity_dep dep on csd.department_id = dep.department_id
where ser.prov_id in 
('1004329',
'1006962',
'1009583',
'1009611',
'1009750',
'1602658',
'1603742',
'1605251',
'1605583',
'1605686',
'1606480',
'1606517',
'1606646',
'1606648',
'1611472',
'1611747',
'1611756',
'1611822',
'1611837',
'1611948',
'1611965',
'1611983',
'1612073',
'1612135',
'1612141',
'1612147',
'1612150',
'1612183',
'1612231',
'1612234',
'1612248',
'1612251',
'1612268',
'1612407',
'1612474',
'1612538',
'1612648',
'1612673',
'1612674',
'1612813',
'1612859',
'1612926',
'1613088',
'1613241',
'1613347',
'1613370',
'1613417',
'1613532',
'1613564',
'1613624',
'1613730',
'1613892',
'1613893',
'1613921',
'1613979',
'1614119',
'1615099',
'1616891',
'1617226',
'1617272',
'1617770',
'1617936',
'1617991',
'1618192',
'1618414',
'1618648',
'1618659',
'1619159',
'1620442',
'1630039',
'1630041',
'1630763',
'1630836',
'1630863',
'1630890',
'1630938',
'1630945',
'1633522',
'1633984',
'1633985',
'1636085',
'1636092',
'1636099',
'1636100',
'1636101',
'1636102',
'1636151',
'1636814',
'1638691',
'1639077',
'1639153',
'1640819',
'1641003',
'1641837',
'1641838',
'1642534',
'1643001',
'1644234',
'1644625',
'1645244',
'1645667',
'1651586',
'1652432',
'1652595',
'1652606',
'1652610',
'1652697',
'1653485',
'1653613',
'1653983',
'1654222',
'1654531',
'1654696',
'1654900',
'1654945',
'1656087',
'1656097',
'1656110',
'1656113',
'1656128',
'1656152',
'1656230',
'1656253',
'1657395',
'1657396',
'1657397',
'1657398',
'1657415',
'1657416',
'1657417',
'1657418',
'1657419',
'1657420',
'1657422',
'1657423',
'1657424',
'1657425',
'1657441',
'1657485',
'1657487',
'1657489',
'1657490',
'1657491',
'1657493',
'1657494',
'1657495',
'1657496',
'1658567',
'1658575',
'1658787',
'1661417',
'1661616',
'1662332',
'1662573',
'1662618',
'1663255',
'1663853',
'1664106',
'1665211',
'1665451',
'1665539',
'1671551',
'1671845',
'1672452',
'1672453',
'1672519',
'1673768',
'1674650',
'1674651',
'1675012',
'1675043',
'1675102',
'1675142',
'1675144',
'1675145',
'1675146',
'1675148',
'1675150',
'1675152',
'1675153',
'1675154',
'1675155',
'1675156',
'1675157',
'1675158',
'1675159',
'1675161',
'1675166',
'1675241',
'1675539',
'1675975',
'1676690',
'1677033',
'1677038',
'1677236',
'1678275',
'1678276',
'1678284',
'1684775',
'1685106',
'1686765',
'1687859',
'1689378',
'1689415',
'1689533',
'1690307',
'1692315',
'1693038',
'1693133',
'1695436',
'1696179',
'1697046',
'1698015',
'1699695',
'1699705',
'1699738',
'1700244',
'1700819',
'1703502',
'1703505',
'1707018',
'1708037',
'1708518',
'1713857',
'1714281',
'1715972',
'1716184',
'1717214',
'1719166',
'1723168',
'1725102',
'1725880',
'3052521',
'3053729',
'3055757',
'3057424',
'3057817',
'3057818',
'3057819',
'3057826',
'3057827',
'3057832',
'3057833',
'3057834',
'3057835',
'3057840',
'3057843',
'3057855',
'3057856',
'3057858',
'3057859',
'3057862',
'3057884',
'3057886',
'3057888',
'3057891',
'3057903',
'3057907',
'3057912',
'3057926',
'3057931',
'3057932',
'3057938',
'3057943',
'3057944',
'3057945',
'3057947',
'3057951',
'3057956',
'3057961',
'3057963',
'3057973',
'3057974',
'3057983',
'3057987',
'3057992',
'3057999',
'3058015',
'3058024',
'3058029',
'3058035',
'3058044',
'3058047',
'3058049',
'3058050',
'3058052',
'3058067',
'3058069',
'3058072',
'3058078',
'3058080',
'3058082',
'3058085',
'3058093',
'3058106',
'3058110',
'3058116',
'3058121',
'3058131',
'3058132',
'3058136',
'3058142',
'3058151',
'3058152',
'3058154',
'3058155',
'3058156',
'3058159',
'3058161',
'KOLL006'

)

order by prov_id asc