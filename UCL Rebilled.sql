
with ucl as
(

select 
 ucl.UCL_ID
,ACCOUNT_ID
,SERVICE_DATE_DT
,eap.PROC_CODE 
,eap.PROC_NAME

from clarity_ucl ucl
left join CLARITY_EAP eap on eap.PROC_ID = ucl.PROCEDURE_ID
where ucl_id in --(295346322)
(
295346322,
298535805,
298549200,
298559604,
298561072,
298571577,
298583033,
298600891,
298627075,
298629812,
298643084,
298649562,
298675730,
298682442,
298683119,
298683701,
298792496,
298840748,
298974064,
299082695,
299097571,
299253726,
299255860,
299265228,
299318132,
299318258,
299372356,
299404271,
299415145,
299417614,
299432119,
299440133,
299465829,
299477883,
299524703,
299527022,
299550768,
299598119,
299642687,
299669154,
299692237,
299693305,
299699650,
299811899,
299813525,
299824002,
299830219,
299856283,
299997743,
299999669,
300018389,
300063715,
300122020,
300221901,
300279461,
300296542,
300300012,
300308767,
300327426,
300335759,
300344912,
300379905,
300414919,
300423260,
300445757,
300463597,
300550389,
300578359,
300638246,
300683144,
300697718,
300781290,
300801309,
300806535,
301081638,
301086645,
301278453,
301354521,
301402010,
301407760,
301459899,
301516781,
301519883,
301549251,
301665808,
301668200,
301671981,
301720259,
301791885,
301795471,
301797490,
301959221,
301985304,
302038575,
302039393,
302109544,
302137729,
302139834,
302153739,
302154556,
302158263,
302160390,
302333029,
302333397,
302337100,
302358756,
302360582,
302421099,
302525962,
302550281,
302554822,
302773245,
302817056,
302845310,
302888613,
302933012,
302961725,
302998523,
303066064,
303137827,
303196074,
303280051,
303302615,
303369527,
303374903,
303385928,
303450817,
303463548,
303463660,
303515565,
303559067,
303567979,
303607126,
303680657,
303826383,
303827981,
303848806,
303858672,
303859712,
303870842,
303895615,
304014369,
304035044,
304041492,
304042514,
304047409,
304098313,
304132531,
304247764,
304253427,
304256921,
304272648,
304299448,
304380075,
304395109,
304438784,
304570084,
304574200,
304598631,
304653846,
304682745,
304693256,
304694589,
304712860,
304796581,
304857751,
304868145,
304917447,
305187181,
305262749,
305341999,
305450247,
305483056,
305499414,
305512302,
305519636,
305522336,
305528489,
305617717,
305639933,
305766560,
305773873,
305776880,
305782118,
305783460,
305810573,
306129427,
306167613,
306181729,
306183578,
306246547,
306305776,
306353435,
306409179,
306444817,
306449913,
306456283,
306461015,
306565221,
306611397,
306612006,
306627131,
306658012,
306711334,
306738627,
306767569,
306767829,
306923279,
306962871,
307022624,
307041909,
307044843,
307064079,
307101101,
307189118,
307216325,
307223733,
307272665,
307320035,
307326264,
307359423,
307360228,
307362510,
307384581,
307387560,
307525594,
307528843,
307537800,
307550016,
307562628,
307566075,
307572398,
307583755,
307591696,
307594975,
307606831,
307657512,
307658653,
307658995,
307659149,
307667957,
307794104,
307898740,
308025264,
308150122,
308155243,
308191466,
308192647,
308224284,
308225196,
308226306,
308313690,
308392044,
308416280,
308426805,
308465162,
308474623,
308490328,
308572440,
308586640,
308600003,
308600265,
308638234,
308741774,
308755170,
308806783,
308838972,
308909998,
308926061,
309065857,
309084690,
309090265,
309137734,
309148393,
309217669,
309256361,
309421842,
309422243,
309472594,
309776612,
309776809,
309813094,
309869802,
309904732,
309985632,
310020724,
310075063,
310092182,
310119160,
310163152,
310179361,
310184728,
310184858,
310337872,
310398947,
310399807,
310415235,
310449808,
310470455,
310483082,
310491185,
310494854,
310601259,
310601278,
310646067,
310809763,
310810492,
310812290,
310854706,
311070826,
311071216,
311085128,
311110047,
311125698,
311130001,
311242598,
311264337,
311354612,
311361805,
311393668,
311408751,
311474748,
311478056,
311481494,
311515541,
311527485,
311611716,
311682604,
311688732,
311723156,
311724966,
311735674,
311818005,
311818185,
311873700,
311907712,
311951766,
311984945,
312053278,
312055633,
312056573,
312168087,
312176870,
312197894,
312237294,
312256991,
312287132,
312456960,
312513156,
312528200,
312542759,
312552377,
312592836,
312607511,
312609640,
312618632,
312622055,
312759236,
312831863,
312847176,
312874671,
312877025,
312922673,
312926529,
312942925,
313017133,
313025862,
313063859,
313222914,
313307116,
313353167,
313397198,
313415567,
313420598,
313420681,
313491700,
313521210,
313561047,
313650476,
313657439,
313660198,
313691829,
313703991,
313767197,
313767414,
313767452,
313780833,
313834376,
313866017,
313898713,
313991334,
314046011,
314083580,
314092586,
314102797,
314132131,
314183925,
314267393,
314296442,
314298410,
314316414,
314355588,
314449527,
314481373,
314493793,
314496360,
314503878,
314616492,
314661739,
314687076,
314692184,
314708613,
314722823,
314728019,
314788628,
314915366,
314921629,
314925736,
314931532,
315029420,
315067268,
315073941,
315080012,
315191752,
315199825,
315210650,
315213048,
315227416,
315229731,
315240904,
315245617,
315251548,
315254354,
315297956,
315360339,
315365145,
315397733,
315414813,
315417260,
315426764,
315430296,
315437374,
315441814,
315454119,
315457277,
315457394,
315459765,
315470398,
315482065,
315486928,
315488382,
315509168,
315535934,
315537819,
315559007,
315559382,
315595882,
315619571,
315623004,
315632828,
315642689,
315642971,
315647921,
315665361,
315673130,
315682569,
315683924,
315696031,
315715750,
315733430,
315737879,
315742018,
315758267,
315768620,
315775589,
315777403,
315808077,
315815477,
315820479,
315825718,
315830417,
315839782,
315840542,
315853052,
315853920,
315860530,
315874551,
315884478,
315928646,
315993929,
316010013,
316012000,
316014726,
316018376,
316020603,
316049049,
316081325,
316109699,
316118212,
316121686,
316124204,
316135941,
316141220,
316155064,
316161626,
316170663,
316181450,
316207146,
316207623,
316207884,
316209640,
316211998,
316213345,
316214372,
316218388,
316220138,
316240002,
316247073,
316262610,
316299755,
316358545,
316359678,
316368383,
316373829,
316387816,
316401083,
316406159,
316409456,
316436963,
316465979,
316468659,
316477894,
316480833,
316493174,
316499909,
316500692,
316532450,
316541700,
316548797,
316548933,
316554858,
316558470,
316570931,
316590543,
316597881,
316597963,
316600739,
316600928,
316617834,
316639042,
316678670,
316679089,
316711929,
316718880,
316721873,
316730556,
316733313,
316734166,
316740866,
316743011,
316744705,
316751439,
316752580,
316758123,
316769345,
316790353,
316794625,
316812990,
316814722,
316815357,
316817462,
316822669,
316837527,
316850268,
316853599,
316859534,
316863796,
316869924,
316889462,
316898658,
316902398,
316910896,
316921787,
316931624,
316935115,
316936965,
316940696,
316948722,
316948830,
316948997,
316949227,
316969571,
317011011,
317035502,
317065891,
317082627,
317096788,
317167788,
317180902,
317196305,
317196478,
317196886,
317224496,
317233328,
317266483,
317287155,
317320783,
317338395,
317348037,
317365198,
317377649,
317379542,
317409798,
317437172,
317451650,
317452541,
317455076,
317458869,
317472787,
317479383,
317503780,
317504926,
317519255,
317525564,
317526686,
317533982,
317534542,
317540435,
317543413,
317543563,
317543880,
317546725,
317547696,
317549640,
317556837,
317557144,
317560480,
317560915,
317560916,
317564583,
317566267,
317580392,
317589795,
317596190,
317604994,
317621778,
317636931,
317675848,
317686142,
317691970,
317696035,
317705941,
317713998,
317721213,
317733456,
317751311,
317769877,
317773448,
317787068,
317805394,
317815339,
317823291,
317828754,
317833608,
317854226,
317856083,
317865067,
317867647,
317878905,
317887356,
317897925,
317898471,
317909626,
317910404,
317911306,
317918980,
317920106,
317966518,
317985303,
318041236,
318063026,
318066723,
318069952,
318074887,
318079059,
318088522,
318088744,
318093023,
318098553,
318098686,
318107372,
318110608,
318115354,
318117756,
318128492,
318138550,
318139513,
318142783,
318144860,
318157674,
318158024,
318189648,
318193364,
318194975,
318209425,
318237941,
318250007,
318255752,
318257149,
318260154,
318260384,
318261350,
318263842,
318273021,
318278786,
318281099,
318281266,
318282519,
318284128,
318291762,
318300350,
318300681,
318389407,
318414027,
318451076,
318457928,
318460376,
318469054,
318470934,
318508368,
318513365,
318514552,
318515993,
318517505,
318522259,
318522714,
318526291,
318536159,
318536579,
318539515,
318541913,
318545072,
318556669,
318563128,
318569947,
318570392,
318574410,
318576783,
318579699,
318591591,
318605095,
318608121,
318608223,
318623667,
318624015,
318626170,
318627340,
318627799,
318636636,
318641903,
318642994,
318651764,
318651795,
318659518,
318691105,
318695676,
318700718,
318706334,
318724690,
318755101,
318755140,
318777466,
318782554,
318785325,
318789659,
318801622,
318810557,
318826828,
318831564,
318835676,
318837642,
318846901,
318868243,
318876459,
318878288,
318879361,
318884717,
318884924,
318895578,
318900078,
318905638,
318938996,
318948557,
318950404,
318958720,
318962391,
318965252,
318967903,
318971348,
318978397,
319091262,
319091686,
319097809,
319098412,
319111940,
319112017,
319118091,
319118111,
319118568,
319119353,
319124127,
319128610,
319138044,
319140190,
319141612,
319152729,
319167866,
319168206,
319170353,
319206262,
319249712,
319250001,
319256038,
319271869,
319282732,
319283450,
319284441,
319285043,
319295040,
319299955,
319358690,
319361217,
319378207,
319378308,
319386656,
319394297,
319418932,
319427893,
319431407,
319435677,
319446241,
319475389,
319479430,
319481100,
319481287,
319481436,
319489298,
319491611,
319494828,
319528685,
319559336,
319561948,
319568137,
319575992,
319577598,
319596093,
319600882,
319603660,
319604429,
319606075,
319611423,
319614795,
319616618,
319619074,
319636543,
319644031,
319650018,
319712953,
319714030,
319746612,
319752298,
319759217,
319763788,
319765579,
319799612,
319801881,
319806147,
319817476,
319821685,
319834509,
319835624,
319838819,
319840349,
319846270,
319846575,
319854626,
319856526,
319860338,
319860523,
319862308,
319864639,
319893268,
319895592,
319896998,
319904086,
319914201,
319914552,
319919581,
319922300,
319932912,
319938345,
319945264,
319958231,
319961138,
319970492,
319971556,
319971575,
319972653,
319981828,
320010691,
320017218,
320024488,
320029392,
320104620,
320119309,
320128122,
320157300
)
)

select 
 ucl.ACCOUNT_ID
,cast(tdl.ORIG_SERVICE_DATE as date) as SERVICE_DATE
,ucl.UCL_ID
,ucl.PROC_CODE as UCL_CODE
,ucl.PROC_NAME as UCL_DESC
,tdl.TX_ID
,tdl.R_ORIG_CHG_TX_ID
,eap.PROC_CODE
,eap.PROC_NAME
,cast(arpb_tx.VOID_DATE as date) as VOID_DATE

from ucl
inner join CLARITY_TDL_TRAN tdl 
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID

on tdl.ACCOUNT_ID = ucl.ACCOUNT_ID and tdl.ORIG_SERVICE_DATE = ucl.SERVICE_DATE_DT and tdl.DETAIL_TYPE = 1