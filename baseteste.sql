﻿-- Random String Function
CREATE OR REPLACE FUNCTION random_string(minlen NUMERIC, maxlen NUMERIC) 
RETURNS VARCHAR(1000) AS $$
DECLARE
	rv VARCHAR(1000) := '';
	i  INTEGER := 0;
	len INTEGER := 0;
BEGIN
	IF maxlen < 1 OR minlen < 1 OR maxlen < minlen THEN
		RETURN rv;
	END IF;
	len := floor(random()*(maxlen-minlen)) + minlen;
	FOR i IN 1..floor(len) LOOP
		rv := rv || chr(97+CAST(random() * 25 AS INTEGER));
	END LOOP;
	RETURN rv;
END;
$$ LANGUAGE plpgsql;

-- Create department table
CREATE OR REPLACE FUNCTION create_department(n INTEGER) RETURNS INTEGER AS $$
BEGIN
	DROP TABLE IF EXISTS department CASCADE;

	CREATE TABLE department AS
	SELECT 	generate_series::bigint AS id,
		initcap(lower(random_string(10, 15)))::varchar(20) as name,
		CURRENT_DATE - CAST(floor(random()*365*10+40*365) AS NUMERIC) * 
			INTERVAL '1 DAY' as creation,
		CAST(floor(random() * 100000000) AS NUMERIC) as phone
	FROM generate_series(1, n);

	ALTER TABLE department ADD PRIMARY KEY (id);

	RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Create employees table
CREATE OR REPLACE FUNCTION create_employees(n INTEGER, d INTEGER) RETURNS INTEGER AS $$
BEGIN
	DROP TABLE IF EXISTS employees;

	CREATE TABLE employees AS
	SELECT 	generate_series::bigint AS id,
		initcap(lower(random_string(5, 10)))::varchar(20) as first_name,
		initcap(lower(random_string(5, 10)))::varchar(20) as last_name, 
		CURRENT_DATE - CAST(floor(random()*365*10+40*365) AS NUMERIC) * 
			INTERVAL '1 DAY' as birth,
		CAST(floor(random() * 100000000) AS NUMERIC) as phone,
		mod((random() * 100000000)::int,d)+1::bigint as department_id
	FROM generate_series(1, n);
	
	ALTER TABLE employees ADD PRIMARY KEY (id);
	ALTER TABLE employees ADD FOREIGN KEY (department_id) 
		REFERENCES department (id);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;

select create_department(10);
select create_employees(10000,10);

SELECT count(*) FROM department;
SELECT count(*) FROM employees;

SELECT * FROM department limit 10;
SELECT * FROM employees limit 10;

SELECT avg(department_id)::int media_do_id FROM employees limit 10;
