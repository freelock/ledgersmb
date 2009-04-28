
CREATE OR REPLACE FUNCTION payment_type__list() RETURNS SETOF payment_types AS
$$
DECLARE out_row payment_types%ROWTYPE;
BEGIN
	FOR out_row IN SELECT * FROM payment_types LOOP
		RETURN NEXT out_row;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE TYPE payment_vc_info AS (
	id int,
	name text,
	entity_class int,
	discount int
);


CREATE OR REPLACE FUNCTION payment_get_entity_accounts
(in_account_class int,
 in_vc_name text,
 in_vc_idn  text)
 returns SETOF payment_vc_info AS
 $$
 DECLARE out_entity payment_vc_info;
 

 BEGIN
 	FOR out_entity IN
 		SELECT ec.id, cp.legal_name as name, e.entity_class, ec.discount_account_id
 		FROM entity e
 		JOIN entity_credit_account ec ON (ec.entity_id = e.id)
 		JOIN company cp ON (cp.entity_id = e.id)
		WHERE ec.entity_class = in_account_class
		AND (cp.legal_name ilike coalesce('%'||in_vc_name||'%','%%') OR cp.tax_id = in_vc_idn)
	LOOP
		RETURN NEXT out_entity;
	END LOOP;
 END;
 $$ LANGUAGE PLPGSQL;

-- payment_get_open_accounts and the option to get all accounts need to be
-- refactored and redesigned.  -- CT
CREATE OR REPLACE FUNCTION payment_get_open_accounts(in_account_class int) 
returns SETOF entity AS
$$
DECLARE out_entity entity%ROWTYPE;
BEGIN
	FOR out_entity IN
		SELECT ec.id, cp.legal_name as name, e.entity_class, e.created 
		FROM entity e
		JOIN entity_credit_account ec ON (ec.entity_id = e.id)
		JOIN company cp ON (cp.entity_id = e.id)
			WHERE ec.entity_class = in_account_class
                   --  AND CASE WHEN in_account_class = 1 THEN
	           --		e.id IN (SELECT entity_id FROM ap 
	           --			WHERE amount <> paid
		   --			GROUP BY entity_id)
		   -- 	       WHEN in_account_class = 2 THEN
		   --		e.id IN (SELECT entity_id FROM ar
		   --			WHERE amount <> paid
		   --			GROUP BY entity_id)
		   --	  END
	LOOP
		RETURN NEXT out_entity;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

COMMENT ON FUNCTION payment_get_open_accounts(int) IS
$$ This function takes a single argument (1 for vendor, 2 for customer as 
always) and returns all entities with open accounts of the appropriate type. $$;

CREATE OR REPLACE FUNCTION payment_get_all_accounts(in_account_class int) 
RETURNS SETOF entity AS
$$
DECLARE out_entity entity%ROWTYPE;
BEGIN
	FOR out_entity IN
		SELECT  ec.id, 
			e.name, e.entity_class, e.created 
		FROM entity e
		JOIN entity_credit_account ec ON (ec.entity_id = e.id)
				WHERE e.entity_class = in_account_class
	LOOP
		RETURN NEXT out_entity;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

COMMENT ON FUNCTION payment_get_open_accounts(int) IS
$$ This function takes a single argument (1 for vendor, 2 for customer as 
always) and returns all entities with accounts of the appropriate type. $$;


CREATE TYPE payment_invoice AS (
	invoice_id int,
	invnumber text,
	invoice_date date,
	amount numeric,
	amount_fx numeric,
	discount numeric,
	discount_fx numeric,
	due numeric,
	due_fx numeric,
	exchangerate numeric
);

CREATE OR REPLACE FUNCTION payment_get_open_invoices
(in_account_class int,
 in_entity_credit_id int,
 in_curr char(3),
 in_datefrom date, 
 in_dateto date,
 in_amountfrom numeric,
 in_amountto   numeric,
 in_department_id int)
RETURNS SETOF payment_invoice AS
$$
DECLARE payment_inv payment_invoice;
BEGIN
	FOR payment_inv IN
		SELECT a.id AS invoice_id, a.invnumber AS invnumber, 
		       a.transdate AS invoice_date, a.amount AS amount, 
		       a.amount/
		       (CASE WHEN a.curr = (SELECT * from defaults_get_defaultcurrency())
                         THEN 1
		        ELSE
		        (CASE WHEN in_account_class =1
		              THEN ex.buy
		              ELSE ex.sell END)
		        END) as amount_fx, 
		       (CASE WHEN c.discount_terms < extract('days' FROM age(a.transdate))
		        THEN 0
		        ELSE (coalesce(ac.due, a.amount)) * coalesce(c.discount, 0) / 100
		        END) AS discount,
		        (CASE WHEN c.discount_terms < extract('days' FROM age(a.transdate))
		        THEN 0
		        ELSE (coalesce(ac.due, a.amount)) * coalesce(c.discount, 0) / 100
		        END)/
		        (CASE WHEN a.curr = (SELECT * from defaults_get_defaultcurrency())
                         THEN 1
		        ELSE
		        (CASE WHEN in_account_class =1
		              THEN ex.buy
		              ELSE ex.sell END)
		        END) as discount_fx,		        
		        ac.due - (CASE WHEN c.discount_terms < extract('days' FROM age(a.transdate))
		        THEN 0
		        ELSE (coalesce(ac.due, a.amount)) * coalesce(c.discount, 0) / 100
		        END) AS due,
		        (ac.due - (CASE WHEN c.discount_terms < extract('days' FROM age(a.transdate))
		        THEN 0 
		        ELSE (coalesce(ac.due, a.amount)) * coalesce(c.discount, 0) / 100
		        END))/
		        (CASE WHEN a.curr = (SELECT * from defaults_get_defaultcurrency())
                         THEN 1
		         ELSE
		         (CASE WHEN in_account_class =1
		              THEN ex.buy
		              ELSE ex.sell END)
		         END) AS due_fx,
		        (CASE WHEN a.curr = (SELECT * from defaults_get_defaultcurrency())
		         THEN 1
		         ELSE
		        (CASE WHEN in_account_class =1
		         THEN ex.buy
		         ELSE ex.sell END)
		         END) AS exchangerate
                FROM  (SELECT id, invnumber, transdate, amount, entity_id,
		               1 as invoice_class, paid, curr, 
		               entity_credit_account, department_id
		          FROM ap
                         UNION
		         SELECT id, invnumber, transdate, amount, entity_id,
		               2 AS invoice_class, paid, curr,
		               entity_credit_account, department_id

		         FROM ar
		         ) a 
		JOIN (SELECT trans_id, chart_id, sum(CASE WHEN in_account_class = 1 THEN amount
		                                  WHEN in_account_class = 2 
		                             THEN amount * -1
		                             END) as due
		        FROM acc_trans 
		        GROUP BY trans_id, chart_id) ac ON (ac.trans_id = a.id)
		        JOIN chart ON (chart.id = ac.chart_id)
		        LEFT JOIN exchangerate ex ON ( ex.transdate = a.transdate AND ex.curr = a.curr )         
		        JOIN entity_credit_account c ON (c.id = a.entity_credit_account
                        OR (a.entity_credit_account IS NULL and a.entity_id = c.entity_id))
	 	        WHERE ((chart.link = 'AP' AND in_account_class = 1)
		              OR (chart.link = 'AR' AND in_account_class = 2))
              	        AND a.invoice_class = in_account_class
		        AND c.entity_class = in_account_class
		        AND c.id = in_entity_credit_id
		        AND a.amount - a.paid <> 0
		        AND a.curr = in_curr
		        AND (a.transdate >= in_datefrom 
		             OR in_datefrom IS NULL)
		        AND (a.transdate <= in_dateto
		             OR in_dateto IS NULL)
		        AND (a.amount >= in_amountfrom 
		             OR in_amountfrom IS NULL)
		        AND (a.amount <= in_amountto
		             OR in_amountto IS NULL)
		        AND (a.department_id = in_department_id
		             OR in_department_id IS NULL)
		        AND due <> 0          
		        GROUP BY a.invnumber, a.transdate, a.amount, amount_fx, discount, discount_fx, ac.due, a.id, c.discount_terms, ex.buy, ex.sell, a.curr
	LOOP
		RETURN NEXT payment_inv;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;



COMMENT ON FUNCTION payment_get_open_invoices(int, int, char(3), date, date, numeric, numeric, int) IS
$$ This function takes three arguments:
Type: 1 for vendor, 2 for customer
Entity_id:  The entity_id of the customer or vendor
Currency:  3 characters for currency ('USD' for example).
Returns all open invoices for the entity in question. $$;

CREATE TYPE payment_contact_invoice AS (
	contact_id int,
	econtrol_code text,
	eca_description text,
	contact_name text,
	account_number text,
	total_due numeric,
	invoices text[],
        has_vouchers int
);

CREATE OR REPLACE FUNCTION payment_get_all_contact_invoices
(in_account_class int, in_business_id int, in_currency char(3),
	in_date_from date, in_date_to date, in_batch_id int, 
	in_ar_ap_accno text, in_meta_number text)
RETURNS SETOF payment_contact_invoice AS
$$
DECLARE payment_item payment_contact_invoice;
BEGIN
	FOR payment_item IN
		  SELECT c.id AS contact_id, e.control_code as econtrol_code, 
			c.description as eca_description, 
			e.name AS contact_name,
		         c.meta_number AS account_number,
			 sum( case when u.username IS NULL or 
				       u.username = SESSION_USER 
			     THEN 
		              coalesce(p.due::numeric, 0) -
		              CASE WHEN c.discount_terms 
		                        > extract('days' FROM age(a.transdate))
		                   THEN 0
		                   ELSE (coalesce(p.due::numeric, 0)) * 
					coalesce(c.discount::numeric, 0) / 100
		              END
			     ELSE 0::numeric
			     END) AS total_due,
		         compound_array(ARRAY[[
		              a.id::text, a.invnumber, a.transdate::text, 
		              a.amount::text, (a.amount - p.due)::text,
		              (CASE WHEN c.discount_terms 
		                        > extract('days' FROM age(a.transdate))
		                   THEN 0
		                   ELSE (a.amount - coalesce((a.amount - p.due), 0)) * coalesce(c.discount, 0) / 100
		              END)::text, 
		              (coalesce(p.due, 0) -
		              (CASE WHEN c.discount_terms 
		                        > extract('days' FROM age(a.transdate))
		                   THEN 0
		                   ELSE (coalesce(p.due, 0)) * coalesce(c.discount, 0) / 100
		              END))::text,
			 	case when u.username IS NOT NULL 
				          and u.username <> SESSION_USER 
				     THEN 0::text
				     ELSE 1::text
				END,
				COALESCE(u.username, 0::text)
				]]),
                              sum(case when a.batch_id = in_batch_id then 1
		                  else 0 END),
		              bool_and(lock_record(a.id, (select max(session_id) 				FROM "session" where users_id = (
					select id from users WHERE username =
					SESSION_USER))))
                           
		    FROM entity e
		    JOIN entity_credit_account c ON (e.id = c.entity_id)
		    JOIN (SELECT ap.id, invnumber, transdate, amount, entity_id, 
				 paid, curr, 1 as invoice_class, 
		                 entity_credit_account, on_hold, v.batch_id,
				 approved
		            FROM ap
		       LEFT JOIN (select * from voucher where batch_class = 1) v 
			         ON (ap.id = v.trans_id)
			   WHERE in_account_class = 1
			         AND (v.batch_class = 1 or v.batch_id IS NULL)
		           UNION
		          SELECT ar.id, invnumber, transdate, amount, entity_id,
		                 paid, curr, 2 as invoice_class, 
		                 entity_credit_account, on_hold, v.batch_id,
				 approved
		            FROM ar
		       LEFT JOIN (select * from voucher where batch_class = 2) v 
			         ON (ar.id = v.trans_id)
			   WHERE in_account_class = 2
			         AND (v.batch_class = 2 or v.batch_id IS NULL)
			ORDER BY transdate
		         ) a ON (a.entity_credit_account = c.id)
		    JOIN transactions t ON (a.id = t.id)
		    JOIN (SELECT trans_id, 
		                 sum(CASE WHEN in_account_class = 1 THEN amount
		                          WHEN in_account_class = 2 
		                          THEN amount * -1
		                     END) AS due 
		            FROM acc_trans 
		            JOIN chart ON (chart.id = acc_trans.chart_id)
		           WHERE ((chart.link = 'AP' AND in_account_class = 1)
		                 OR (chart.link = 'AR' AND in_account_class = 2))
		        GROUP BY trans_id) p ON (a.id = p.trans_id)
		LEFT JOIN "session" s ON (s."session_id" = t.locked_by)
		LEFT JOIN users u ON (u.id = s.users_id)
		   WHERE (a.batch_id = in_batch_id
		          OR (a.invoice_class = in_account_class
		             AND a.approved
			 AND (c.business_id = 
				coalesce(in_business_id, c.business_id)
				OR in_business_id is null)
		         AND ((a.transdate >= COALESCE(in_date_from, a.transdate)
		               AND a.transdate <= COALESCE(in_date_to, a.transdate)))
		         AND c.entity_class = in_account_class
		         AND a.curr = in_currency
		         AND a.entity_credit_account = c.id
			 AND p.due <> 0
		         AND a.amount <> a.paid 
			 AND NOT a.on_hold
		         AND EXISTS (select trans_id FROM acc_trans
		                      WHERE trans_id = a.id AND
		                            chart_id = (SELECT id frOM chart
		                                         WHERE accno
		                                               = in_ar_ap_accno)
		                    )))
		         AND (in_meta_number IS NULL OR 
                             in_meta_number = c.meta_number)
		GROUP BY c.id, e.name, c.meta_number, c.threshold, 
			e.control_code, c.description
		  HAVING  (sum(p.due) >= c.threshold
			OR sum(case when a.batch_id = in_batch_id then 1
                                  else 0 END) > 0)
        ORDER BY c.meta_number ASC
	LOOP
		RETURN NEXT payment_item;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION payment_get_all_contact_invoices
(in_account_class int, in_business_id int, in_currency char(3),
	in_date_from date, in_date_to date, in_batch_id int, 
	in_ar_ap_accno text, in_meta_number text) IS
$$
This function takes the following arguments (all prefaced with in_ in the db):
account_class: 1 for vendor, 2 for customer
business_type: integer of business.id.
currency: char(3) of currency (for example 'USD')
date_from, date_to:  These dates are inclusive.
1;3B
batch_id:  For payment batches, where fees are concerned.
ar_ap_accno:  The AR/AP account number.

This then returns a set of contact information with a 2 dimensional array 
cnsisting of outstanding invoices.
$$;

CREATE OR REPLACE FUNCTION payment_bulk_queue
(in_transactions numeric[], in_batch_id int, in_source text, in_total numeric,
	in_ar_ap_accno text, in_cash_accno text, 
	in_payment_date date, in_account_class int)
returns int as
$$
BEGIN
	INSERT INTO payments_queue
	(transactions, batch_id, source, total, ar_ap_accno, cash_accno,
		payment_date, account_class)
	VALUES 
	(in_transactions, in_batch_id, in_source, in_total, in_ar_ap_accno,
		in_cash_accno, in_payment_date, in_account_class);

	RETURN array_upper(in_transactions, 1) - 
		array_lower(in_transactions, 1);
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION job__process_payment(in_job_id int)
RETURNS bool AS $$
DECLARE 
	queue_record RECORD;
	t_auth_name text;
	t_counter int;
BEGIN
	-- TODO:  Move the set session authorization into a utility function
	SELECT entered_by INTO t_auth_name FROM pending_job
	WHERE id = in_job_id;

	EXECUTE 'SET SESSION AUTHORIZATION ' || quote_ident(t_auth_name);

	t_counter := 0;
	
	FOR queue_record IN 
		SELECT * 
		FROM payments_queue WHERE job_id = in_job_id
	LOOP
		PERFORM payment_bulk_post
			(queue_record.transactions, queue_record.batch_id, 
				queue_record.source, queue_record.total, 
				queue_record.ar_ap_accno, 
				queue_record.cash_accno, 
				queue_record.payment_date, 
				queue_record.account_class);

		t_counter := t_counter + 1;
		RAISE NOTICE 'Processed record %, starting transaction %', 
			t_counter, queue_record.transactions[1][1];
	END LOOP;	
	DELETE FROM payments_queue WHERE job_id = in_job_id;

	UPDATE pending_job
	SET completed_at = timeofday()::timestamp,
	    success = true
	WHERE id = in_job_id;
	RETURN TRUE;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION job__create(in_batch_class int, in_batch_id int)
RETURNS int AS
$$
BEGIN
	INSERT INTO pending_job (batch_class, batch_id)
	VALUES (coalesce(in_batch_class, 3), in_batch_id);

	RETURN currval('pending_job_id_seq');
END;
$$ LANGUAGE PLPGSQL;

CREATE TYPE job__status AS (
	completed int, -- 1 for completed, 0 for no
	success int, -- 1 for success, 0 for no
	completed_at timestamp,
	error_condition text -- error if not successful
);

CREATE OR REPLACE FUNCTION job__status(in_job_id int) RETURNS job__status AS
$$
DECLARE out_row job__status;
BEGIN
	SELECT  (completed_at IS NULL)::INT, success::int, completed_at,
		error_condition
	INTO out_row 
	FROM pending_job
	WHERE id = in_job_id;

	RETURN out_row;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION payment_bulk_post
(in_transactions numeric[], in_batch_id int, in_source text, in_total numeric,
	in_ar_ap_accno text, in_cash_accno text, 
	in_payment_date date, in_account_class int, in_payment_type int)
RETURNS int AS
$$
DECLARE 
	out_count int;
	t_voucher_id int;
	t_trans_id int;
	t_amount numeric;
        t_ar_ap_id int;
	t_cash_id int;
BEGIN
	IF in_batch_id IS NULL THEN
		-- t_voucher_id := NULL;
		RAISE EXCEPTION 'Bulk Post Must be from Batch!';
	ELSE
		INSERT INTO voucher (batch_id, batch_class, trans_id)
		values (in_batch_id, 3, in_transactions[1][1]);

		t_voucher_id := currval('voucher_id_seq');
	END IF;

	CREATE TEMPORARY TABLE bulk_payments_in (id int, amount numeric);

	select id into t_ar_ap_id from chart where accno = in_ar_ap_accno;
	select id into t_cash_id from chart where accno = in_cash_accno;

	FOR out_count IN 
			array_lower(in_transactions, 1) ..
			array_upper(in_transactions, 1)
	LOOP
		EXECUTE $E$
			INSERT INTO bulk_payments_in(id, amount)
			VALUES ($E$ || quote_literal(in_transactions[out_count][1])
				|| $E$, $E$ ||
				quote_literal(in_transactions[out_count][2])
				|| $E$)$E$;
	END LOOP;
	EXECUTE $E$ 
		INSERT INTO acc_trans 
			(trans_id, chart_id, amount, approved, voucher_id, transdate, 
			source, payment_type)
		SELECT id, 
		case when $E$ || quote_literal(in_account_class) || $E$ = 1
			THEN $E$ || t_cash_id || $E$
			WHEN $E$ || quote_literal(in_account_class) || $E$ = 2 
			THEN $E$ || t_ar_ap_id || $E$
			ELSE -1 END, 
		amount,
		CASE 
			WHEN $E$|| t_voucher_id || $E$ IS NULL THEN true
			ELSE false END,
		$E$ || t_voucher_id || $E$, $E$|| quote_literal(in_payment_date) 
		||$E$ , $E$ ||COALESCE(quote_literal(in_source), 'NULL') || , 
		$E$ || quote_literal(in_payment_class) || $E$
		FROM bulk_payments_in $E$;

	EXECUTE $E$ 
		INSERT INTO acc_trans 
			(trans_id, chart_id, amount, approved, voucher_id, transdate, 
			source, payment_type)
		SELECT id, 
		case when $E$ || quote_literal(in_account_class) || $E$ = 1 
			THEN $E$ || t_ar_ap_id || $E$
			WHEN $E$ || quote_literal(in_account_class) || $E$ = 2 
			THEN $E$ || t_cash_id || $E$
			ELSE -1 END, 
		amount * -1,
		CASE 
			WHEN $E$|| t_voucher_id || $E$ IS NULL THEN true
			ELSE false END,
		$E$ || t_voucher_id || $E$, $E$|| quote_literal(in_payment_date) 
		||$E$ , $E$ ||COALESCE(quote_literal(in_source), 'null') 
		||$E$ , $E$ || quote_literal(in_payment_class) || $E$ 
		FROM bulk_payments_in $E$;

	EXECUTE $E$
		UPDATE ap 
		set paid = paid + (select amount from bulk_payments_in b 
			where b.id = ap.id)
		where id in (select id from bulk_payments_in) $E$;
	EXECUTE $E$ DROP TABLE bulk_payments_in $E$;
	perform unlock_all();
	return out_count;
END;
$$ language plpgsql;

COMMENT ON FUNCTION payment_bulk_post
(in_transactions numeric[], in_batch_id int, in_source text, in_total numeric,
        in_ar_ap_accno text, in_cash_accno text, 
        in_payment_date date, in_account_class int)
IS
$$ Note that in_transactions is a two-dimensional numeric array.  Of each 
sub-array, the first element is the (integer) transaction id, and the second
is the amount for that transaction.  $$;

--
-- WE NEED A PAYMENT TABLE 
--

CREATE TABLE payment (
  id serial primary key,
  reference text NOT NULL,
  gl_id     integer references gl(id),
  payment_class integer NOT NULL,
  payment_date date default current_date,
  closed bool default FALSE,
  entity_credit_id   integer references entity_credit_account(id),
  employee_id integer references entity_employee(entity_id),
  currency char(3),
  notes text,
  department_id integer default 0);
              
COMMENT ON TABLE payment IS $$ This table will store the main data on a payment, prepayment, overpayment, et$$;
COMMENT ON COLUMN payment.reference IS $$ This field will store the code for both receipts and payment order  $$; 
COMMENT ON COLUMN payment.closed IS $$ This will store the current state of a payment/receipt order $$;
COMMENT ON COLUMN payment.gl_id IS $$ A payment should always be linked to a GL movement $$;
CREATE  INDEX payment_id_idx ON payment(id);
                  
CREATE TABLE payment_links (
  payment_id integer references Payment(id),
  entry_id   integer references acc_trans(entry_id),
  type       integer);
COMMENT ON TABLE payment_links IS $$  
 An explanation to the type field.
 * A type 0 means the link is referencing an ar/ap  and was created
   using an overpayment movement after the receipt was created 
 * A type 1 means the link is referencing an ar/ap and  was made 
   on the payment creation, its not the product of an overpayment movement 
 * A type 2 means the link is not referencing an ar/ap and its the product
   of the overpayment logic 

 With this ideas in order we can do the following

 To get the payment amount we will sum the entries with type > 0.
 To get the linked amount we will sum the entries with type < 2.
 The overpayment account can be obtained from the entries with type = 2.

 This reasoning is hacky and i hope it can dissapear when we get to 1.4 - D.M.
$$;
 
CREATE OR REPLACE FUNCTION payment_post 
(in_datepaid      		  date,
 in_account_class 		  int,
 in_entity_credit_id                     int,
 in_curr        		  char(3),
 in_notes                         text,
 in_department_id                 int,
 in_gl_description                text,
 in_cash_account_id               int[],
 in_amount                        numeric[],
 in_cash_approved                 bool[],
 in_source                        text[],
 in_memo                          text[], 
 in_transaction_id                int[],
 in_op_amount                     numeric[],
 in_op_cash_account_id            int[],
 in_op_source                     text[], 
 in_op_memo                       text[],
 in_op_account_id                 int[],                   
 in_approved                      bool)
RETURNS INT AS
$$
DECLARE var_payment_id int;
DECLARE var_gl_id int;
DECLARE var_entry record;
DECLARE var_entry_id int[];
DECLARE out_count int;
DECLARE coa_id record;
DECLARE var_employee int;
DECLARE var_account_id int;
DECLARE default_currency char(3);
DECLARE current_exchangerate numeric;
DECLARE old_exchangerate numeric;
DECLARE tmp_amount numeric;
BEGIN
        
        SELECT * INTO default_currency  FROM defaults_get_defaultcurrency(); 
        SELECT * INTO current_exchangerate FROM currency_get_exchangerate(in_curr, in_datepaid, in_account_class);


        SELECT INTO var_employee entity_id FROM users WHERE username = SESSION_USER LIMIT 1;
        -- 
        -- WE HAVE TO INSERT THE PAYMENT, USING THE GL INFORMATION
        -- THE ID IS GENERATED BY payment_id_seq
        --
   	INSERT INTO payment (reference, payment_class, payment_date,
	                      employee_id, currency, notes, department_id, entity_credit_id) 
	VALUES ((CASE WHEN in_account_class = 1 THEN
	                                setting_increment('rcptnumber') -- I FOUND THIS ON sql/modules/Settings.sql 
			             ELSE 						-- and it is very usefull				
			                setting_increment('paynumber') 
			             END),
	         in_account_class, in_datepaid, var_employee,
                 in_curr, in_notes, in_department_id, in_entity_credit_id);
        SELECT currval('payment_id_seq') INTO var_payment_id; -- WE'LL NEED THIS VALUE TO USE payment_link table
        -- WE'LL NEED THIS VALUE TO JOIN WITH PAYMENT
        -- NOW COMES THE HEAVY PART, STORING ALL THE POSSIBLE TRANSACTIONS... 
        --
        -- FIRST WE SHOULD INSERT THE CASH ACCOUNTS
        --
        -- WE SHOULD HAVE THE DATA STORED AS (ACCNO, AMOUNT), SO
	FOR out_count IN 
			array_lower(in_cash_account_id, 1) ..
			array_upper(in_cash_account_id, 1)
	LOOP
	        INSERT INTO acc_trans (chart_id, amount,
		                       trans_id, transdate, approved, source, memo)
		VALUES (in_cash_account_id[out_count], 
		        CASE WHEN in_account_class = 1 THEN in_amount[out_count]*current_exchangerate  
		        ELSE (in_amount[out_count]*current_exchangerate)* - 1
		        END,
		        in_transaction_id[out_count], in_datepaid, coalesce(in_approved, true), 
		        in_source[out_count], in_memo[out_count]);
                INSERT INTO payment_links 
		VALUES (var_payment_id, currval('acc_trans_entry_id_seq'), 1);
		
	END LOOP;
	-- NOW LETS HANDLE THE AR/AP ACCOUNTS
	-- WE RECEIVED THE TRANSACTIONS_ID AND WE CAN OBTAIN THE ACCOUNT FROM THERE
	FOR out_count IN
		     array_lower(in_transaction_id, 1) ..
		     array_upper(in_transaction_id, 1)
       LOOP
               SELECT INTO var_account_id chart_id FROM acc_trans as ac
	        JOIN chart as c ON (c.id = ac.chart_id) 
       	        WHERE 
       	        trans_id = in_transaction_id[out_count] AND
       	        ( c.link = 'AP' OR c.link = 'AR' );
        -- We need to know the exchangerate of this transaction
        IF (current_exchangerate = 1 ) THEN 
           old_exchangerate := 1;
        ELSIF (in_account_class = 1) THEN
           SELECT buy INTO old_exchangerate 
           FROM exchangerate e
           JOIN ap a on (a.transdate = e.transdate )
           WHERE a.id = in_transaction_id[out_count];
        ELSE 
           SELECT sell INTO old_exchangerate 
           FROM exchangerate e
           JOIN ar a on (a.transdate = e.transdate )
           WHERE a.id = in_transaction_id[out_count];
        END IF;
        -- Now we post the AP/AR transaction
        INSERT INTO acc_trans (chart_id, amount,
                                trans_id, transdate, approved, source, memo)
		VALUES (var_account_id, 
		        CASE WHEN in_account_class = 1 THEN 
		        
		        (in_amount[out_count]*old_exchangerate) * -1 
		        ELSE in_amount[out_count]*old_exchangerate
		        END,
		        in_transaction_id[out_count], in_datepaid,  coalesce(in_approved, true), 
		        in_source[out_count], in_memo[out_count]);
        -- Lets set the gain/loss, if tmp_amount equals zero then we dont need to post
        -- any transaction
        tmp_amount := in_amount[out_count]*current_exchangerate - in_amount[out_count]*old_exchangerate;
       IF (tmp_amount < 0) THEN
          IF (in_account_class  = 1) THEN
           INSERT INTO acc_trans (chart_id, amount, trans_id, transdate, approved, source)
            VALUES (CAST((select value from defaults where setting_key like 'fxloss_accno_id') AS INT),
                    tmp_amount, in_transaction_id[out_count], in_datepaid, coalesce(in_approved, true),
                    in_source[out_count]);
           ELSE
            INSERT INTO acc_trans (chart_id, amount, trans_id, transdate, approved, source)
            VALUES (CAST((select value from defaults where setting_key like 'fxgain_accno_id') AS INT),
                    tmp_amount, in_transaction_id[out_count], in_datepaid, coalesce(in_approved, true),
                    in_source[out_count]);
          END IF;
        ELSIF (tmp_amount > 0) THEN
          IF (in_account_class  = 1) THEN
            INSERT INTO acc_trans (chart_id, amount, trans_id, transdate, approved, source)
            VALUES (CAST((select value from defaults where setting_key like 'fxgain_accno_id') AS INT),
                    tmp_amount, in_transaction_id[out_count], in_datepaid, coalesce(in_approved, true),
                    in_source[out_count]);
           ELSE
            INSERT INTO acc_trans (chart_id, amount, trans_id, transdate, approved, source)
            VALUES (CAST((select value from defaults where setting_key like 'fxloss_accno_id') AS INT),
                    tmp_amount, in_transaction_id[out_count], in_datepaid, coalesce(in_approved, true),
                    in_source[out_count]);
          END IF; 
        END IF; 
        -- Now we set the links
         INSERT INTO payment_links 
		VALUES (var_payment_id, currval('acc_trans_entry_id_seq'), 1);
      END LOOP;
--
-- WE NEED TO HANDLE THE OVERPAYMENTS NOW
--
       --
       -- FIRST WE HAVE TO MAKE THE GL TO HOLD THE OVERPAYMENT TRANSACTIONS
       -- THE ID IS GENERATED BY gl_id_seq
       --
       
  IF (array_upper(in_op_cash_account_id, 1) > 0) THEN
       INSERT INTO gl (reference, description, transdate,
                       person_id, notes, approved, department_id) 
              VALUES (setting_increment('glnumber'),
	              in_gl_description, in_datepaid, var_employee,
	              in_notes, in_approved, in_department_id);
       SELECT currval('id') INTO var_gl_id;   
--
-- WE NEED TO SET THE GL_ID FIELD ON PAYMENT'S TABLE
--
       UPDATE payment SET gl_id = var_gl_id 
       WHERE id = var_payment_id;
       -- NOW COMES THE HEAVY PART, STORING ALL THE POSSIBLE TRANSACTIONS... 
       --
       -- FIRST WE SHOULD INSERT THE OVERPAYMENT CASH ACCOUNTS
       --
	FOR out_count IN 
			array_lower(in_op_cash_account_id, 1) ..
			array_upper(in_op_cash_account_id, 1)
	LOOP
	        INSERT INTO acc_trans (chart_id, amount,
		                       trans_id, transdate, approved, source, memo)
		VALUES (in_op_cash_account_id[out_count], 
		        CASE WHEN in_account_class = 2 THEN in_op_amount[out_count]  
		        ELSE in_op_amount[out_count] * - 1
		        END,
		        var_gl_id, in_datepaid, coalesce(in_approved, true), 
		        in_op_source[out_count], in_op_memo[out_count]);
	        INSERT INTO payment_links 
		VALUES (var_payment_id, currval('acc_trans_entry_id_seq'), 2);
	END LOOP;
	-- NOW LETS HANDLE THE OVERPAYMENT ACCOUNTS
	FOR out_count IN
		     array_lower(in_op_account_id, 1) ..
		     array_upper(in_op_account_id, 1)
	LOOP
         INSERT INTO acc_trans (chart_id, amount,
                                trans_id, transdate, approved, source, memo)
		VALUES (in_op_account_id[out_count], 
		        CASE WHEN in_account_class = 2 THEN in_op_amount[out_count] * -1 
		        ELSE in_op_amount[out_count]
		        END,
		        var_gl_id, in_datepaid,  coalesce(in_approved, true), 
		        in_op_source[out_count], in_op_memo[out_count]);
		INSERT INTO payment_links 
		VALUES (var_payment_id, currval('acc_trans_entry_id_seq'), 2);
	END LOOP;	        
 END IF;  
 return var_payment_id;
END;
$$ LANGUAGE PLPGSQL;
-- I HAVE TO MAKE A COMMENT ON THIS FUNCTION

-- Move this to the projects module when we start on that. CT
CREATE OR REPLACE FUNCTION project_list_open(in_date date) 
RETURNS SETOF project AS
$$
DECLARE out_project project%ROWTYPE;
BEGIN
	FOR out_project IN
		SELECT * from project
		WHERE startdate <= in_date AND enddate >= in_date
		      AND completed = 0
	LOOP
		return next out_project;
	END LOOP;
END;
$$ language plpgsql;

comment on function project_list_open(in_date date) is
$$ This function returns all projects that were open as on the date provided as
the argument.$$;
-- Move this to the projects module when we start on that. CT


CREATE OR REPLACE FUNCTION department_list(in_role char)
RETURNS SETOF department AS
$$
DECLARE out_department department%ROWTYPE;
BEGIN
       FOR out_department IN
               SELECT * from department
               WHERE role = coalesce(in_role, role)
       LOOP
               return next out_department;
       END LOOP;
END;
$$ language plpgsql;
-- Move this into another module.

comment on function department_list(in_role char) is
$$ This function returns all department that match the role provided as
the argument.$$;

CREATE OR REPLACE FUNCTION payments_get_open_currencies(in_account_class int)
RETURNS SETOF char(3) AS
$$
DECLARE resultrow record;
BEGIN
        FOR resultrow IN
          SELECT DISTINCT curr FROM ar
          UNION
          SELECT DISTINCT curr FROM ap 
          ORDER BY curr
          LOOP
         return next resultrow.curr;
        END LOOP;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION currency_get_exchangerate(in_currency char(3), in_date date, in_account_class int) 
RETURNS NUMERIC AS
$$
DECLARE 
    out_exrate exchangerate.buy%TYPE;
    default_currency char(3);
    
    BEGIN 
        SELECT * INTO default_currency  FROM defaults_get_defaultcurrency();
        IF default_currency = in_currency THEN
           RETURN 1;
        END IF; 
        IF in_account_class = 1 THEN
          SELECT buy INTO out_exrate 
          FROM exchangerate
          WHERE transdate = in_date AND curr = in_currency;
        ELSE 
          SELECT sell INTO out_exrate 
          FROM exchangerate
          WHERE transdate = in_date AND curr = in_currency;   
        END IF;
        RETURN out_exrate;
    END;
$$ language plpgsql;                                                                  
COMMENT ON FUNCTION currency_get_exchangerate(in_currency char(3), in_date date, in_account_class int) IS
$$ This function return the exchange rate of a given currency, date and exchange rate class (buy or sell). $$;

--
--  payment_location_result has the same arch as location_result, except for one field 
--  This should be unified on the API when we get things working - David Mora
--
CREATE TYPE payment_location_result AS (
        id int,
        line_one text,
        line_two text,
        line_three text,
        city text,
        state text,
	mail_code text,
        country text,
        class text
);

--
--  payment_get_vc_info has the same arch as company__list_locations, except for the filtering capabilities 
--  This should be unified on the API when we get things working - David Mora
--
CREATE OR REPLACE FUNCTION payment_get_vc_info(in_entity_credit_id int, in_location_class_id int)
RETURNS SETOF payment_location_result AS
$$
DECLARE out_row payment_location_result;
	BEGIN
		FOR out_row IN
                SELECT l.id, l.line_one, l.line_two, l.line_three, l.city,
                       l.state, l.mail_code, c.name, lc.class
                FROM location l
                JOIN company_to_location ctl ON (ctl.location_id = l.id)
                JOIN company cp ON (ctl.company_id = cp.id)
                JOIN location_class lc ON (ctl.location_class = lc.id)
                JOIN country c ON (c.id = l.country_id)
                JOIN entity_credit_account ec ON (ec.entity_id = cp.entity_id)
                WHERE ec.id = in_entity_credit_id AND
                      lc.id = in_location_class_id
                ORDER BY lc.id, l.id, c.name
                LOOP
                	RETURN NEXT out_row;
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

COMMENT ON FUNCTION payment_get_vc_info(in_entity_id int, in_location_class_id int) IS
$$ This function returns vendor or customer info $$;

CREATE TYPE payment_record AS (
	amount numeric,
	meta_number text,
        credit_id int,
	company_paid text,
	accounts text[],
        source text,
	batch_control text,
	batch_description text,
        date_paid date
);

CREATE OR REPLACE FUNCTION payment__search 
(in_source text, in_date_from date, in_date_to date, in_credit_id int, 
	in_cash_accno text, in_account_class int)
RETURNS SETOF payment_record AS
$$
DECLARE 
	out_row payment_record;
BEGIN
	FOR out_row IN 
		select sum(CASE WHEN c.entity_class = 1 then a.amount
				ELSE a.amount * -1 END), c.meta_number, 
			c.id, co.legal_name,
			compound_array(ARRAY[ARRAY[ch.id::text, ch.accno, 
				ch.description]]), a.source, 
			b.control_code, b.description, a.transdate
		FROM entity_credit_account c
		JOIN ( select entity_credit_account, id
			FROM ar WHERE in_account_class = 2
			UNION
			SELECT entity_credit_account, id
			FROM ap WHERE in_account_class = 1
			) arap ON (arap.entity_credit_account = c.id)
		JOIN acc_trans a ON (arap.id = a.trans_id)
		JOIN chart ch ON (ch.id = a.chart_id)
		JOIN company co ON (c.entity_id = co.entity_id)
		LEFT JOIN voucher v ON (v.id = a.voucher_id)
		LEFT JOIN batch b ON (b.id = v.batch_id)
		WHERE (ch.accno = in_cash_accno)
			AND (c.id = in_credit_id OR in_credit_id IS NULL)
			AND (a.transdate >= in_date_from 
				OR in_date_from IS NULL)
			AND (a.transdate <= in_date_to OR in_date_to IS NULL)
			AND (source = in_source OR in_source IS NULL)
		GROUP BY c.meta_number, c.id, co.legal_name, a.transdate, 
			a.source, a.memo, b.id, b.control_code, b.description
		ORDER BY a.transdate, c.meta_number, a.source
	LOOP
		RETURN NEXT out_row;
	END LOOP;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION payment__reverse
(in_source text, in_date_paid date, in_credit_id int, in_cash_accno text, 
	in_date_reversed date, in_account_class int, in_batch_id int)
RETURNS INT 
AS $$
DECLARE
	pay_row record;
        t_voucher_id int;
        t_voucher_inserted bool;
BEGIN
        IF in_batch_id IS NOT NULL THEN
		t_voucher_id := nextval('voucher_id_seq');
		t_voucher_inserted := FALSE;
	END IF;
	FOR pay_row IN 
		SELECT a.*, c.ar_ap_account_id
		FROM acc_trans a
		JOIN (select id, entity_credit_account 
			FROM ar WHERE in_account_class = 2
			UNION
			SELECT id, entity_credit_account
			FROM ap WHERE in_account_class = 1
		) arap ON (a.trans_id = arap.id)
		JOIN entity_credit_account c 
			ON (arap.entity_credit_account = c.id)
		JOIN chart ch ON (a.chart_id = ch.id)
		WHERE coalesce(source, '') = coalesce(in_source, '')
			AND transdate = in_date_paid
			AND in_credit_id = c.id
			AND in_cash_accno = ch.accno
	LOOP
		IF in_batch_id IS NOT NULL 
			AND t_voucher_inserted IS NOT TRUE
		THEN
			INSERT INTO voucher 
			(id, trans_id, batch_id, batch_class)
			VALUES
			(t_voucher_id, pay_row.trans_id, in_batch_id,
				CASE WHEN in_account_class = 1 THEN 4
				     WHEN in_account_class = 2 THEN 7
				END);

			t_voucher_inserted := TRUE;
		END IF;

		INSERT INTO acc_trans
		(trans_id, chart_id, amount, transdate, source, memo, approved,
			voucher_id) 
		VALUES 
		(pay_row.trans_id, pay_row.chart_id, pay_row.amount * -1, 
			in_date_reversed, in_source, 'Reversing ' || 
			COALESCE(in_source, ''), 
			case when in_batch_id is not null then false 
			else true end, t_voucher_id);
		INSERT INTO acc_trans
		(trans_id, chart_id, amount, transdate, source, memo, approved,
			voucher_id) 
		VALUES 
		(pay_row.trans_id, pay_row.ar_ap_account_id, pay_row.amount,
			in_date_reversed, in_source, 'Reversing ' ||
			COALESCE(in_source, ''), 
			case when in_batch_id is not null then false 
			else true end, t_voucher_id);
		IF in_account_class = 1 THEN
			UPDATE ap SET paid = amount - 
				(SELECT sum(a.amount) 
				FROM acc_trans a
				JOIN chart c ON (a.chart_id = c.id)
				WHERE c.link = 'AP'
					AND trans_id = pay_row.trans_id
				) 
			WHERE id = pay_row.trans_id;
		ELSIF in_account_class = 2 THEN
			update ar SET paid = amount - 
				(SELECT sum(a.amount) 
				FROM acc_trans a
				JOIN chart c ON (a.chart_id = c.id)
				WHERE c.link = 'AR'
					AND trans_id = pay_row.trans_id
				) * -1
			WHERE id = pay_row.trans_id;
		ELSE
			RAISE EXCEPTION 'Unknown account class for payments %',
				in_account_class;
		END IF;
	END LOOP;
	RETURN 1;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION payments_set_exchangerate(in_account_class int,
 in_exchangerate numeric, in_curr char(3), in_datepaid date )
RETURNS INT
AS $$
DECLARE current_exrate  exchangerate%ROWTYPE;
BEGIN
select  * INTO current_exrate
        FROM  exchangerate 
        WHERE transdate = in_date;
IF current_exrate.transdate = in_date THEN
   IF in_account_class = 1 THEN 
      UPDATE exchangerate set buy = in_exchangerate  where transdate = in_date;
   ELSE
      UPDATE exchangerate set sell = in_exchangerate where transdate = in_date;
   END IF;
   RETURN 0; 
ELSE
    IF in_account_class = 1 THEN
     INSERT INTO exchangerate (curr, transdate, buy) values (in_currency, in_date, in_exchangerate);
  ELSE   
     INSERT INTO exchangerate (curr, transdate, sell) values (in_currency, in_date, in_exchangerate);
  END IF;                                       
RETURN 0;
END IF;
END;
$$ language plpgsql;


CREATE TYPE payment_header_item AS (
payment_id int,
payment_reference int,
payment_date date,
legal_name text,
amount numeric,
employee_first_name text,
employee_last_name  text,
currency char(3),
notes text
);
-- I NEED TO PLACE THE COMPANY TELEPHONE AND ALL THAT STUFF
CREATE OR REPLACE FUNCTION payment_gather_header_info(in_account_class int, in_payment_id int)
 RETURNS SETOF payment_header_item AS
 $$
 DECLARE out_payment payment_header_item;
 BEGIN
 FOR out_payment IN 
   SELECT p.id as payment_id, p.reference as payment_reference, p.payment_date,  
          c.legal_name as legal_name, am.amount as amount, em.first_name, em.last_name, p.currency, p.notes
   FROM payment p
   JOIN employee em ON (em.entity_id = p.employee_id)
   JOIN company c ON   (c.entity_id  = p.entity_id)
   JOIN (  SELECT sum(a.amount) as amount
		FROM acc_trans a
		JOIN chart c ON (a.chart_id = c.id)
		JOIN payment_links pl ON (pl.entry_id=a.entry_id)
		WHERE 
		(   ((c.link like '%AP_paid%' OR c.link like '%AP_discount%') AND in_account_class = 1)
		 OR ((c.link like '%AR_paid%' OR c.link like '%AR_discount%') AND in_account_class = 2))
                 AND pl.payment_id = in_payment_id ) am ON (1=1)
   WHERE p.id = in_payment_id
 LOOP
     RETURN NEXT out_payment;
 END LOOP;

 END;
 $$ language plpgsql;
                            

COMMENT ON FUNCTION payment_gather_header_info(int,int) IS
$$ This function finds a payment based on the id and retrieves the record, 
it is usefull for printing payments :) $$;

CREATE TYPE payment_line_item AS (
  payment_id int,
  entry_id int,
  link_type int,
  trans_id int,
  invoice_number int,
  chart_id int,
  chart_accno int,
  chart_description text,
  chart_link text,
  amount int,
  trans_date date,	
  source text,
  cleared bool,
  fx_transaction bool,
  project_id int,
  memo text,
  invoice_id int,
  approved bool,
  cleared_on date,
  reconciled_on date
);
   
CREATE OR REPLACE FUNCTION payment_gather_line_info(in_account_class int, in_payment_id int)
 RETURNS SETOF payment_line_item AS
 $$
 DECLARE out_payment_line payment_line_item;
 BEGIN
   FOR out_payment_line IN 
     SELECT pl.payment_id, ac.entry_id, pl.type as link_type, ac.trans_id, a.invnumber as invoice_number,
     ac.chart_id, ch.accno as chart_accno, ch.description as chart_description, ch.link as chart_link,
     ac.amount,  ac.transdate as trans_date, ac.source, ac.cleared_on, ac.fx_transaction, ac.project_id,
     ac.memo, ac.invoice_id, ac.approved, ac.cleared_on, ac.reconciled_on
     FROM acc_trans ac
     JOIN payment_links pl ON (pl.entry_id = ac.entry_id )
     JOIN chart         ch ON (ch.id = ac.chart_id)
     LEFT JOIN (SELECT id,invnumber
                 FROM ar WHERE in_account_class = 2
                 UNION
                 SELECT id,invnumber
                 FROM ap WHERE in_account_class = 1
                ) a ON (ac.trans_id = a.id)
     WHERE pl.payment_id = in_payment_id
   LOOP
      RETURN NEXT out_payment_line;
   END LOOP;  
 END;
 $$ language plpgsql;

COMMENT ON FUNCTION payment_gather_line_info(int,int) IS
$$ This function finds a payment based on the id and retrieves all the line records, 
it is usefull for printing payments and build reports :) $$;
