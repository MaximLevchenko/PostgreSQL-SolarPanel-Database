-- 1. Select names of all clients, which decided to ONLY build solar station with Bitchip solar panels
-- RA {solar_panels_type(name='Bitchip')*solar_panels*order_name[order_name.id_client=client.id_client>client}[name]
-- SQL:

SELECT DISTINCT name
FROM CLIENT
WHERE EXISTS (
    SELECT DISTINCT 1
    FROM (
             SELECT DISTINCT *
             FROM SOLAR_PANELS_TYPE
             WHERE name = 'Bitchip'
         ) R1
             NATURAL JOIN SOLAR_PANELS
             NATURAL JOIN ORDER_NAME
    WHERE ORDER_NAME.id_client = CLIENT.id_client
);
-- 2. Seleact id of all clients who have decided to order both maintenance and solar station installations
-- RA {<!-- -->{{client[id_client=order_name.id_client>order_name<*solar_station_installation}[id_client] ∩ {client[id_client=order_name.id_client>order_name<*maintenance}[id_client]}}*client
-- SQL:

SELECT DISTINCT *
FROM (
         SELECT DISTINCT id_client
         FROM (
                  SELECT DISTINCT id_order_name,
                                  id_maintenance,
                                  id_address,
                                  id_client,
                                  id_solar_panels,
                                  id_solar_station_installation,
                                  date_of_realization,
                                  additional_information,
                                  total_price
                  FROM (
                           SELECT DISTINCT *
                           FROM ORDER_NAME
                           WHERE EXISTS (
                               SELECT DISTINCT 1
                               FROM CLIENT
                               WHERE id_client = ORDER_NAME.id_client
                           )
                       ) R1
                           NATURAL JOIN SOLAR_STATION_INSTALLATION
              ) R2
         INTERSECT
         SELECT DISTINCT id_client
         FROM (
                  SELECT DISTINCT id_order_name,
                                  id_maintenance,
                                  id_address,
                                  id_client,
                                  id_solar_panels,
                                  id_solar_station_installation,
                                  date_of_realization,
                                  additional_information,
                                  total_price
                  FROM (
                           SELECT DISTINCT *
                           FROM ORDER_NAME ORDER_NAME1
                           WHERE EXISTS (
                               SELECT DISTINCT 1
                               FROM CLIENT CLIENT1
                               WHERE id_client = ORDER_NAME1.id_client
                           )
                       ) R3
                           NATURAL JOIN MAINTENANCE
              ) R4
     ) R5
         NATURAL JOIN CLIENT CLIENT2;

-- 3. Select date from orders, which were all managed by employee with id name Nerita
-- RA {employee(name='Nerita')*order_name_employee[order_name_employee.id_order_name=order_name.id_order_name>order_name}[date_of_realization]
-- SQL:
SELECT DISTINCT date_of_realization
FROM ORDER_NAME
WHERE EXISTS (
    SELECT DISTINCT 1
    FROM (
             SELECT DISTINCT *
             FROM EMPLOYEE
             WHERE name = 'Nerita'
         ) R1
             NATURAL JOIN ORDER_NAME_EMPLOYEE
    WHERE ORDER_NAME_EMPLOYEE.id_order_name = ORDER_NAME.id_order_name
);

-- 4. Select all clients from Poland, who have built their stations with solar panels supplier 'Doyle LLC'
-- RA {<!-- -->{client*address[address.id_country=country.id_country]country}(country.name='Poland')}[id_client = order_name.id_client>order_name*solar_panels(supplier='Doyle LLC')
-- SQL:
SELECT DISTINCT *
FROM (
         SELECT DISTINCT *
         FROM ORDER_NAME
         WHERE EXISTS (
             SELECT DISTINCT 1
             FROM (
                      SELECT DISTINCT *
                      FROM (
                               SELECT DISTINCT id_address,
                                               CLIENT.id_client,
                                               CLIENT.name,
                                               CLIENT.phone_number,
                                               CLIENT.email,
                                               CLIENT.additional_information,
                                               ADDRESS.id_country,
                                               ADDRESS.street,
                                               ADDRESS.street_number,
                                               ADDRESS.town,
                                               COUNTRY.id_country AS id_country_1,
                                               COUNTRY.name AS name_1
                               FROM CLIENT
                                        NATURAL JOIN ADDRESS
                                        JOIN COUNTRY ON ADDRESS.id_country = COUNTRY.id_country
                           ) R1
                      WHERE R1.name_1 = 'Poland'
                  ) R2
             WHERE id_client = ORDER_NAME.id_client
         )
     ) R3
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM SOLAR_PANELS
    WHERE supplier = 'Doyle LLC'
) R4;

-- 5. Select all managers, who have at least 1000 cars.
-- RA manager(number_of_cars>1000)
-- SQL:
SELECT *
FROM MANAGER
WHERE number_of_cars > 1000;

-- 6. Select all clients from Brazil who ordered a maintenance type "Panels Cleaning"
-- RA {<!-- -->{client*address[address.id_country=country.id_country]country}(country.name='Brazil')}[id_client = order_name.id_client>order_name*maintenance(maintenance_type = 'Panels Cleaning')
--- SQL:
SELECT DISTINCT *
FROM (
         SELECT DISTINCT *
         FROM ORDER_NAME
         WHERE EXISTS (
             SELECT DISTINCT 1
             FROM (
                      SELECT DISTINCT *
                      FROM (
                               SELECT DISTINCT id_address,
                                               CLIENT.id_client,
                                               CLIENT.name,
                                               CLIENT.phone_number,
                                               CLIENT.email,
                                               CLIENT.additional_information,
                                               ADDRESS.id_country,
                                               ADDRESS.street,
                                               ADDRESS.street_number,
                                               ADDRESS.town,
                                               COUNTRY.id_country AS id_country_1,
                                               COUNTRY.name AS name_1
                               FROM CLIENT
                                        NATURAL JOIN ADDRESS
                                        JOIN COUNTRY ON ADDRESS.id_country = COUNTRY.id_country
                           ) R1
                      WHERE R1.name_1 = 'Brazil'
                  ) R2
             WHERE id_client = ORDER_NAME.id_client
         )
     ) R3
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM MAINTENANCE
    WHERE maintenance_type = 'Panels Cleaning'
) R4;

-- 7. Seleact id of all clients who have decided to order ONLY solar panels installations
-- RA {client[id_client=order_name.id_client>order_name<*solar_station_installation}[id_client] \ {client[id_client=order_name.id_client>order_name<*maintenance}[id_client]
-- SQL:
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT id_order_name,
                         id_maintenance,
                         id_address,
                         id_client,
                         id_solar_panels,
                         id_solar_station_installation,
                         date_of_realization,
                         additional_information,
                         total_price
         FROM (
                  SELECT DISTINCT *
                  FROM ORDER_NAME
                  WHERE EXISTS (
                      SELECT DISTINCT 1
                      FROM CLIENT
                      WHERE id_client = ORDER_NAME.id_client
                  )
              ) R1
                  NATURAL JOIN SOLAR_STATION_INSTALLATION
     ) R2
EXCEPT
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT id_order_name,
                         id_maintenance,
                         id_address,
                         id_client,
                         id_solar_panels,
                         id_solar_station_installation,
                         date_of_realization,
                         additional_information,
                         total_price
         FROM (
                  SELECT DISTINCT *
                  FROM ORDER_NAME ORDER_NAME1
                  WHERE EXISTS (
                      SELECT DISTINCT 1
                      FROM CLIENT CLIENT1
                      WHERE id_client = ORDER_NAME1.id_client
                  )
              ) R3
                  NATURAL JOIN MAINTENANCE
     ) R4;

-- 8. Seleact id of all clients who have decided to order maintenance or solar station installations-- RA {client[id_client=order_name.id_client>order_name<*solar_station_installation}[id_client] ∪ {client[id_client=order_name.id_client>order_name<*maintenance}[id_client]
-- SQL:
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT id_order_name,
                         id_maintenance,
                         id_address,
                         id_client,
                         id_solar_panels,
                         id_solar_station_installation,
                         date_of_realization,
                         additional_information,
                         total_price
         FROM (
                  SELECT DISTINCT *
                  FROM ORDER_NAME
                  WHERE EXISTS (
                      SELECT DISTINCT 1
                      FROM CLIENT
                      WHERE id_client = ORDER_NAME.id_client
                  )
              ) R1
                  NATURAL JOIN SOLAR_STATION_INSTALLATION
     ) R2
UNION
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT id_order_name,
                         id_maintenance,
                         id_address,
                         id_client,
                         id_solar_panels,
                         id_solar_station_installation,
                         date_of_realization,
                         additional_information,
                         total_price
         FROM (
                  SELECT DISTINCT *
                  FROM ORDER_NAME ORDER_NAME1
                  WHERE EXISTS (
                      SELECT DISTINCT 1
                      FROM CLIENT CLIENT1
                      WHERE id_client = ORDER_NAME1.id_client
                  )
              ) R3
                  NATURAL JOIN MAINTENANCE
     ) R4;

-- 9. Clients, which didn't order a maintenance
-- RA {client[id_client=order_name.id_client>order_name!<*maintenance}[id_client]
-- SQL:
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT *
         FROM ORDER_NAME
         WHERE EXISTS (
             SELECT DISTINCT 1
             FROM CLIENT
             WHERE id_client = ORDER_NAME.id_client
         )
         EXCEPT
         SELECT DISTINCT id_order_name,
                         id_maintenance,
                         id_address,
                         id_client,
                         id_solar_panels,
                         id_solar_station_installation,
                         date_of_realization,
                         additional_information,
                         total_price
         FROM (
                  SELECT DISTINCT *
                  FROM ORDER_NAME
                  WHERE EXISTS (
                      SELECT DISTINCT 1
                      FROM CLIENT
                      WHERE id_client = ORDER_NAME.id_client
                  )
              ) R1
                  NATURAL JOIN MAINTENANCE
     ) R2;

-- 10. Clients which have decided to build solar station on panels, supplied by Doyle LLC of type Zontrax
-- RA client[id_client=order_name.id_client>order_name*>solar_panels(supplier='Doyle LLC')<*solar_panels_type(name='Zontrax')
-- SQL:
SELECT DISTINCT id_solar_panels,
                id_solar_panels_type,
                supplier
FROM (
         SELECT DISTINCT id_solar_panels,
                         id_solar_panels_type,
                         supplier
         FROM (
                  SELECT DISTINCT *
                  FROM SOLAR_PANELS
                  WHERE supplier = 'Doyle LLC'
              ) R1
                  NATURAL JOIN (
             SELECT DISTINCT *
             FROM ORDER_NAME
             WHERE EXISTS (
                 SELECT DISTINCT 1
                 FROM CLIENT
                 WHERE id_client = ORDER_NAME.id_client
             )
         ) R2
     ) R3
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM SOLAR_PANELS_TYPE
    WHERE name = 'Zontrax'
) R4;

-- 11. Select id of all panels by supplier 'Doyle LLC' and of type 'Zontrax'
-- RA {solar_panels(supplier='Doyle LLC')[solar_panels.id_solar_panels_type=solar_panels_type.id_solar_panels_type]solar_panels_type(name='Zontrax')}[id_solar_panels]
-- SQL:
SELECT DISTINCT id_solar_panels
FROM (
         SELECT DISTINCT R1.id_solar_panels,
                         R1.id_solar_panels_type,
                         R1.supplier,
                         R2.id_solar_panels_type AS id_solar_panels_type_1,
                         R2.name
         FROM (
                  SELECT DISTINCT *
                  FROM SOLAR_PANELS
                  WHERE supplier = 'Doyle LLC'
              ) R1
                  JOIN (
             SELECT DISTINCT *
             FROM SOLAR_PANELS_TYPE
             WHERE name = 'Zontrax'
         ) R2 ON R1.id_solar_panels_type = R2.id_solar_panels_type
     ) R3;

-- 12. Select all clients which live in Slovenia
-- RA {<!-- -->{client*address[address.id_country=country.id_country]country}(country.name='Slovenia')}
-- SQL:
SELECT DISTINCT *
FROM (
         SELECT DISTINCT id_address,
                         CLIENT.id_client,
                         CLIENT.name,
                         CLIENT.phone_number,
                         CLIENT.email,
                         CLIENT.additional_information,
                         ADDRESS.id_country,
                         ADDRESS.street,
                         ADDRESS.street_number,
                         ADDRESS.town,
                         COUNTRY.id_country AS id_country_1,
                         COUNTRY.name AS name_1
         FROM CLIENT
                  NATURAL JOIN ADDRESS
                  JOIN COUNTRY ON ADDRESS.id_country = COUNTRY.id_country
     ) R1
WHERE R1.name_1 = 'Slovenia';

-- 13. Clients who have ordered all types of maintenance
-- RA {maintenance}[id_maintenance] \ {<!-- -->{employee*>order_name_employee[id_employee,id_order_name]÷order_name[id_order_name]}*order_name[order_name.id_maintenance=maintenance.id_maintenance>maintenance}[id_maintenance]
-- SQL:
SELECT DISTINCT id_maintenance
FROM MAINTENANCE
EXCEPT
SELECT DISTINCT id_maintenance
FROM MAINTENANCE MAINTENANCE1
WHERE EXISTS (
    SELECT DISTINCT 1
    FROM (
             SELECT DISTINCT id_employee
             FROM (
                      SELECT DISTINCT id_employee,
                                      id_order_name
                      FROM (
                               SELECT DISTINCT id_employee,
                                               id_order_name
                               FROM ORDER_NAME_EMPLOYEE
                           ) R1
                               NATURAL JOIN EMPLOYEE
                  ) R2
             EXCEPT
             SELECT DISTINCT id_employee
             FROM (
                      SELECT DISTINCT *
                      FROM (
                               SELECT DISTINCT id_employee
                               FROM (
                                        SELECT DISTINCT id_employee,
                                                        id_order_name
                                        FROM (
                                                 SELECT DISTINCT id_employee,
                                                                 id_order_name
                                                 FROM ORDER_NAME_EMPLOYEE
                                             ) R1
                                                 NATURAL JOIN EMPLOYEE
                                    ) R2
                           ) R3
                               CROSS JOIN (
                          SELECT DISTINCT id_order_name
                          FROM ORDER_NAME
                      ) R4
                      EXCEPT
                      SELECT DISTINCT id_employee,
                                      id_order_name
                      FROM (
                               SELECT DISTINCT id_employee,
                                               id_order_name
                               FROM ORDER_NAME_EMPLOYEE
                           ) R1
                               NATURAL JOIN EMPLOYEE
                  ) R5
         ) R6
             NATURAL JOIN ORDER_NAME ORDER_NAME1
    WHERE ORDER_NAME1.id_maintenance = MAINTENANCE1.id_maintenance
);

-- 14. Id of all clients, who have ordered all types of maintenance
-- RA client[client.id_client=order_name.id_client>order_name[id_client,id_maintenance]÷order_name[id_maintenance]
-- SQL:
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT id_client,
                         id_maintenance
         FROM ORDER_NAME
     ) R1
WHERE EXISTS (
    SELECT DISTINCT 1
    FROM CLIENT
    WHERE CLIENT.id_client = R1.id_client
)
EXCEPT
SELECT DISTINCT id_client
FROM (
         SELECT DISTINCT *
         FROM (
                  SELECT DISTINCT id_client
                  FROM (
                           SELECT DISTINCT id_client,
                                           id_maintenance
                           FROM ORDER_NAME
                       ) R1
                  WHERE EXISTS (
                      SELECT DISTINCT 1
                      FROM CLIENT
                      WHERE CLIENT.id_client = R1.id_client
                  )
              ) R2
                  CROSS JOIN (
             SELECT DISTINCT id_maintenance
             FROM ORDER_NAME ORDER_NAME1
         ) R3
         EXCEPT
         SELECT DISTINCT *
         FROM (
                  SELECT DISTINCT id_client,
                                  id_maintenance
                  FROM ORDER_NAME
              ) R1
         WHERE EXISTS (
             SELECT DISTINCT 1
             FROM CLIENT
             WHERE CLIENT.id_client = R1.id_client
         )
     ) R4;

-- 15. Select all clients and all orders, including the information whether the client have made any orders
-- SQL:
SELECT client.name, order_name.id_order_name
FROM client
         FULL OUTER JOIN order_name ON client.id_client=order_name.id_client
ORDER BY client.name;

-- 16. Select names and of all clients, who have placed at least one order
-- SQL:
SELECT client.name, order_name.id_order_name
FROM client
         RIGHT OUTER JOIN order_name ON client.id_client=order_name.id_client
ORDER BY client.name;

-- 17. Select total price of all orders as 'total' for every client
-- SQL:
SELECT client.id_client,
       (SELECT SUM(total_price)
        FROM order_name
        WHERE client.id_client = order_name.id_client)
           AS total
FROM client

-- 18. Select all names of the clients
-- SQL:
SELECT name FROM client
GROUP BY name;

-- 19.  Select all clients with id_client > 30, select total amount they have spend on orders and then sort them by their 'total'
-- SQL:
SELECT client.id_client,
       (SELECT SUM(total_price)
        FROM order_name
        WHERE client.id_client = order_name.id_client)
           AS total
FROM client
GROUP BY id_client
HAVING  id_client>30
ORDER BY total

-- 20.  Create a view, which selects all customers from Brazil
-- SQL:
CREATE OR REPLACE VIEW managerr AS
select * from employee e where name='Munmro' and exists(select 1 from manager m where e.id_employee=m.id_employee )
;
--let's check
select * from managerr;

-- 21.  Select all managers using 3 different sql queries
-- SQL:
select distinct e.* from employee e join manager ma on e.id_employee = ma.id_employee
order by name asc, surname desc;
--or with exists
select distinct * from employee e where exists(select * from manager ma where e.id_employee = ma.id_employee)
order by name asc, surname desc;
--or with in
select distinct * from employee e where e.id_employee in (select id_employee from manager)
order by name asc, surname desc;

-- 22. Select id_employee of the manager from the view Manager
--SQL:
select id_employee from employee e where exists (select 1 from managerr m where m.id_employee=e.id_employee);

-- 23.  Delete employee with the corresponding id_employee from the view 'manager'
-- SQL:
begin;
--check if query even returns some value, so there will be something to delete
select count(id_employee) from managerr;
--let's delete it by using in
delete from employee where id_employee in(select id_employee from managerr);
--let's check if we did delete it
select count(id_employee) from managerr;
--return to the previous state
rollback;

-- 24.  Change name of the clients to 'bought_Zontrax', who have decided to build solar station using panels of type 'Zontrax'
-- SQL:
begin;
--what data we will change
select cl.id_client,cl.name, phone_number
from client cl join order_name ord using(id_client) join solar_panels sp on ord.id_solar_panels = sp.id_solar_panels join solar_panels_type spt on sp.id_solar_panels_type = spt.id_solar_panels_type
where spt.name='Zontrax';
--update the value
update client
set name='bought_Zontrax'
where id_client in(
    select ord.id_client
    from order_name ord  join solar_panels sp on ord.id_solar_panels = sp.id_solar_panels join solar_panels_type spt on sp.id_solar_panels_type = spt.id_solar_panels_type
    where spt.name='Zontrax'
);
--check how we changed it
select cl.id_client,cl.name, phone_number
from client cl join order_name ord using(id_client) join solar_panels sp on ord.id_solar_panels = sp.id_solar_panels join solar_panels_type spt on sp.id_solar_panels_type = spt.id_solar_panels_type
where spt.name='Zontrax';
rollback;

-- 25.  Insert randomly generated to the employees, with 'Random_name' as name, 'Random_surname' as surname and random salary
-- SQL:
begin;
--check count
select count(*) from employee;
--lets make an insert
insert into employee (id_employee, id_address, name, surname, salary)
select id_employee, id_address, name, surname, salary from(
                                                              select id_employee*1000 as id_employee, id_address, 'Random_name' as name, 'Random_surname' as surname, round(random()*10000)+1 as salary
                                                              from manager cross join address
                                                          ) vstup order by random() limit 5;
--check count after inserting
select count(*) from employee;
--reset
rollback;


