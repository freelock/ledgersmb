-- SQL Fixes for upgrades.  These must be safe to run repeatedly, or they must 
-- fail transactionally.  Please:  one transaction per fix.  
--
-- Chris Travers


BEGIN; -- 1.3.4, fix for menu-- David Bandel
update menu_attribute set value = 'receive_order' where value  =
'consolidate_sales_order' and node_id = '65';

update menu_attribute set id = '149' where value  = 'receive_order'
and node_id = '65';

update menu_attribute set value = 'consolidate_sales_order' where
value  = 'receive_order' and node_id = '64';

update menu_attribute set id = '152' where value  =
'consolidate_sales_order' and node_id = '64';

-- fix for bug 3430820
update menu_attribute set value = 'pricegroup' where node_id = '83' and attribute = 'type';
update menu_attribute set value = 'partsgroup' where node_id = '82' and attribute = 'type';

UPDATE menu_attribute SET value = 'partsgroup' WHERE node_id = 91 and attribute = 'type';
UPDATE menu_attribute SET value = 'pricegroup' WHERE node_id = 92 and attribute = 'type';

COMMIT;

BEGIN;
ALTER TABLE entity_credit_account drop constraint "entity_credit_account_language_code_fkey";
COMMIT;

BEGIN;
ALTER TABLE entity_credit_account ADD FOREIGN KEY (language_code) REFERENCES language(code);
COMMIT;
