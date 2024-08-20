-- smazání všech záznamů z tabulek

CREATE or replace FUNCTION clean_tables() RETURNS void AS $$
declare
l_stmt text;
begin
select 'truncate ' || string_agg(format('%I.%I', schemaname, tablename) , ',')
into l_stmt
from pg_tables
where schemaname in ('public');

execute l_stmt || ' cascade';
end;
$$ LANGUAGE plpgsql;
select clean_tables();

-- reset sekvenci

CREATE or replace FUNCTION restart_sequences() RETURNS void AS $$
DECLARE
i TEXT;
BEGIN
FOR i IN (SELECT column_default FROM information_schema.columns WHERE column_default SIMILAR TO 'nextval%')
  LOOP
         EXECUTE 'ALTER SEQUENCE'||' ' || substring(substring(i from '''[a-z_]*')from '[a-z_]+') || ' '||' RESTART 1;';
END LOOP;
END $$ LANGUAGE plpgsql;
select restart_sequences();
-- konec resetu

-- konec mazání
-- mohli bchom použít i jednotlivé příkazy truncate na každo tabulku


-- Remove conflicting tables
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS contract CASCADE;
DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS maintenance CASCADE;
DROP TABLE IF EXISTS manager CASCADE;
DROP TABLE IF EXISTS order_name CASCADE;
DROP TABLE IF EXISTS solar_panels CASCADE;
DROP TABLE IF EXISTS solar_panels_type CASCADE;
DROP TABLE IF EXISTS solar_station_installation CASCADE;
DROP TABLE IF EXISTS order_name_employee CASCADE;
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

--insert into country

INSERT INTO country (id_country, name) VALUES (1, 'Indonesia');
INSERT INTO country (id_country, name) VALUES (2, 'Colombia');
INSERT INTO country (id_country, name) VALUES (3, 'Slovenia');
INSERT INTO country (id_country, name) VALUES (4, 'Mauritania');
INSERT INTO country (id_country, name) VALUES (5, 'Poland');
INSERT INTO country (id_country, name) VALUES (6, 'Brazil');


--insert into address

insert into address (id_address, id_country, street, street_number, town) values (1,  4, 'Brown', null, 'Lipov');
insert into address (id_address, id_country, street, street_number, town) values (2,  2, 'Caliangt', null, 'Longde Chengguanzhen');
insert into address (id_address, id_country, street, street_number, town) values (3,  6, 'Eagle Crest', '126', 'Buçimas');
insert into address (id_address, id_country, street, street_number, town) values (4,  3, 'Delladonna', null, 'Bakau');
insert into address (id_address, id_country, street, street_number, town) values (5,  1, '8th', null, 'Kolonnawa');
insert into address (id_address, id_country, street, street_number, town) values (6,  6, 'Hansons', '5', 'Mengxi');
insert into address (id_address, id_country, street, street_number, town) values (7,  2, 'Stuart', null, 'Báguanos');
insert into address (id_address, id_country, street, street_number, town) values (8,  3, 'Kings', null, 'Buriram');
insert into address (id_address, id_country, street, street_number, town) values (9,  6, 'West', '9548', 'Caseros');
insert into address (id_address, id_country, street, street_number, town) values (10, 4, null, null, 'Cibingbin');
insert into address (id_address, id_country, street, street_number, town) values (11, 3, null, null, 'Pulau Pinang');
insert into address (id_address, id_country, street, street_number, town) values (12, 6, 'Eggendart', null, 'Sokol');
insert into address (id_address, id_country, street, street_number, town) values (13, 3, 'Columbus', null, 'Bayshint');
insert into address (id_address, id_country, street, street_number, town) values (14, 1, null, null, 'Paris 13');
insert into address (id_address, id_country, street, street_number, town) values (15, 1, 'Southridge', null, 'Gelan');
insert into address (id_address, id_country, street, street_number, town) values (16, 4, 'Del Mar', '191', 'Bagacay');
insert into address (id_address, id_country, street, street_number, town) values (17, 4, null, null, 'Parbatipur');
insert into address (id_address, id_country, street, street_number, town) values (18, 1, 'Gateway', '68', 'Příbram');
insert into address (id_address, id_country, street, street_number, town) values (19, 3, 'Briar Crest', '6', 'Banqiao');
insert into address (id_address, id_country, street, street_number, town) values (20, 6, null, null, 'Charlotte');
insert into address (id_address, id_country, street, street_number, town) values (21, 6, 'Vermont', null, 'Cikaludan');
insert into address (id_address, id_country, street, street_number, town) values (22, 6, null, '640', 'Temyasovo');
insert into address (id_address, id_country, street, street_number, town) values (23, 4, null, null, 'Itapecuru Mirim');
insert into address (id_address, id_country, street, street_number, town) values (24, 2, null, null, 'Seixezelo');
insert into address (id_address, id_country, street, street_number, town) values (25, 5, 'Onsgard', null, 'Baturaja');
insert into address (id_address, id_country, street, street_number, town) values (26, 5, null, null, 'Troyes');
insert into address (id_address, id_country, street, street_number, town) values (27, 5, null, '3', 'Sandakan');
insert into address (id_address, id_country, street, street_number, town) values (28, 2, 'Oakridge', null, 'Sośnicowice');
insert into address (id_address, id_country, street, street_number, town) values (29, 1, 'Clyde Gallagher', '288', 'La Jagua de Ibirico');
insert into address (id_address, id_country, street, street_number, town) values (30, 3, 'John Wall', null, 'Staryy Krym');
insert into address (id_address, id_country, street, street_number, town) values (31, 4, 'Hudson', null, 'Washington');
insert into address (id_address, id_country, street, street_number, town) values (32, 6, 'Northwestern', null, 'Udomlya');
insert into address (id_address, id_country, street, street_number, town) values (33, 5, 'American', null, 'Ollantaytambo');
insert into address (id_address, id_country, street, street_number, town) values (34, 1, 'Lukken', null, 'Pueblo Viejo');
insert into address (id_address, id_country, street, street_number, town) values (35, 4, 'Butterfield', null, 'Kamensk-Ural’skiy');
insert into address (id_address, id_country, street, street_number, town) values (36, 1, 'Waywood', null, 'Juncheng');
insert into address (id_address, id_country, street, street_number, town) values (37, 1, null, null, 'Penamacor');
insert into address (id_address, id_country, street, street_number, town) values (38, 5, 'Eastwood', '3', 'Hutang');
insert into address (id_address, id_country, street, street_number, town) values (39, 6, 'Carioca', '18', 'Ajuy');
insert into address (id_address, id_country, street, street_number, town) values (40, 1, 'Stuart', '65', 'Ucuncha');
insert into address (id_address, id_country, street, street_number, town) values (41, 3, 'Melody', null, 'Mae Lan');
insert into address (id_address, id_country, street, street_number, town) values (42, 2, 'Maple Wood', null, 'Granada');
insert into address (id_address, id_country, street, street_number, town) values (43, 1, 'Ruskin', null, 'Petaling Jaya');
insert into address (id_address, id_country, street, street_number, town) values (44, 2, 'Butterfield', null, 'Lianshi');
insert into address (id_address, id_country, street, street_number, town) values (45, 2, 'Karstens', '0569', 'Tân An');
insert into address (id_address, id_country, street, street_number, town) values (46, 3, 'Pond', null, 'San Rafael');
insert into address (id_address, id_country, street, street_number, town) values (47, 4, null, null, 'Tongshanxiang');
insert into address (id_address, id_country, street, street_number, town) values (48, 5, null, '2951', 'Machida');
insert into address (id_address, id_country, street, street_number, town) values (49, 2, 'Gina', null, 'Samanco');
insert into address (id_address, id_country, street, street_number, town) values (50, 1, 'Hagan', '88241', 'Tokoname');

--insert into client

insert into client (id_client, id_address, name, phone_number, email, additional_information) values (1, 15, 'Pauline Piquard', '+230 (180) 859-9054', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (2, 22, 'Margeaux Minchinton', '+86 (547) 419-9052', 'mminchinton1@constantcontact.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (3, 15, 'Emmi Tanman', '+86 (515) 116-7261', 'etanman2@t.co', 'Whole blood transfus NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (4, 28, 'Faydra Todarello', '+46 (367) 165-5505', 'ftodarello3@google.es', 'IV infusion clofarabine');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (5, 39, 'Bobbie Slarke', '+371 (494) 949-4025', 'bslarke4@yelp.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (6, 4, 'Christian Streeten', '+33 (440) 175-2987', 'cstreeten5@hhs.gov', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (7, 48, 'Anastasia Gage', '+30 (802) 502-4097', 'agage6@drupal.org', 'Eswl gb/bile duct');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (8, 20, 'Marj Dormer', '+387 (879) 720-9063', 'mdormer7@weebly.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (9, 49, 'Michael Terrey', '+63 (313) 605-2503', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (10, 19, 'Hammad Tropman', '+385 (786) 808-8572', 'htropman9@mysql.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (11, 34, 'Xena McKee', '+386 (470) 449-6860', null, 'Transfer of finger');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (12, 16, 'Kylila Brignall', '+86 (128) 356-4153', 'kbrignallb@mayoclinic.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (13, 1, 'Waldemar Stegell', '+7 (245) 809-8445', 'wstegellc@amazon.co.jp', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (14, 43, 'Frederich Hugenin', '+55 (233) 990-2662', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (15, 35, 'Lenci Riley', '+1 (687) 375-5710', 'lrileye@issuu.com', 'Cul-de-sac operation NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (16, 32, 'Jacquelynn Guisby', '+62 (130) 945-3053', 'jguisbyf@home.pl', 'Lysis trach/larynx adhes');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (17, 15, 'Huberto Windrum', '+66 (232) 905-8264', 'hwindrumg@ted.com', 'Turbinectomy NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (18, 31, 'Celle Lelievre', '+86 (308) 551-7324', 'clelievreh@boston.com', 'Intestinal fixation NOS');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (19, 42, 'Averyl Danieli', '+976 (195) 799-7727', 'adanielii@ovh.net', 'Parasitology-lymph sys');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (20, 43, 'Johannah Bramer', '+46 (933) 906-0033', 'jbramerj@bbb.org', 'Bladder operation NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (21, 7, 'Alexandr Marlowe', '+55 (394) 177-9821', null, 'CAS w multiple datasets');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (22, 34, 'Evita Penas', '+351 (735) 887-8118', 'epenasl@google.ca', 'Renal decapsulation');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (23, 19, 'Junette Birchenough', '+299 (355) 144-0611', null, 'Endosc dilation ampulla');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (24, 17, 'Marris Dorre', '+57 (892) 330-4620', 'mdorren@webnode.com', 'Tonsillectomy');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (25, 27, 'Orv Kobelt', '+595 (136) 951-7727', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (26, 42, 'Rozelle Ahlf', '+86 (164) 831-4122', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (27, 15, 'Hervey Ingliby', '+81 (849) 902-8563', 'hinglibyq@mysql.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (28, 48, 'Germain Beyne', '+86 (545) 637-5968', 'gbeyner@multiply.com', 'Endosc dilation ampulla');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (29, 48, 'Winslow Ferryn', '+62 (800) 268-5100', 'wferryns@privacy.gov.au', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (30, 41, 'Sigrid Dipple', '+53 (476) 785-9670', 'sdipplet@1und1.de', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (31, 38, 'Kizzee Kayzer', '+381 (366) 885-0864', 'kkayzeru@discovery.com', 'Corneal transplant NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (32, 45, 'Ernest Beaman', '+62 (420) 906-4576', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (33, 44, 'Addia Kettridge', '+357 (497) 184-1154', null, 'Therapeu plateltpheresis');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (34, 47, 'Aprilette Pitman', '+81 (611) 857-4413', null, 'Oth unilat oophorectomy');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (35, 10, 'Abraham Pantridge', '+48 (508) 633-2219', 'apantridgey@joomla.org', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (36, 25, 'Tate Rizzelli', '+51 (883) 828-8144', 'trizzelliz@amazon.co.jp', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (37, 45, 'Zachery MacGibbon', '+62 (482) 913-3851', 'zmacgibbon10@rediff.com', 'Excise minor les lid NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (38, 41, 'Nedi Werrett', '+34 (833) 620-9351', 'nwerrett11@amazon.de', 'Pharyngeal repair NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (39, 13, 'Sorcha Phalip', '+63 (856) 270-4541', 'sphalip12@homestead.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (40, 34, 'Millard Maude', '+55 (971) 421-6880', 'mmaude13@usnews.com', 'Replace vag/vulv packing');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (41, 4, 'Harris Grealey', '+52 (348) 700-7903', 'hgrealey14@globo.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (42, 19, 'Olag Gaunson', '+420 (222) 795-9161', 'ogaunson15@blog.com', 'Toxicology-lower GI');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (43, 41, 'Frederique Derye-Barrett', '+261 (986) 460-2242', 'fderyebarrett16@squarespace.com', 'Bilat tubal division NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (44, 19, 'Ferrell Yeliashev', '+33 (928) 350-4970', 'fyeliashev17@posterous.com', null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (45, 5, 'Ogden Calcott', '+63 (629) 678-0540', null, null);
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (46, 25, 'Jermaine Trott', '+7 (336) 693-9780', 'jtrott19@newyorker.com', 'Op bi in ing hrn-grf NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (47, 49, 'Riva Dewdney', '+420 (614) 580-9360', 'rdewdney1a@quantcast.com', 'LITT lesn, guide oth/NOS');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (48, 29, 'Wainwright Oles', '+63 (619) 620-4485', null, 'Occlude leg artery NEC');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (49, 26, 'Sophronia Accomb', '+58 (164) 485-5726', null, 'Close reduc-femur epiphy');
insert into client (id_client, id_address, name, phone_number, email, additional_information) values (50, 15, 'Mercy Abramski', '+62 (462) 660-1516', 'mabramski1d@freewebs.com', null);

--insert into employee

insert into employee (id_employee, id_address, name, surname, salary) values (1, 14, 'Nerita', 'Stambridge', 31688);
insert into employee (id_employee, id_address, name, surname, salary) values (2, 1, 'Thayne', 'Banbrigge', 22064);
insert into employee (id_employee, id_address, name, surname, salary) values (3, 21, 'Munmro', 'Lean', 83933);
insert into employee (id_employee, id_address, name, surname, salary) values (11, 22, 'Rafaelita', 'Blazej', 83052);
insert into employee (id_employee, id_address, name, surname, salary) values (12, 33, 'Bridget', 'Weavill', 65655);
insert into employee (id_employee, id_address, name, surname, salary) values (13, 20, 'Ugo', 'Hearne', 95198);
insert into employee (id_employee, id_address, name, surname, salary) values (14, 11, 'Judie', 'Sacks', 49621);
insert into employee (id_employee, id_address, name, surname, salary) values (15, 9, 'Gail', 'Wroath', 30593);
insert into employee (id_employee, id_address, name, surname, salary) values (19, 43, 'Patrice', 'Couronne', 41861);
insert into employee (id_employee, id_address, name, surname, salary) values (28, 14, 'Lana', 'Rodda', 47659);
insert into employee (id_employee, id_address, name, surname, salary) values (29, 20, 'Gustav', 'Sealand', 37751);
insert into employee (id_employee, id_address, name, surname, salary) values (30, 10, 'Mel', 'Rousell', 73982);
insert into employee (id_employee, id_address, name, surname, salary) values (31, 17, 'Cary', 'Demetr', 63410);
insert into employee (id_employee, id_address, name, surname, salary) values (32, 5, 'Seward', 'Harraway', 61088);
insert into employee (id_employee, id_address, name, surname, salary) values (33, 28, 'Cale', 'Kalderon', 94629);
insert into employee (id_employee, id_address, name, surname, salary) values (34, 36, 'Ashley', 'Pevsner', 69285);
insert into employee (id_employee, id_address, name, surname, salary) values (35, 24, 'Donnamarie', 'Heisler', 49934);
insert into employee (id_employee, id_address, name, surname, salary) values (36, 28, 'Inga', 'Livingstone', 49416);
insert into employee (id_employee, id_address, name, surname, salary) values (37, 28, 'Waite', 'Feasby', 50642);
insert into employee (id_employee, id_address, name, surname, salary) values (38, 4, 'Gail', 'Huyge', 11018);
insert into employee (id_employee, id_address, name, surname, salary) values (39, 48, 'Peder', 'Sidwick', 56899);
insert into employee (id_employee, id_address, name, surname, salary) values (45, 17, 'Bryn', 'Wignall', 61128);
insert into employee (id_employee, id_address, name, surname, salary) values (46, 3, 'Margot', 'Kirman', 59684);
insert into employee (id_employee, id_address, name, surname, salary) values (47, 43, 'Kaylee', 'Ofener', 31744);

--insert into maintenance

INSERT INTO maintenance (id_maintenance, maintenance_type, description) VALUES (1, 'Wall Protection', 'BLXUY9uQz4Z5wBBcETPZBbpwCJRYEAchS69MZXzJcXkUz5TCjHc');
INSERT INTO maintenance (id_maintenance, maintenance_type, description) VALUES (2, 'Panels Cleaning', 'BLdEve2skT8tMveMcjLs2mDNmG4BUA94TCqNsBz1RNBvJ1Ni4Nw');
INSERT INTO maintenance (id_maintenance, maintenance_type, description) VALUES (3, 'Base Support', 'BMKBpAkdiVoJdaxYP2pQVDfm5uTANT2VeHpM18GUEr58rSsLvzG');
INSERT INTO maintenance (id_maintenance, maintenance_type, description) VALUES (4, 'Roof Preparing', 'sdfgsdfgsdf18GUEr58rSsfsdgdfsfgdsLsvzG');



--insert into manager

INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (19, 196, null);
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (14, 374, 'Chel');
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (28, 516, null);
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (34, 740, 'Lera vajicko');
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (45, 1042, 'Pchel');
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (30, 1202, null);
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (39, 1242, 'Dima Obrez');
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (33, 1281, 'Nagibator Galaktiki');
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (32, 1338, 'Dima Biser');
INSERT INTO manager (id_employee, number_of_cars, nickname) VALUES (3, 1562, null);

--insert into solar_station_installation

insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (1, 22, 4.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (2, 14, 8.7);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (3, 17, 3.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (4, 32, 6.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (5, 24, 2.0);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (6, 27, 9.5);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (7, 10, 8.0);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (8, 36, 5.0);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (9, 20, 4.0);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (10, 25, 5.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (11, 21, 1.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (12, 31, 2.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (13, 29, 9.7);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (14, 30, 3.9);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (15, 40, 7.1);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (16, 29, 3.9);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (17, 28, 4.5);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (18, 19, 2.1);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (19, 12, 3.8);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (20, 11, 7.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (21, 32, 3.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (22, 36, 9.1);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (23, 17, 2.0);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (24, 10, 4.5);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (25, 16, 6.7);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (26, 25, 3.5);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (27, 18, 2.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (28, 25, 8.8);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (29, 31, 7.5);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (30, 30, 6.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (31, 40, 1.7);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (32, 17, 4.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (33, 10, 4.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (34, 40, 7.8);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (35, 16, 6.5);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (36, 35, 7.1);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (37, 24, 7.7);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (38, 36, 9.2);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (39, 39, 3.8);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (40, 17, 7.3);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (41, 24, 1.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (42, 24, 4.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (43, 34, 3.0);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (44, 22, 6.1);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (45, 17, 6.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (46, 21, 5.6);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (47, 27, 2.3);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (48, 18, 2.4);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (49, 32, 3.7);
insert into solar_station_installation (id_solar_station_installation, total_voltage, size) values (50, 14, 5.4);

--insert into solar_panels_type

INSERT INTO solar_panels_type (id_solar_panels_type, name) VALUES (1, 'Zontrax');
INSERT INTO solar_panels_type (id_solar_panels_type, name) VALUES (2, 'Bitchip');
INSERT INTO solar_panels_type (id_solar_panels_type, name) VALUES (3, 'Solarbreeze');

--insert into solar_panels

INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (1, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (2, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (3, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (4, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (5, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (6, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (7, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (8, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (9, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (10, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (11, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (12, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (13, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (14, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (15, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (16, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (17, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (18, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (19, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (20, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (21, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (22, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (23, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (24, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (25, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (26, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (27, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (28, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (29, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (30, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (31, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (32, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (33, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (34, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (35, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (36, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (37, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (38, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (39, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (40, 2, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (41, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (42, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (43, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (44, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (45, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (46, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (47, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (48, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (49, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (50, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (51, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (52, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (53, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (54, 2, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (55, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (56, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (57, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (58, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (59, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (60, 2, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (61, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (62, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (63, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (64, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (65, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (66, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (67, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (68, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (69, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (70, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (71, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (72, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (73, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (74, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (75, 3, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (76, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (77, 2, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (78, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (79, 2, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (80, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (81, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (82, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (83, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (84, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (85, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (86, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (87, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (88, 2, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (89, 3, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (90, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (91, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (92, 1, 'Doyle LLC');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (93, 1, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (94, 2, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (95, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (96, 3, 'Bailey Inc');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (97, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (98, 1, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (99, 2, 'Labadie and Sons');
INSERT INTO solar_panels (id_solar_panels, id_solar_panels_type, supplier) VALUES (100, 3, 'Doyle LLC');

--insert into order_name

insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (1, null, 9, 41, 42, 34, '2022-02-20', null, 487886);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (2, 2, 47, 41, 13, null, '2021-09-15', 'Bact smear-lower urinary', 206781);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (3, 4, 8, 5, 8, null, '2021-12-08', 'Vulvar/perin repair NEC', 451121);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (4, 4, 28, 22, 55, null, '2021-08-08', 'Corneal scrape for smear', 259793);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (5, null, 7, 14, 16, 42, '2021-12-11', null, 486400);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (6, 3, 13, 37, 17, null, '2021-11-04', 'Simple sut-common duct', 232645);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (7, null, 14, 22, 97, 5, '2021-09-18', null, 233095);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (8, null, 44, 20, 22, 43, '2021-11-11', null, 152636);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (9, null, 3, 27, 29, 3, '2021-12-11', null, 376135);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (10, 1, 19, 1, 68, null, '2021-10-10', 'Close reduc-femur epiphy', 304364);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (11, 3, 37, 4, 36, null, '2021-12-03', 'Ant synechia lysis NEC', 304379);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (12, null, 2, 20, 34, 15, '2022-01-11', null, 183641);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (13, 4, 18, 37, 5, null, '2021-06-25', 'Repair of hip, NEC', 216210);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (14, null, 27, 32, 37, 34, '2022-05-01', null, 271353);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (15, 4, 29, 43, 83, null, '2021-06-10', 'Ligate gastric varices', 393158);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (16, null, 12, 12, 95, 26, '2021-10-13', null, 291275);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (17, null, 34, 40, 10, 3, '2022-02-08', null, 156566);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (18, 1, 37, 26, 11, null, '2021-10-04', 'Esophagoscopy by incis', 163777);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (19, null, 43, 21, 74, 17, '2021-12-23', null, 86907);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (20, 4, 26, 34, 2, null, '2021-08-28', 'Transfusion NEC', 86033);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (21, null, 9, 5, 20, 20, '2021-11-20', null, 342887);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (22, null, 8, 35, 12, 2, '2021-11-06', null, 464578);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (23, null, 43, 45, 38, 42, '2021-08-13', null, 266760);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (24, null, 19, 49, 22, 21, '2021-07-30', null, 493827);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (25, 2, 48, 20, 53, null, '2022-03-04', 'Symphysiotomy', 132881);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (26, 3, 11, 17, 91, null, '2021-05-11', 'Fallop tube dx proc NEC', 341149);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (27, 2, 28, 44, 38, null, '2021-08-07', 'Choroid plexectomy', 240130);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (28, 1, 31, 5, 83, null, '2021-05-15', 'Closed biopsy of tongue', 420786);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (29, 2, 48, 40, 49, null, '2021-05-23', 'Endosc remove bile stone', 355315);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (30, null, 37, 24, 29, 46, '2021-12-07', null, 267632);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (31, null, 36, 40, 17, 19, '2021-10-26', null, 113742);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (32, null, 50, 18, 89, 22, '2022-04-25', null, 350536);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (33, 2, 49, 4, 71, null, '2021-06-19', 'TRAM flap, pedicled', 370697);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (34, 3, 21, 6, 36, null, '2022-03-02', 'Chorioret les radiother', 144775);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (35, null, 50, 29, 2, 40, '2021-10-09', null, 329096);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (36, null, 10, 23, 60, 50, '2022-04-29', null, 51713);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (37, 1, 46, 26, 100, null, '2021-10-25', 'Abdominal x-ray NEC', 385642);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (38, null, 15, 40, 54, 3, '2021-12-17', null, 214222);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (39, 4, 3, 29, 72, null, '2021-08-03', 'Culture-op wound', 404855);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (40, 3, 15, 1, 63, null, '2022-04-21', 'Vaginoscopy', 363556);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (41, 2, 5, 5, 20, null, '2022-02-20', 'Thoracoscopic pleural bx', 276001);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (42, 4, 6, 47, 46, null, '2021-08-25', 'Renal anastomosis', 480421);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (43, null, 18, 48, 16, 11, '2022-01-10', null, 358471);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (44, 1, 15, 40, 45, null, '2021-06-01', 'Cell blk/pap-upper urin', 85821);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (45, 1, 13, 20, 36, null, '2021-12-28', 'Grp therap psychsex dysf', 64807);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (46, 1, 12, 36, 17, null, '2021-07-13', 'Lid lacer rx-prt th NEC', 391623);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (47, 2, 29, 38, 11, null, '2021-12-03', 'Unil ext rad mastectomy', 210347);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (48, 3, 15, 35, 90, null, '2021-11-01', 'D & C for preg terminat', 120618);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (49, null, 5, 14, 39, 14, '2021-12-15', null, 25642);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (50, 2, 36, 4, 77, null, '2021-12-02', 'Dialysis arteriovenostom', 425241);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (51, 1, 3, 9, 13, null, '2021-09-17', 'Oth exc, fus, repair toe', 433268);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (52, 4, 33, 30, 8, null, '2022-04-28', 'Micro exam-nervous NEC', 350173);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (53, 4, 11, 18, 20, null, '2021-10-18', 'Renal operation NEC', 244134);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (54, null, 45, 41, 45, 41, '2021-08-12', null, 23106);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (55, null, 7, 26, 74, 17, '2022-01-08', null, 399942);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (56, 1, 6, 24, 63, null, '2021-06-15', 'Oth transmyo revascular', 349661);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (57, null, 22, 45, 95, 47, '2022-02-25', null, 444705);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (58, 2, 7, 39, 77, null, '2022-02-18', 'Colostomy NOS', 185744);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (59, null, 33, 30, 26, 30, '2021-09-08', null, 349215);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (60, null, 3, 5, 25, 9, '2021-09-13', null, 421966);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (61, null, 15, 32, 97, 9, '2021-12-09', null, 112472);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (62, null, 24, 10, 74, 35, '2021-11-06', null, 408348);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (63, 2, 41, 43, 86, null, '2022-01-06', 'Remove imp device-femur', 162491);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (64, 4, 18, 47, 43, null, '2021-06-02', 'Impl or rev art anal sph', 86582);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (65, null, 2, 41, 98, 10, '2021-11-21', null, 432584);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (66, 1, 35, 11, 8, null, '2022-05-03', 'Amnioscopy', 399785);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (67, 3, 34, 8, 77, null, '2022-01-24', 'Man replace invert uter', 320008);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (68, null, 9, 10, 96, 18, '2022-02-25', null, 234034);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (69, 4, 33, 40, 12, null, '2021-09-21', 'Intracarot amobarb test', 487722);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (70, null, 7, 45, 87, 41, '2021-12-18', null, 127987);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (71, 1, 37, 4, 26, null, '2022-03-02', 'Part facial ostectom NEC', 260106);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (72, 1, 29, 9, 23, null, '2022-05-05', 'Hysterotomy to termin pg', 31156);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (73, null, 28, 46, 12, 23, '2021-09-14', null, 253797);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (74, 2, 21, 39, 24, null, '2022-02-04', 'Total gastrectomy NEC', 189142);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (75, 1, 26, 34, 88, null, '2021-08-25', 'Other muscle/fasc suture', 220500);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (76, null, 6, 22, 68, 46, '2021-11-22', null, 363363);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (77, null, 50, 21, 49, 38, '2022-03-05', null, 201366);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (78, 1, 44, 39, 14, null, '2022-04-17', 'Other spinal traction', 194529);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (79, 4, 2, 30, 65, null, '2021-12-11', 'Individ psychotherap NEC', 78365);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (80, 1, 17, 48, 7, null, '2021-07-13', 'Tenotomy of hand', 217093);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (81, 2, 13, 21, 22, null, '2022-03-24', 'Oth laryngeal operation', 251345);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (82, 3, 26, 16, 84, null, '2021-07-29', 'Drain face & mouth floor', 372461);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (83, 4, 8, 46, 47, null, '2021-08-25', 'Endosc inser nasopan tub', 398199);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (84, 3, 44, 16, 23, null, '2021-12-18', 'Oth dx proc-radius/ulna', 299057);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (85, 2, 23, 19, 60, null, '2021-10-28', 'Cricopharyngeal myotomy', 411924);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (86, null, 24, 24, 65, 7, '2021-07-28', null, 408702);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (87, null, 6, 45, 71, 19, '2021-08-31', null, 225844);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (88, 3, 25, 46, 64, null, '2022-01-02', 'Excision of joint NEC', 134293);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (89, 1, 40, 46, 44, null, '2021-09-18', 'Conjunctivocystorhinost', 104928);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (90, 2, 9, 46, 69, null, '2022-04-05', 'Thorac esophagogastrost', 263397);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (91, null, 30, 4, 38, 3, '2021-06-14', null, 252416);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (92, null, 10, 24, 82, 4, '2021-05-17', null, 186630);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (93, 3, 41, 43, 42, null, '2021-05-21', 'Remov intralum mouth FB', 77391);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (94, 3, 2, 11, 88, null, '2022-04-14', 'Int fixation-tibia/fibul', 22802);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (95, 1, 14, 19, 98, null, '2022-03-05', 'Alcohol detoxification', 80568);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (96, 4, 48, 2, 96, null, '2021-10-30', 'Rep anuls fibros NEC/NOS', 315538);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (97, 1, 18, 48, 83, null, '2021-12-19', 'Epistaxis control NEC', 149688);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (98, 4, 32, 49, 24, null, '2021-10-09', 'Arth/pros rem wo rep-hip', 287862);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (99, 1, 15, 16, 43, null, '2021-08-06', 'Thoracoscopc lung biopsy', 404029);
insert into order_name (id_order_name, id_maintenance, id_address, id_client, id_solar_panels, id_solar_station_installation, date_of_realization, additional_information, total_price) values (100, 4, 42, 24, 33, null, '2021-05-31', 'Imageless comp asst surg', 314615);--insert into contract
--46 id_client
select id_employee from manager;

--insert into contract

INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (1, 32, 1, '2022-04-08', 'Foot & toe ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (2, 19, 2, '2021-12-28', 'Electro-oculogram');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (3, 33, 3, '2021-12-06', 'Uterine repair NEC ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (4, 3, 4, '2021-10-23', 'Replace wound pack ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (5, 34, 5, '2021-09-10', 'Loc exc bone');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (6, 28, 6, '2022-02-24', 'Bact smear- ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (7, 30, 7, '2022-02-19', 'Pancreatic homotransplan chest cage');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (8, 3, 8, '2021-05-12', 'Oth part cholecystectomy ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (9, 14, 9, '2021-08-31', 'Ventricl shunt-');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (10, 19, 10, '2021-12-13', 'Non-op ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (11, 39, 11, '2022-03-27', 'Eyelid operation NEC ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (12, 45, 12, '2021-05-19', 'Testes dx procedure');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (13, 30, 13, '2022-02-15', 'Incision of mediastinum ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (14, 33, 14, '2021-09-04', 'Repair vess w ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (15, 32, 15, '2021-10-30', 'Thyroid scan/ /bladder');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (16, 34, 16, '2021-09-25', 'Reduction torsion testes sys');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (17, 14, 17, '2021-09-30', 'Parasitology-upper hrn-gr NEC');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (18, 34, 18, '2022-04-30', 'Excision of nipple');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (19, 19, 19, '2022-05-04', 'Upper limb lymphangiogrm ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (20, 30, 20, '2021-06-11', 'Lower limb lymphangiogrm ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (22, 33, 21, '2022-01-10', 'Bone mineral density');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (23, 28, 22, '2022-03-24', 'Remove solitary fal ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (24, 30, 23, '2021-12-01', 'Middle ear incision ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (25, 14, 24, '2021-07-31', 'Vessel resect/ bile duct');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (26, 32, 25, '2021-12-01', 'Periph nerve destruction /ulna');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (27, 45, 26, '2021-11-26', 'Blepharorrhaphy');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (28, 34, 27, '2021-12-11', 'Plaster jacket applicat ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (29, 3, 28, '2022-02-12', 'Uterine repair NEC');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (30, 14, 29, '2021-10-22', 'Open prostatic biopsy ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (31, 28, 30, '2022-02-18', 'Oth arthrotomy-');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (21, 19, 31, '2021-08-07', 'Intravascul imaging NEC');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (32, 32, 32, '2021-08-19', 'Intermitt skel traction');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (33, 33, 33, '2021-08-30', 'Bilat radical mastectomy ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (34, 32, 34, '2021-06-21', 'Cervical dx procedur ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (35, 45, 35, '2021-09-25', 'Remov imp dev ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (36, 45, 36, '2022-04-19', 'Cystoscopy thru stoma mus NEC');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (37, 32, 37, '2021-12-09', 'Auto hem stem');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (38, 32, 38, '2022-04-09', 'Tracheoscopy thru stoma');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (39, 14, 39, '2021-08-10', 'Ins/re ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (40, 33, 40, '2021-06-28', 'Local gastr destruct');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (41, 30, 41, '2022-03-07', 'Closed lung biopsy ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (42, 34, 42, '2021-10-29', 'Head tomography NEC');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (43, 32, 43, '2021-10-08', 'Rectal packing');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (44, 3, 44, '2021-10-25', 'Intelligence test admin');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (45, 14, 45, '2022-04-09', 'Culdocentesis');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (46, 34, 46, '2022-02-02', 'Imp/repl thor');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (47, 14, 47, '2021-08-19', 'Vaginal douche');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (48, 3, 48, '2022-03-09', 'Thumb reconstruction NEC');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (49, 3, 49, '2022-05-07', 'Aspirat curet- ');
INSERT INTO contract (id_contract, id_employee, id_order_name, date_of_signing, description) VALUES (50, 34, 50, '2022-04-11', 'Intravs msmt ves tubes');


select * from contract;

--insert into order_name_employee (decomposition of many to many)

INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (20, 15);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (5, 2);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (7, 30);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (37, 15);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (1, 28);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (17, 35);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (42, 36);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (49, 29);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (31, 47);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (45, 31);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (40, 11);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (42, 35);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (15, 28);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (39, 30);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (49, 3);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (49, 12);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (2, 36);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (37, 14);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (6, 37);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (8, 12);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (38, 46);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (47, 13);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (9, 28);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (37, 45);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (28, 45);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (2, 46);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (50, 29);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (35, 34);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (35, 32);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (17, 31);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (19, 28);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (30, 33);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (2, 30);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (47, 2);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (48, 13);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (34, 15);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (2, 28);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (39, 11);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (30, 2);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (36, 19);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (23, 39);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (14, 3);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (46, 47);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (49, 33);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (13, 31);


INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (1, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (2, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (3, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (4, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (5, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (6, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (7, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (8, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (9, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (10, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (11, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (12, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (13, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (14, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (15, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (16, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (17, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (18, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (19, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (20, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (21, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (22, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (23, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (24, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (25, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (26, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (27, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (28, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (29, 1);
--INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (29, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (30, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (31, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (32, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (33, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (34, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (35, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (36, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (37, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (38, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (39, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (40, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (41, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (42, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (43, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (44, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (45, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (46, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (47, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (48, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (49, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (50, 1);


INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (51, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (52, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (53, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (54, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (55, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (56, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (57, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (58, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (59, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (60, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (61, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (62, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (63, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (64, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (65, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (66, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (67, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (68, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (69, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (70, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (71, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (72, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (73, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (74, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (75, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (76, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (77, 1);
--INSERT INTO order_name_employee (id_order_name, id_employee) VALUES7729, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (78, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (79, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (80, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (81, 1);

--INSERT INTO order_name_employee (id_order_name, id_employee) VALUES8134, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (82, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (83, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (84, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (85, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (86, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (87, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (88, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (89, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (90, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (91, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (92, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (93, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (94, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (95, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (96, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (97, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (98, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (99, 1);
INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (100, 1);



--INSERT INTO order_name_employee (id_order_name, id_employee) VALUES (33, 1);


