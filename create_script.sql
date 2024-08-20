-- odeberu pokud existuje funkce na oodebrání tabulek a sekvencí
DROP FUNCTION IF EXISTS remove_all();

-- vytvořím funkci která odebere tabulky a sekvence
-- chcete také umět psát PLSQL? Zapište si předmět BI-SQL ;-)
CREATE or replace FUNCTION remove_all() RETURNS void AS $$
DECLARE
rec RECORD;
    cmd text;
BEGIN
    cmd := '';

FOR rec IN SELECT
               'DROP SEQUENCE ' || quote_ident(n.nspname) || '.'
                   || quote_ident(c.relname) || ' CASCADE;' AS name
           FROM
               pg_catalog.pg_class AS c
                   LEFT JOIN
               pg_catalog.pg_namespace AS n
               ON
                   n.oid = c.relnamespace
           WHERE
               relkind = 'S' AND
               n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
               pg_catalog.pg_table_is_visible(c.oid)
               LOOP
        cmd := cmd || rec.name;
END LOOP;

FOR rec IN SELECT
               'DROP TABLE ' || quote_ident(n.nspname) || '.'
                   || quote_ident(c.relname) || ' CASCADE;' AS name
           FROM
               pg_catalog.pg_class AS c
                   LEFT JOIN
               pg_catalog.pg_namespace AS n
               ON
                   n.oid = c.relnamespace WHERE relkind = 'r' AND
               n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
               pg_catalog.pg_table_is_visible(c.oid)
               LOOP
        cmd := cmd || rec.name;
END LOOP;

EXECUTE cmd;
RETURN;
END;
$$ LANGUAGE plpgsql;
-- zavolám funkci co odebere tabulky a sekvence - Mohl bych dropnout celé schéma a znovu jej vytvořit, použíjeme však PLSQL
select remove_all();



-- Remove conflicting tables
--DROP TABLE IF EXISTS address CASCADE;
--DROP TABLE IF EXISTS client CASCADE;
--DROP TABLE IF EXISTS contract CASCADE;
--DROP TABLE IF EXISTS country CASCADE;
--DROP TABLE IF EXISTS employee CASCADE;
--DROP TABLE IF EXISTS maintenance CASCADE;
--DROP TABLE IF EXISTS manager CASCADE;
--DROP TABLE IF EXISTS order_name CASCADE;
--DROP TABLE IF EXISTS solar_panels CASCADE;
--DROP TABLE IF EXISTS solar_panels_type CASCADE;
--DROP TABLE IF EXISTS solar_station_installation CASCADE;
--DROP TABLE IF EXISTS order_name_employee CASCADE;
-- End of removing

CREATE TABLE address (
                         id_address SERIAL NOT NULL,
                         id_country INTEGER NOT NULL,
                         street VARCHAR(256),
                         street_number INTEGER,
                         town VARCHAR(256) NOT NULL
);
ALTER TABLE address ADD CONSTRAINT pk_address PRIMARY KEY (id_address);

CREATE TABLE client (
                        id_client SERIAL NOT NULL,
                        id_address INTEGER NOT NULL,
                        name VARCHAR(60) NOT NULL,
                        phone_number VARCHAR(60) NOT NULL,
                        email VARCHAR(256),
                        additional_information VARCHAR(256)
);
ALTER TABLE client ADD CONSTRAINT pk_client PRIMARY KEY (id_client);

CREATE TABLE contract (
                          id_contract SERIAL NOT NULL,
                          id_employee INTEGER NOT NULL,
                          id_order_name INTEGER NOT NULL,
                          date_of_signing DATE NOT NULL,
                          description VARCHAR(256) NOT NULL
);
ALTER TABLE contract ADD CONSTRAINT pk_contract PRIMARY KEY (id_contract);
ALTER TABLE contract ADD CONSTRAINT u_fk_contract_order_name UNIQUE (id_order_name);

CREATE TABLE country (
                         id_country SERIAL NOT NULL,
                         name VARCHAR(256) NOT NULL
);
ALTER TABLE country ADD CONSTRAINT pk_country PRIMARY KEY (id_country);

CREATE TABLE employee (
                          id_employee SERIAL NOT NULL,
                          id_address INTEGER NOT NULL,
                          name VARCHAR(60) NOT NULL,
                          surname VARCHAR(60) NOT NULL,
                          salary INTEGER NOT NULL
);
ALTER TABLE employee ADD CONSTRAINT pk_employee PRIMARY KEY (id_employee);

CREATE TABLE maintenance (
                             id_maintenance SERIAL NOT NULL,
                             maintenance_type VARCHAR(256) NOT NULL,
                             description VARCHAR(256) NOT NULL
);
ALTER TABLE maintenance ADD CONSTRAINT pk_maintenance PRIMARY KEY (id_maintenance);

CREATE TABLE manager (
                         id_employee INTEGER NOT NULL,
                         number_of_cars INTEGER NOT NULL,
                         nickname VARCHAR(60)
);
ALTER TABLE manager ADD CONSTRAINT pk_manager PRIMARY KEY (id_employee);

CREATE TABLE order_name (
                            id_order_name SERIAL NOT NULL,
                            id_maintenance INTEGER,
                            id_address INTEGER NOT NULL,
                            id_client INTEGER NOT NULL,
                            id_solar_panels INTEGER NOT NULL,
                            id_solar_station_installation INTEGER,
                            date_of_realization DATE NOT NULL,
                            additional_information VARCHAR(256),
                            total_price INTEGER NOT NULL
);
ALTER TABLE order_name ADD CONSTRAINT pk_order_name PRIMARY KEY (id_order_name);

CREATE TABLE solar_panels (
                              id_solar_panels SERIAL NOT NULL,
                              id_solar_panels_type INTEGER NOT NULL,
                              supplier VARCHAR(60) NOT NULL
);
ALTER TABLE solar_panels ADD CONSTRAINT pk_solar_panels PRIMARY KEY (id_solar_panels);

CREATE TABLE solar_panels_type (
                                   id_solar_panels_type SERIAL NOT NULL,
                                   name VARCHAR(60) NOT NULL
);
ALTER TABLE solar_panels_type ADD CONSTRAINT pk_solar_panels_type PRIMARY KEY (id_solar_panels_type);

CREATE TABLE solar_station_installation (
                                            id_solar_station_installation SERIAL NOT NULL,
                                            total_voltage INTEGER NOT NULL,
                                            size VARCHAR(256) NOT NULL
);
ALTER TABLE solar_station_installation ADD CONSTRAINT pk_solar_station_installation PRIMARY KEY (id_solar_station_installation);

CREATE TABLE order_name_employee (
                                     id_order_name INTEGER NOT NULL,
                                     id_employee INTEGER NOT NULL
);
ALTER TABLE order_name_employee ADD CONSTRAINT pk_order_name_employee PRIMARY KEY (id_order_name, id_employee);

ALTER TABLE address ADD CONSTRAINT fk_address_country FOREIGN KEY (id_country) REFERENCES country (id_country) ON DELETE CASCADE;

ALTER TABLE client ADD CONSTRAINT fk_client_address FOREIGN KEY (id_address) REFERENCES address (id_address) ON DELETE CASCADE;

ALTER TABLE contract ADD CONSTRAINT fk_contract_manager FOREIGN KEY (id_employee) REFERENCES manager (id_employee) ON DELETE CASCADE;
ALTER TABLE contract ADD CONSTRAINT fk_contract_order_name FOREIGN KEY (id_order_name) REFERENCES order_name (id_order_name) ON DELETE CASCADE;

ALTER TABLE employee ADD CONSTRAINT fk_employee_address FOREIGN KEY (id_address) REFERENCES address (id_address) ON DELETE CASCADE;

ALTER TABLE manager ADD CONSTRAINT fk_manager_employee FOREIGN KEY (id_employee) REFERENCES employee (id_employee) ON DELETE CASCADE;

ALTER TABLE order_name ADD CONSTRAINT fk_order_name_maintenance FOREIGN KEY (id_maintenance) REFERENCES maintenance (id_maintenance) ON DELETE CASCADE;
ALTER TABLE order_name ADD CONSTRAINT fk_order_name_address FOREIGN KEY (id_address) REFERENCES address (id_address) ON DELETE CASCADE;
ALTER TABLE order_name ADD CONSTRAINT fk_order_name_client FOREIGN KEY (id_client) REFERENCES client (id_client) ON DELETE CASCADE;
ALTER TABLE order_name ADD CONSTRAINT fk_order_name_solar_panels FOREIGN KEY (id_solar_panels) REFERENCES solar_panels (id_solar_panels) ON DELETE CASCADE;
ALTER TABLE order_name ADD CONSTRAINT fk_order_name_solar_station_ins FOREIGN KEY (id_solar_station_installation) REFERENCES solar_station_installation (id_solar_station_installation) ON DELETE CASCADE;

ALTER TABLE solar_panels ADD CONSTRAINT fk_solar_panels_solar_panels_ty FOREIGN KEY (id_solar_panels_type) REFERENCES solar_panels_type (id_solar_panels_type) ON DELETE CASCADE;

ALTER TABLE order_name_employee ADD CONSTRAINT fk_order_name_employee_order_na FOREIGN KEY (id_order_name) REFERENCES order_name (id_order_name) ON DELETE CASCADE;
ALTER TABLE order_name_employee ADD CONSTRAINT fk_order_name_employee_employee FOREIGN KEY (id_employee) REFERENCES employee (id_employee) ON DELETE CASCADE;

ALTER TABLE order_name ADD CONSTRAINT xc_order_name_id_maintenance_id CHECK ((id_maintenance IS NOT NULL AND id_solar_station_installation IS NULL) OR (id_maintenance IS NULL AND id_solar_station_installation IS NOT NULL));

