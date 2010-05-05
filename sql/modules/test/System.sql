BEGIN;
\i Base.sql

CREATE TABLE test_exempt_funcs (funcname text primary key);

insert into test_exempt_funcs values ('rewrite');
insert into test_exempt_funcs values ('gin_extract_trgm');
insert into test_exempt_funcs values ('plainto_tsquery');
insert into test_exempt_funcs values ('headline');
insert into test_exempt_funcs values ('rank');
insert into test_exempt_funcs values ('to_tsquery');
insert into test_exempt_funcs values ('to_tsvector');
insert into test_exempt_funcs values ('stat');
insert into test_exempt_funcs values ('lexize');
insert into test_exempt_funcs values ('connectby');
insert into test_exempt_funcs values ('parse');
insert into test_exempt_funcs values ('set_curprs');
insert into test_exempt_funcs values ('rank_cd');
insert into test_exempt_funcs values ('set_curdict');
insert into test_exempt_funcs values ('set_curcfg');
insert into test_exempt_funcs values ('token_type');
insert into test_exempt_funcs values ('crosstab');
insert into test_exempt_funcs values ('concat_colon');
insert into test_exempt_funcs values ('to_args');
insert into test_exempt_funcs values ('table_log_restore_table');

create table test_exempt_tables (tablename text, reason text);
insert into test_exempt_tables values ('note', 'abstract table, no data');
insert into test_exempt_tables values ('open_forms', 'security definer only');

insert into test_exempt_tables 
values ('person_to_company', 'Unused in core, for addons only');
insert into test_exempt_tables 
values ('person_to_entity', 'Unused in core, for addons only');

insert into test_exempt_tables values ('test_exempt_funcs', 'test data only');

insert into test_exempt_tables values  ('test_exempt_tables', 'test data only');
insert into test_exempt_tables values ('menu_friendly', 'dev info only');
insert into test_exempt_tables values ('note', 'abstract table, no data');
analyze test_exempt_tables;

INSERT INTO test_result(test_name, success)
select 'No overloaded functions in current schema', count(*) = 0
FROM (select proname FROM pg_proc 
	WHERE pronamespace = 
		(select oid from pg_namespace 
		where nspname = current_schema())
		AND proname NOT IN (select funcname FROM test_exempt_funcs)
	group by proname
	having count(*) > 1
) t;

select proname FROM pg_proc WHERE pronamespace =
	(select oid from pg_namespace 
	where nspname = current_schema())
	AND proname NOT IN (select funcname from test_exempt_funcs)
group by proname
having count(*) > 1;

CREATE TEMPORARY table permissionless_tables AS
select t.table_catalog, t.table_schema, t.table_type, t.table_name
from information_schema.tables t
where t.table_catalog = current_database()
  and t.table_schema = 'public'
  and not exists (
    select *
    from information_schema.role_table_grants r
    where r.table_catalog = t.table_catalog
      and r.table_schema = t.table_schema
      and r.table_name = t.table_name
      )
  and not exists (
     select *
     from test_exempt_tables x
     where x.tablename = t.table_name)
order by t.table_catalog, t.table_schema, t.table_type, t.table_name;

select * from permissionless_tables;

INSERT INTO test_result (test_name, success)
select 'All tables in public have some permissions', count(*)=0 from 
permissionless_tables;
SELECT * FROM test_result;


SELECT (select count(*) from test_result where success is true)
|| ' tests passed and '
|| (select count(*) from test_result where success is not true)
|| ' failed' as message;

ROLLBACK;

