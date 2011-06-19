begin;
-- UCOA Form 990EZ
--
SELECT account_heading_save(NULL,'1000','Cash', NULL);
SELECT account_save(NULL,'1010','Cash in bank-operating','A','22', NULL, false, false, string_to_array('AR_paid:AP_paid', ':'));
SELECT account_save(NULL,'1020','Cash in bank-payroll','A','22', NULL, false, false, string_to_array('AP_paid', ':'));
SELECT account_save(NULL,'1040','Petty cash','A','22', NULL, false, false, string_to_array('AR_paid:AP_paid', ':'));
SELECT account_save(NULL,'1070','Savings & short-term investments','A','22', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'1100','Accounts receivable', NULL);
SELECT account_save(NULL,'1110','Accounts receivable','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1115','Doubtful accounts allowance','A','24', NULL, '1',string_to_array('AR_paid', ':'));
SELECT account_heading_save(NULL,'1200','Contributions receivable', NULL);
SELECT account_save(NULL,'1210','Pledges receivable','A','24', NULL, false, false, string_to_array('AR', ':'));
SELECT account_save(NULL,'1215','Doubtful pledges allowance','A','24', NULL, '1',string_to_array('AR_paid', ':'));
SELECT account_save(NULL,'1225','Discounts - long-term pledges','A','24', NULL, '1',string_to_array('AR_paid', ':'));
SELECT account_save(NULL,'1240','Grants receivable','A','24', NULL, false, false, string_to_array('AR', ':'));
SELECT account_save(NULL,'1245','Discounts - long-term grants','A','24', NULL, '1',string_to_array('AR_paid', ':'));
SELECT account_heading_save(NULL,'1300','Other receivables', NULL);
SELECT account_save(NULL,'1310','Employee & trustee receivables','A','24', NULL, false, false, string_to_array('AR', ':'));
SELECT account_save(NULL,'1320','Notes/loans receivable','A','24', NULL, false, false, string_to_array('AR', ':'));
SELECT account_save(NULL,'1325','Doubtful notes/loans allowance','A','24', NULL, '1',string_to_array('AR_paid', ':'));
SELECT account_heading_save(NULL,'1400','Other assets', NULL);
SELECT account_save(NULL,'1410','Inventories for sale','A','24', NULL, false, false, string_to_array('IC', ':'));
SELECT account_save(NULL,'1420','Inventories for use','A','24', NULL, false, false, string_to_array('IC', ':'));
SELECT account_save(NULL,'1450','Prepaid expenses','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1460','Accrued revenues','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'1500','Investments', NULL);
SELECT account_save(NULL,'1510','Marketable securities ','A','22', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1530','Land held for investment','A','22', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1540','Buildings held for investment','A','22', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1545','Accum deprec - bldg investment','A','22', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'1580','Investments - other','A','22', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'1600','Fixed operating assets', NULL);
SELECT account_save(NULL,'1610','Land - operating','A','23', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1620','Buildings - operating','A','23', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1630','Leasehold improvements','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1640','Furniture, fixtures, & equip','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1650','Vehicles','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1660','Construction in progress','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'1700','Accum deprec - fixed operating assets', NULL);
SELECT account_save(NULL,'1725','Accum deprec - building','A','23', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'1735','Accum amort - leasehold improvements','A','24', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'1745','Accum deprec - furn,fix,equip','A','24', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'1755','Accum deprec - vehicles','A','24', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'1810','Other long-term assets','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1850','Split-interest agreements','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1910','Collections - art, etc','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'1950','Funds held in trust by others','A','24', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'2000','Payables', NULL);
SELECT account_save(NULL,'2010','Accounts payable','L','26', NULL, false, false, string_to_array('AP', ':'));
SELECT account_save(NULL,'2020','Grants & allocations payable','L','26', NULL, false, false, string_to_array('AP', ':'));
SELECT account_heading_save(NULL,'2100','Accrued liabilities', NULL);
SELECT account_save(NULL,'2110','Accrued  payroll','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2120','Accrued paid leave','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2130','Accrued payroll taxes','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2140','Accrued sales taxes','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2150','Accrued expenses - other','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'2300','Unearned/deferred revenue', NULL);
SELECT account_save(NULL,'2310','Deferred contract revenue','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2350','Unearned/deferred revenue - other','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2410','Refundable advances','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'2500','Short-term notes & loans payable', NULL);
SELECT account_save(NULL,'2510','Trustee & employee loans payable','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2550','Line of credit','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2560','Current portion - long-term loan','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2570','Short-term liabilities - other','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2610',' Split-interest liabilities','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'2700','Long-term notes & loans payable', NULL);
SELECT account_save(NULL,'2710','Bonds payable','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2730','Mortgages payable','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2750','Capital leases','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2770','Long-term liabilities - other','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2810','Gov\'t-owned fixed assets liability','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'2910','Custodial funds','L','26', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'3000','Unrestricted net assets', NULL);
SELECT account_save(NULL,'3010','Unrestricted net assets','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'3020','Board-designated net assets','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'3030','Board designated quasi-endowment','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'3040','Fixed operating net assets','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'3100','Temporarily restricted net assets', NULL);
SELECT account_save(NULL,'3110','Use restricted net assets','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'3120','Time restricted net assets','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'3200','Permanently restricted net assets', NULL);
SELECT account_save(NULL,'3210','Endowment net assets','Q','21&27', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'4000','Revenue from direct contributions', NULL);
SELECT account_save(NULL,'4010','Individual/small business contributions','I','1', NULL, false, false, string_to_array('AR_amount:IC_income', ':'));
SELECT account_save(NULL,'4020','Corporate contributions','I','1', NULL, false, false, string_to_array('AR_amount:IC_income', ':'));
SELECT account_save(NULL,'4070','Legacies & bequests','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4075','Uncollectible pledges - estimated','I','1', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'4085','Long-term pledges discount','I','1', NULL, '1',string_to_array('', ':'));
SELECT account_heading_save(NULL,'4100','Donated goods & services revenue', NULL);
SELECT account_save(NULL,'4110','Donated professional services-GAAP','I','', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4120','Donated other services - non-GAAP','I','', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4130','Donated use of facilities','I','', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4140','Gifts in kind - goods','I','1', NULL, false, false, string_to_array('AR_amount:IC_sale', ':'));
SELECT account_save(NULL,'4150','Donated art, etc','I','1', NULL, false, false, string_to_array('AR_amount:IC_sale', ':'));
SELECT account_heading_save(NULL,'4200','Revenue from non-government grants', NULL);
SELECT account_save(NULL,'4210','Corporate/business grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4230','Foundation/trust grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4250','Nonprofit organization grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4255','Discounts - long-term grants','I','1', NULL, '1',string_to_array('', ':'));
SELECT account_heading_save(NULL,'4300','Revenue from split-interest agreements', NULL);
SELECT account_save(NULL,'4310','Split-interest agreement contributions','I','1', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'4350','Gain (loss) split-interest agreements','I','1', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'4400','Revenue from indirect contributions', NULL);
SELECT account_save(NULL,'4410','United Way or CFC contributions','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4420','Affiliated organizations revenue','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4430','Fundraising agencies revenue','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_heading_save(NULL,'4500','Revenue from government grants', NULL);
SELECT account_save(NULL,'4510','Agency (government) grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4520','Federal grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4530','State grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'4540','Local government grants','I','1', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_heading_save(NULL,'5000','Revenue from government agencies', NULL);
SELECT account_save(NULL,'5010','Agency (government) contracts/fees','I','2', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5020','Federal contracts/fees','I','2', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5030','State contracts/fees','I','2', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5040','Local government contracts/fees','I','2', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5080','Medicare/Medicaid payments','I','2', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'5100','Revenue from program-related sales & fees', NULL);
SELECT account_save(NULL,'5180','Program service fees','I','2', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5185','Bad debts, est - program fees','I','2', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'5200','Revenue from dues', NULL);
SELECT account_save(NULL,'5210','Membership dues-individuals','I','3', NULL, false, false, string_to_array('AR_amount:IC_income', ':'));
SELECT account_save(NULL,'5220','Assessments and dues-organizations','I','3', NULL, false, false, string_to_array('AR_amount:IC_income', ':'));
SELECT account_heading_save(NULL,'5300','Revenue from investments', NULL);
SELECT account_save(NULL,'5310','Interest-savings/short-term investments','I','4', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5320','Dividends & interest - securities','I','4', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5330','Real estate rent - debt-financed','I','8', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'5335','Real estate rental cost - debt-financed','I','8', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'5340','Real estate rent - not debt-financed','I','8', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'5345','Real estate rental cost - not debt-financed','I','8', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'5350','Personal property rent','I','8', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'5355','Personal property rental cost','I','8', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'5360','Other investment income','I','4', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5370','Securities sales - gross','I','5a', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'5375','Securities sales cost ','I','5b', NULL, '1',string_to_array('', ':'));
SELECT account_heading_save(NULL,'5400','Revenue from other sources', NULL);
SELECT account_save(NULL,'5410','Non-inventory sales - gross','I','5a', NULL, false, false, string_to_array('AR_amount:IC_income', ':'));
SELECT account_save(NULL,'5415','Non-inventory sales cost ','I','5b', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'5440','Gross sales - inventory','I','8', NULL, false, false, string_to_array('AR_amount:IC_sale', ':'));
SELECT account_save(NULL,'5445','Cost of inventory sold ','I','8', NULL, '1',string_to_array('', ':'));
SELECT account_save(NULL,'5450','Advertising revenue','I','8', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5460','Affiliate revenues from other entities','I','8', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5490','Misc revenue','I','8', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_heading_save(NULL,'5800','Special events', NULL);
SELECT account_save(NULL,'5810','Special events - non-gift revenue','I','6a', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_save(NULL,'5820','Special events - gift revenue','I','1&(6a)', NULL, false, false, string_to_array('AR_amount', ':'));
SELECT account_heading_save(NULL,'6800','Unrealized gain (loss)', NULL);
SELECT account_save(NULL,'6810','Unrealized gain (loss) - investments','I','', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'6820','Unrealized gain (loss) - other assets','I','', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'6900','Net assets released from restriction', NULL);
SELECT account_save(NULL,'6910','Satisfaction of use restriction','I','', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'6920','LB&E acquisition satisfaction','I','', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'6930','Time restriction satisfaction','I','', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'7000','Grantscts, & direct assistance', NULL);
SELECT account_save(NULL,'7010','Contracts - program-related','E','10', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7020','Grants to other organizations','E','10', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7040','Awards & grants - individuals','E','10', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7050','Specific assistance - individuals','E','10', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7060','Benefits paid to or for members','E','11', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_heading_save(NULL,'7200','Salaries & related expenses', NULL);
SELECT account_save(NULL,'7210','Officers & directors salaries','E','12', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'7220','Salaries & wages - other','E','12', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'7230','Pension plan contributions','E','12', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'7240','Employee benefits - not pension','E','12', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'7250','Payroll taxes, etc.','E','12', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'7500','Contract service expenses', NULL);
SELECT account_save(NULL,'7510','Fundraising fees','E','13', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7520','Accounting fees','E','13', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7530','Legal fees','E','13', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7540','Professional fees - other','E','13', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7550','Temporary help - contract','E','13', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7580','Donated professional services - GAAP','E','', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'7590','Donated other services - non-GAAP','E','', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_heading_save(NULL,'8100','Nonpersonnel expenses', NULL);
SELECT account_save(NULL,'8110','Supplies','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8120','Donated materials & supplies','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8130','Telephone & telecommunications','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8140','Postage & shipping','E','15', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8150','Mailing services','E','15', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8170','Printing & copying','E','15', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8180','Books, subscriptions, references','E','15', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8190','In-house publications','E','15', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_heading_save(NULL,'8200','Facility & equipment expenses', NULL);
SELECT account_save(NULL,'8210','Rent, parking, other occupancy','E','14', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8220','Utilities','E','14', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8230','Real estate taxes','E','14', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'8240','Personal property taxes','E','14', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'8250','Mortgage interest','E','14', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8260','Equipment rental & maintenance','E','14', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8270','Deprec & amort - allowable','E','16', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'8280','Deprec & amort - not allowable','E','16', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'8290','Donated facilities ','E','', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'8300','Travel & meetings expenses', NULL);
SELECT account_save(NULL,'8310','Travel','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8320','Conferences, conventions, meetings','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_heading_save(NULL,'8500','Other expenses', NULL);
SELECT account_save(NULL,'8510','Interest-general','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8520','Insurance - non-employee related','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8530','Membership dues - organization','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8540','Staff development','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8550','List rental','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8560','Outside computer services','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8570','Advertising expenses','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8580','Contingency provisions','E','16', NULL, false, false, string_to_array('AP_amount', ':'));
SELECT account_save(NULL,'8590','Other expenses','E','16', NULL, false, false, string_to_array('AP_amount:IC_expense', ':'));
SELECT account_heading_save(NULL,'8600','Business expenses', NULL);
SELECT account_save(NULL,'8610','Bad debt expense ','E','16', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'8620','Sales taxes','E','16', NULL, false, false, string_to_array('AP_tax', ':'));
SELECT account_save(NULL,'8630','UBITaxes ','E','16', NULL, false, false, string_to_array('AP_tax', ':'));
SELECT account_save(NULL,'8650','Taxes - other','E','16', NULL, false, false, string_to_array('AP_tax', ':'));
SELECT account_save(NULL,'8660','Fines, penalties, judgments','E','16', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'8670','Organizational (corp) expenses','E','16', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'9800','Fixed asset purchases ', NULL);
SELECT account_save(NULL,'9810','Capital purchases - land','A','capitalized', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'9820','Capital purchases - building','A','capitalized', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'9830','Capital purchases - equipment','A','capitalized', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'9840','Capital purchases - vehicles','A','capitalized', NULL, false, false, string_to_array('', ':'));
SELECT account_heading_save(NULL,'9900','Other Allocations', NULL);
SELECT account_save(NULL,'9910','Payments to affiliates','E','16', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'9920','Additions to reserves','E','', NULL, false, false, string_to_array('', ':'));
SELECT account_save(NULL,'9930','Program administration allocations','E','', NULL, false, false, string_to_array('', ':'));
--
insert into tax (chart_id,rate) values ((select id from chart where accno = '8620'),0);
insert into tax (chart_id,rate) values ((select id from chart where accno = '8630'),0);
insert into tax (chart_id,rate) values ((select id from chart where accno = '8650'),0);
--
INSERT INTO defaults (setting_key, value) VALUES ('inventory_accno_id', (select id from chart where accno = '1410'));

 INSERT INTO defaults (setting_key, value) VALUES ('income_accno_id', (select id from chart where accno = '4010'));

 INSERT INTO defaults (setting_key, value) VALUES ('expense_accno_id', (select id from chart where accno = '7510'));

 INSERT INTO defaults (setting_key, value) VALUES ('fxgain_accno_id', (select id from chart where accno = '5490'));

 INSERT INTO defaults (setting_key, value) VALUES ('fxloss_accno_id', (select id from chart where accno = '8590'));

 INSERT INTO defaults (setting_key, value) VALUES ('curr', 'USD');

 INSERT INTO defaults (setting_key, value) VALUES ('weightunit', 'lbs');

commit;
UPDATE account
   SET tax = true
WHERE id
   IN (SELECT account_id
       FROM account_link
       WHERE description LIKE '%_tax');

