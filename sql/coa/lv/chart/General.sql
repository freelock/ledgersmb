begin;
-- Latvian COA
-- prepared by Kaspars Melkis <info@isolis.lv>
-- Sept. 14, 2003
-- checked and edited Sept. 20, 2003, D. Simader
--
SELECT account_heading_save(NULL, '1', 'Ilgtermiòa ieguldîjumi', NULL);
SELECT account_heading_save(NULL, '2', 'Apgrozâmie lîdzekïi', NULL);
SELECT account_heading_save(NULL, '11', 'Nemateriâlie ieguldîjumi', NULL);
SELECT account_heading_save(NULL, '12', 'Pamatlîdzekïi', NULL);
SELECT account_save(NULL,'1210','Zemes gabali, çkas, bûves, ilggadîgie stâdîjumi un citi nekustamâ îpaðuma objekti','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'1290','Pamatlîdzekïu nolietojums (pasîvâ)','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_heading_save(NULL, '13', 'Ilgtermiòa finansu ieguldîjumi', NULL);
SELECT account_heading_save(NULL, '21', 'Krâjumi', NULL);
SELECT account_save(NULL,'2130','Gatavâs preces pârdoðanai','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'2310','Norçíini ar pircçjiem un pasûtîtâjiem','','L', NULL, false, false, string_to_array('AP', ':'), false);
SELECT account_heading_save(NULL, '23', 'Norçíini par prasîbâm (ar debitoriem)', NULL);
SELECT account_save(NULL,'2350','Norçíini ar citiem debitoriem','','A', NULL, false, false, string_to_array('AR_amount', ':'), false);
SELECT account_heading_save(NULL, '26', 'Naudas lîdzekïi', NULL);
SELECT account_save(NULL,'2610','Kase','','A', NULL, false, false, string_to_array('AR_paid:AP_paid', ':'), false);
SELECT account_save(NULL,'1380','Aizdevumi uzòçmuma dalîbniekiem un valdei','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'1310','Lîdzdalîba meitas uzòçmumu kapitâlâ','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'1340','Aizdevumi saistîtajiem uzòçmumiem','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'1350','Pârçjie vçrtspapîri','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '5', 'Kreditori', NULL);
SELECT account_save(NULL,'1370','Paðu akcijas un daïas','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2210','Pieauguðie produktîvie lopi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'3350','Statûtos paredzçtâs rezerves','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2220','Jaunlopi un sîkie dzîvnieki','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2320','Par piegâdçm un pasûtîjumiem saòemtie vekseïi','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'2140','Nepabeigtie pasûtîjumi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2370','Îstermiòa aizdevumi sabiedrîbâm dalîbniekiem un vadîbai','','A', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'1360','Pârçjie aizdevumi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2120','Nepabeigtie raþojumi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2330','Meitas uzòçmumu parâdi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2340','Saistîto uzòçmumu parâdi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2380','Norçíini par prasîbâm pret personâlu un îstermiòa aizdevumi personâlam','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2410','Nâkamo periodu izdevumi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2420','Akciju emisijas  nocenojums (disagio)','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '25', 'Vçrtspapîri apgrozâmo lîdzekïu sastâvâ un îstermiòa lîdzdalîba kapitâlos', NULL);
SELECT account_save(NULL,'2510','Meitas  uzòçmuma akcijas un daïas ','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2520','Saistîto uzòçmuma akcijas un daïas ','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2530','Paðu  uzòçmuma akcijas un daïas ','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2540','Pârçjie vçrtspapîri un lîdzdalîba kapitâlos','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2640','Akreditîvi, èeki un îpaðu norçíina  formu konti','','A', NULL, false, false, string_to_array('AR_paid:AP_paid', ':'), false);
SELECT account_save(NULL,'2650','Citi konti bankâs','','A', NULL, false, false, string_to_array('AR_paid:AP_paid', ':'), false);
SELECT account_save(NULL,'2670','Pârçjie naudas lîdzekïi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '3', 'Paðu kapitâls', NULL);
SELECT account_save(NULL,'3130','Ilgtermiòa ieguldîjuma pârvçrtçðanas rezerve','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'3120','Akciju emisijas uzcenojums (agio)','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '32', 'Privâtkonti', NULL);
SELECT account_save(NULL,'3210','Privâtiem nolûkiem izòemtie lîdzekïi','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '33', 'Rezerves ', NULL);
SELECT account_save(NULL,'3310','Rezerves kapitâls','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'3330','Citas likumâ paredzçtâs  rezerves','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'3340','Rezerves paðu akcijâm un daïâm','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'3360','Pârçjâs rezerves','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '34', 'Nesadalîtâ peïòa vai nesegtie zaudçjumi', NULL);
SELECT account_save(NULL,'3410','Pârskata gada nesadalîtâ peïòa','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'3420','Iepriekðçjo gadu nesadalîtâ peïòa','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '4', 'Uzkrâjumi', NULL);
SELECT account_save(NULL,'4110','Uzkrâjumi pensijâm pielîdzinâtâm saistîbâm','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'4310','Citi uzkrâjumi','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '41', 'Uzkrâjumi pensijâm pielîdzinâmâtâm saistîbâm', NULL);
SELECT account_heading_save(NULL, '43', 'Citi uzkrâjumi', NULL);
SELECT account_heading_save(NULL, '42', 'Uzkrâjumi paredzamiem nodokïiem', NULL);
SELECT account_heading_save(NULL, '51', 'Norçíini par aizòçmumiem', NULL);
SELECT account_save(NULL,'5110','Aizòçmumi pret obligâcijâm','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5120','Akcijâs pârvçðamie aizòçmumi','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5130','Aizòçmumi ar lîdzdalîbu peïòâ','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5140','Citi aizòçmumi','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5150','Îstermiòa aizòçmumi  no kredîtiestâdçm','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5160','Ilgtermiòa aizòçmumi no kredîtiestâdçm','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5170','Aizòçmumi no kredîtiestâdçm bez norâdîtâ termiòa','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '52', 'Norçíini par saòemtajiem avansiem', NULL);
SELECT account_save(NULL,'5210','Norçíini par saòemtiem avansiem','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '54', 'Maksâjamie vekseïi', NULL);
SELECT account_heading_save(NULL, '53', 'Norçíini par piegâdâtâjiem un darbuzòçmçjiem', NULL);
SELECT account_save(NULL,'5310','Norçíini par piegâdâtâjiem un darbuzòçmçjiem','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5410','Norçíini par paðu izdotajiem vekseïiem','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5510','Norçíini par parâdiem meitas uzòçmumiem','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5540','Norçíini par parâdiem citiem uzòçmumiem un dalîbniekiem','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5550','Norçíini par parâdiem personâlam','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5520','Norçíini par parâdiem saistîtiem uzòçmumiem','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5530','Norçíini par parâdiem uzòçmumiem, ar kuriem ir lîgums par lîdzdalîbu','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_heading_save(NULL, '57', 'Norçíini par nodokïiem', NULL);
SELECT account_heading_save(NULL, '58', 'Norçíini par  dividendçm', NULL);
SELECT account_heading_save(NULL, '61', 'Ieòçmumi no pârdoðanas, kas apliekami ar nodokïiem vispârçjâ kârtîbâ', NULL);
SELECT account_heading_save(NULL, '62', 'Ieòçmumi no pârdoðanas, kas citâdi  apliekami ar nodokïiem', NULL);
SELECT account_save(NULL,'6220','Ar îpaðiem nodokïiem apliekamie pârdoðanas ieòçmumi','','I', NULL, false, false, string_to_array('AR_amount:IC_income', ':'), false);
SELECT account_heading_save(NULL, '63', 'Komisijas, starpniecîbas un citi ieòçmumi', NULL);
SELECT account_save(NULL,'6310','Komisijas un starpniecîbas ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'6320','Ieòçmumi no atkritumu pârstrâdes un realizâcijas','','I', NULL, false, false, string_to_array('AR_amount:IC_income', ':'), false);
SELECT account_save(NULL,'6330','Ieòçmumi no taras realizâcijas','','I', NULL, false, false, string_to_array('AR_amount:IC_income', ':'), false);
SELECT account_save(NULL,'6340','Ar nodokïiem neapliekamie apgrozîjumi','','I', NULL, false, false, string_to_array('AR_amount:IC_income', ':'), false);
SELECT account_heading_save(NULL, '64', 'Ieòçmumus samazinoðas atlaides', NULL);
SELECT account_save(NULL,'6410','Pieðíirtâs skonto atlaides','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'6420','Pieðíirtie bonusi','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '59', 'Nâkamo periodu ieòçmumi', NULL);
SELECT account_heading_save(NULL, '65', 'Pârçjie uzòçmuma ieòçmumi', NULL);
SELECT account_save(NULL,'6510','Ieòçmumi no vçrtspapîru kursa paaugstinâðanâs','','I', NULL, false, false, string_to_array('AR_amount', ':'), false);
SELECT account_save(NULL,'6530','Ieòçmumi no zemes gabalu iznomâðanas','','I', NULL, false, false, string_to_array('AR_amount', ':'), false);
SELECT account_save(NULL,'6540','Ieòçmumi no apgrozâmo lîdzekïu pârdoðanas','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6550','Ieòçmumi no pamatlîdzekïu iznomâðanas','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6560','Ieòçmumos pârskaitîtais rezervju un uzkrâjumu samazinâjums','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6570','Iepriekðçjo gadu nodokïu samazinâjums','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6580','Papildus  ieguldîjumi un citi ieòçmumi','','I', NULL, false, false, string_to_array('AR_amount', ':'), false);
SELECT account_save(NULL,'6590','Paðu uzòçmuma kapitâlieguldîjumiem izpildîtie darbi','','I', NULL, false, false, string_to_array('AR_amount', ':'), false);
SELECT account_heading_save(NULL, '67', 'Citu periodu ieòçmumi, kas attiecas uz pârskata periodu', NULL);
SELECT account_save(NULL,'6710','Citu periodu ieòçmumi, kas attiecas uz pârskata periodu','','I', NULL, false, false, string_to_array('AR_amount', ':'), false);
SELECT account_heading_save(NULL, '69', 'Sociâlâs infrastruktûras iestâþu un pasâkumu ieòçmumi', NULL);
SELECT account_save(NULL,'6930','Sadzîves paklpojumu ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'6920','Komunâlâs  saimniecîbas ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_heading_save(NULL, '66', 'Gatavâs produkcijas  un nepabeigto  raþojumu krâjumu un vçrtîbas  izmaiòas', NULL);
SELECT account_save(NULL,'6610','Gatavâs produkcijas krâjumu un vçrtîbas izmaiòas','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6620','Nepabeigto raþojumu krâjumu un vçrtîbas  izmaiòas','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6630','Nepabeigto pasûtîjumu atlikumu un vçtîbas izmaiòas','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6640','Produktîvo  un darba dzîvnieku ganâmpulka vçrtîbas izmaiòas','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6940','Sabiedriskâs çdinâðanas ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'6950','Izglîtîbas iestâþu ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'6960','Medicînas iestâþu ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'6970','Kultûras un sporta ietâþu un pasâkumu ieòçmumi','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6980','Pârçjie sociâlâs infrastruktûras iestâþu un pasâkumu ieòçmumi','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '7', 'Saimnieciskâs darbîbas izdevumi', NULL);
SELECT account_heading_save(NULL, '71', 'Izdevumi izejvielu, materiâlu un preèu iepirkðanai', NULL);
SELECT account_save(NULL,'7110','Izejvielu un materiâlu iepirkðanas un piegâdes izdevumi','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7120','Preèu iepirkðanas un piegâdes izdevumi','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7130','Saòemtâs atlaides','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7140','Taras izdevumi','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7150','Muitas un ievednodevas','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7160','Pârçjie ârçjie izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7170','Samaksa par darbiem un pakalpojumiem no ârienes','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7190','Pirkto materiâlu un preèu krâjumu un vçrtîbas izmaiòas','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '72', 'Personâla izmaksas', NULL);
SELECT account_save(NULL,'7210','Strâdnieku algas','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7230','Sociâlâs  infrastruktûras  iestâþu un pasâkumu darbinieku algas','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '73', 'Sociâlâs nodevas un izmaksas', NULL);
SELECT account_save(NULL,'7320','Pârçjâs sociâlâs izmaksas','','E', NULL, false, false, string_to_array('AP_tax', ':'), false);
SELECT account_heading_save(NULL, '74', 'Pamatlîdzekïu nolietojums un citu ieguldîjumu vçrtîbas norakstîjumi', NULL);
SELECT account_save(NULL,'7410','Nemateriâlo ieguldîjumu vçrtîbas norakstîðana','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '75', 'Pârçjie saimnieciskâs darbîbas  izdevumi', NULL);
SELECT account_save(NULL,'7510','Dabas aizsardzîbas izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7530','Nodevas par raþoðanâ izmantotiem zemes gabaliem','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7440','Apgrozâmo lîdzekïu vçrtîbas norakstîðana','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7540','Apdroðinnâðanas maksâjumi (izòemot darbinieku apdroðinâðanu)','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7550','Pârçjie saimnieciskâs darbîbas izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7560','Strâdnieku vervçðanas un apmâcîbas izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_heading_save(NULL, '76', 'Preèu pârdoðanas izdevumi', NULL);
SELECT account_save(NULL,'7610','Iesaiòojamais materiâls, tara','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7620','Preèu transporta izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7630','Preèu transporta apdroðinâðana','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7640','Samaksâtâs komisijas naudas','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7650','Citi pârdoðanas izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_heading_save(NULL, '77', 'Administrâcijas izdevumi', NULL);
SELECT account_save(NULL,'7710','Sakaru izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7720','Kantora (biroja) izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7730','Juristu pakalpojumu apmaksa','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7740','Gada pârskata un revîzijas izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7750','Naudas apgrozîjuma blakus izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7760','Transporta izdevumi administrâcijas vajadzîbâm','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7770','Citi vadîðanas un administrâcijas izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_heading_save(NULL, '78', 'Pârskata periodâ iekïaujamie iepriekðçjo periodu izdevumi', NULL);
SELECT account_save(NULL,'7810','Pârskata periodâ iekïaujamie iepriekðçjo periodu izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_heading_save(NULL, '79', 'Sociâlâs  infrastruktûras uzturçðanas izdevumi', NULL);
SELECT account_save(NULL,'7920','Komuâlâs saimniecîbas izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7940','Sabiedriskâs çdinâðanas izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7950','Izglîtîbas iestâþu izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_heading_save(NULL, '8', 'Daþâdi ieòçmumi un izdevumi, peïòa un zaudçjumi', NULL);
SELECT account_heading_save(NULL, '81', 'Daþâdi ieòçmumi', NULL);
SELECT account_save(NULL,'8110','Ieòçmumi no lîdzdalîbas, vçrtspapîriem un aizdevumiem','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'8120','Pârçjie ieòçmumi no procentiem un tiem pielîdzinâmi ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'7910','Dzîvokïu saimniecîbas izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'8130','Vekseïu diskonta ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'8150','Ienâkumi no valûtas kursa paaugstinâðanâs','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'8160','Saòemtâs soda naudas un lîgumsodi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'8170','Peïòa no ârzemju valûtas pârdoðanas vai pirkðanas','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'8190','Citi ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_heading_save(NULL, '82', 'Daþâdi izdevumi', NULL);
SELECT account_save(NULL,'8210','Îstermiòa finansu ieguldîjumu vçrtîbas norakstîðana','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8220','Samaksâtie procenti un tiem pielîdzinâmie izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8230','Vekseïu diskonta izmaksas','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8240','Ilgtermiòa aizdevumu procentu samaksa','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8260','Samaksâtâs soda naudas un lîgumsodi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8270','Zaudçjumi no ârzemju valûtas pirkðanas un pârdoðanas','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8290','Citi izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_heading_save(NULL, '83', 'Ârkârtas ieòçmumi', NULL);
SELECT account_save(NULL,'8310','Ârkârtas ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_heading_save(NULL, '84', 'Ârkârtas izdevumi', NULL);
SELECT account_save(NULL,'8410','Ârkârtas izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_heading_save(NULL, '86', 'Peïòa vai zaudçjumi', NULL);
SELECT account_save(NULL,'8610','Peïòa vai zaudçjumi','','I', NULL, false, false, string_to_array('IC_income:IC_expense', ':'), false);
SELECT account_save(NULL,'3220','Privâtie ieguldîjumi','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6110','Ieòçmumi no pamatdarbîbas  produkcijas un pakalpojumu pârdoðanas','','I', NULL, false, false, string_to_array('AR_paid', ':'), false);
SELECT account_save(NULL,'1220','Tehnoloìiskâs  iekârtas un maðînas','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'1240','Pamatlîdzekïu izveidoðana un nepabeigto celtniecîbas objektu izmaksas','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'1320','Aizdevumi meitas uzòçmumam','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2110','Izejvielas un materiâli','','A', NULL, false, false, string_to_array('AP', ':'), false);
SELECT account_save(NULL,'2190','Avansa maksâjumi par precçm','','A', NULL, false, false, string_to_array('AR', ':'), false);
SELECT account_save(NULL,'1130','Uzòçmuma nemateriâlâ vçrtîba','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'1180','Avansa maksâjumi par nemateriâliem aktîviem','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'1190','Nemateriâlo ieguldîjumu vçrtîbas norakstîtâ daïa (pasîvâ)','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_heading_save(NULL, '22', 'Produktîvie un darba dzîvnieki', NULL);
SELECT account_save(NULL,'2230','Darba lopi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2290','Darba lopu norakstîtâ vçrtîba (pasîvâ)','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2360','Norçíini par parakstîtâ sabiedrîbas kapitâlâ neiemaksâtâm summâm','','A', NULL, false, false, string_to_array('AR_paid', ':'), false);
SELECT account_heading_save(NULL, '24', 'Nâkamo periodu izdevumi', NULL);
SELECT account_save(NULL,'2620','Norçíinu konti bankâ','','A', NULL, false, false, string_to_array('AR_paid:AP_paid', ':'), false);
SELECT account_save(NULL,'3110','Pamatkapitâls vai lîdzdalîbas kapitâls','','Q', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '55', 'Norçíini ar uzòçmumiem, dalîbniekiem un personâlu', NULL);
SELECT account_heading_save(NULL, '56', 'Norçíini  par darba samaksu  un ieturçjumiem (izòemot nodokïus)', NULL);
SELECT account_save(NULL,'5610','Norçíini par darba algu','','E', NULL, false, false, string_to_array('AP_amount', ':'), false);
SELECT account_save(NULL,'5620','Norçíini par ieturçjumiem no darba algas (izòemot nodokïus)','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5820','Norçíini par iepriekðçjo gadu neizmaksâtajâm dividendçm','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5810','Norçíini par pârskata gada dividendçm','','L', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'5910','Nâkamo periodu ieòçmumi','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '6', 'Ieòçmumi no uzòçmuma saimnieciskâs darbîbas', NULL);
SELECT account_save(NULL,'6210','Ar nodokïiem neapliekamie pârdoðanas ieòçmumi','','I', NULL, false, false, string_to_array('AR_amount:IC_income', ':'), false);
SELECT account_save(NULL,'6430','Pieðíirtie rabati un citas tirdzniecîbas  atlaides','','I', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'6910','Dzîvokïu saimniecîbas ieòçmumi','','I', NULL, false, false, string_to_array('AR_paid', ':'), false);
SELECT account_save(NULL,'7180','Pârçjie materiâlie izdevumi (nodoklis par dabas resursu izmantoðanu, celmu nauda u.c.)','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7240','Pârçjâs personâla izmaksas','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7220','Pârvaldes personâla un administratîvâ personâla algas','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7420','Pamatlîdzekïu nolietojums','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7570','Komandçjuma izdevumi','','E', NULL, false, false, string_to_array('AP_paid', ':'), false);
SELECT account_save(NULL,'7930','Sadzîves pakalpojumu izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7960','Medicîniskâs apkalpoðanas izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7970','Kultûras un sporta iestâþu un pasâkumu izdevumi','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'8140','Ziedojumi un citi tiem pielîdzinâmi ieòçmumi','','I', NULL, false, false, string_to_array('IC_income', ':'), false);
SELECT account_save(NULL,'8250','Zaudçjumi no valûtu  kursa pazeminâðanâs','','E', NULL, false, false, string_to_array('IC_expense', ':'), false);
SELECT account_save(NULL,'7980','Pârçjie sociâlâs infrastruktûras uzturçðanas izdevumi','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_heading_save(NULL, '87', 'Peïòas izlietojums (bez nodokïiem)', NULL);
SELECT account_heading_save(NULL, '88', 'Nodoïi no peïòas un citi saimnieciskâs darbîbas izdevumos neiekïaujamie nodokïi', NULL);
SELECT account_save(NULL,'1110','Pçtniecîbas un uzòçmuma attîstîbas izmaksas','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'1120','Koncesijas, patenti, licences, tirdzniecîbas zîmes un lîdzîgas tiesîbas; datoru programmas','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'1230','Pârçjie pamatlîdzekïi un inventârs','','A', NULL, false, false, string_to_array('IC', ':'), false);
SELECT account_save(NULL,'5710','Norçíini par peïòas nodokli','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2390','Pârmaksâtie nodokïi, iepriekð samaksâtie nodokïi','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'4210','Uzkrâjumi paredzamiem nodokïiem','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'5720','Norçíini par citiem nodokïiem, nodevâm un maksâjumiem budþetam','','L', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'7310','Sociâlais nodoklis','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'8710','Peïòas izlietojums','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'8830','Nodoklis par zemi','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'8840','Citi saimnieciskâs darbîbas izmaksâs neiekïaujamie nodokïi','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'8820','Nodoklis par dabas resursu izmantoðanu no peïòas  maksâjamâ daïâ','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'8810','Nodoklis no peïòas','','E', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'1330','Lîdzdalîbas saistîto uzòçmumu kapitâlâ','','A', NULL, false, false, string_to_array('', ':'), false);
SELECT account_save(NULL,'2354','PVN samaksâts 18%','','E', NULL, false, false, string_to_array('AP_tax:IC_taxpart:IC_taxservice', ':'), false);
SELECT account_save(NULL,'2352','PVN ieòemtais 18%','','L', NULL, false, false, string_to_array('AR_tax:IC_taxpart:IC_taxservice', ':'), false);

SELECT cr_coa_to_account_save(accno, accno || '--' || description)
FROM account WHERE id IN (select account_id FROM account_link
                           WHERE description = 'AP_paid');
--
INSERT INTO tax (chart_id,rate,taxnumber) VALUES ((SELECT id FROM chart where accno = '2352'),'0.18','');
INSERT INTO tax (chart_id,rate,taxnumber) VALUES ((SELECT id FROM chart where accno = '2354'),'0.18','');
--
INSERT INTO defaults (setting_key, value) VALUES ('inventory_accno_id', (select id from chart where accno = '1230'));

 INSERT INTO defaults (setting_key, value) VALUES ('income_accno_id', (select id from chart where accno = '6010'));

 INSERT INTO defaults (setting_key, value) VALUES ('expense_accno_id', (select id from chart where accno = '7110'));

 INSERT INTO defaults (setting_key, value) VALUES ('fxgain_accno_id', (select id from chart where accno = '8170'));

 INSERT INTO defaults (setting_key, value) VALUES ('fxloss_accno_id', (select id from chart where accno = '8270'));

 INSERT INTO defaults (setting_key, value) VALUES ('curr', 'LVL');

 INSERT INTO defaults (setting_key, value) VALUES ('weightunit', 'kg');

commit;
UPDATE account
   SET tax = true
WHERE id
   IN (SELECT account_id
       FROM account_link
       WHERE description LIKE '%_tax');

