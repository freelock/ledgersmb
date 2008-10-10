-- VERSION 1.3.0

CREATE OR REPLACE FUNCTION account_get (in_id int) RETURNS chart AS
$$
DECLARE
	account chart%ROWTYPE;
BEGIN
	SELECT * INTO account FROM chart WHERE id = in_id;
	RETURN account;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION account_is_orphaned (in_id int) RETURNS bool AS
$$
BEGIN
	PERFORM trans_id FROM acc_trans WHERE chart_id = in_id LIMIT 1;
	IF FOUND THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE plpgsql;

