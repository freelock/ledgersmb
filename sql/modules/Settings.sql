-- VERSION 1.3.0

CREATE OR REPLACE FUNCTION setting_set (in_key varchar, in_value varchar) 
RETURNS VOID AS
$$
BEGIN
	UPDATE defaults SET value = in_value WHERE setting_key = in_key;
	RETURN;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION setting_get (in_key varchar) RETURNS varchar AS
$$
DECLARE
	out_value varchar;
BEGIN
	SELECT value INTO out_value FROM defaults WHERE setting_key = in_key;
	RETURN out_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setting_get_default_accounts () 
RETURNS SETOF defaults AS
$$
DECLARE
	account defaults%ROWTYPE;
BEGIN
	FOR account IN 
		SELECT * FROM defaults 
		WHERE setting_key like '%accno_id'
	LOOP
		RETURN NEXT account;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setting_increment (in_key varchar) returns varchar
AS
$$
DECLARE
	base_value VARCHAR;
	raw_value VARCHAR;
	increment INTEGER;
	inc_length INTEGER;
	new_value VARCHAR;
BEGIN
	SELECT value INTO raw_value FROM defaults 
	WHERE setting_key = in_key
	FOR UPDATE;

	SELECT substring(raw_value from  '(' || E'\\' || 'd*)(' || E'\\' || 'D*|<' || E'\\' || '?lsmb [^<>] ' || E'\\' || '?>)*$')
	INTO base_value;

	IF base_value like '0%' THEN
		increment := base_value::integer + 1;
		SELECT char_length(increment::text) INTO inc_length;

		SELECT overlay(base_value placing increment::varchar
			from (select char_length(base_value) 
				- inc_length + 1) for inc_length)
		INTO new_value;
	ELSE
		new_value := base_value::integer + 1;
	END IF;
	SELECT regexp_replace(raw_value, base_value, new_value) INTO new_value;
	UPDATE defaults SET value = new_value WHERE setting_key = in_key;

	return new_value;	
END;
$$ LANGUAGE PLPGSQL;

-- Table schema defaults

ALTER TABLE entity ADD control_code TEXT default setting_increment('entity_control');
