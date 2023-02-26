--------------------------------------------------------------------------------------------------------------------------------
                    --Tworzenie tabeli regions_train na podstawie już istniejacej tabeli regions--
--------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE regions_train AS
SELECT
    *
FROM
    hr.regions;
--------------------------------------------------------------------------------------------------------------------------------            
                        --Tworzenie tabeli jobs_train na podstawie juz istniejacej tabeli jobs--
--------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE jobs_train AS
SELECT
    *
FROM
    hr.jobs;

--------------------------------------------------------------------------------------------------------------------------------            
                                            --Dodwanie nowych rekordów do tabeli--
--------------------------------------------------------------------------------------------------------------------------------

INSERT INTO regions_train VALUES (
                                    5,
                                    'Australia'
                                 );
--------------------------------------------------------------------------------------------------------------------------------     
                                                --Tworzenie Synonimu dla tabeli--
--------------------------------------------------------------------------------------------------------------------------------     
CREATE SYNONYM regiony FOR regions_train;

CREATE SYNONYM praca FOR jobs_train;

SELECT
    *
FROM
    regiony;
--------------------------------------------------------------------------------------------------------------------------------
                    --Dodwania danych do tabeli z wykorzystaniem automatycznej sekwencji--
                    --Utworzenie sekwencji jest pierwszym krokiem (jest ona widoczna w zakladce Sequences)--
--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE samochody_seq MINVALUE 1 MAXVALUE 1000000 START WITH 1 INCREMENT BY 1;

--------------------------------------------------------------------------------------------------------------------------------
                            --Dodawanie rekordow z wykorzystaniem sekwencji na polu ID--; 
--------------------------------------------------------------------------------------------------------------------------------
INSERT INTO samochody VALUES (
                                samochody_seq.NEXTVAL,
                                'Volvo',
                                'S40',
                                'czarny',
                                '3D876789',
                                'GLR8721',
                                133000
                             );

INSERT INTO samochody VALUES (
                                samochody_seq.NEXTVAL,
                                'Renult',
                                'Megan',
                                'Niebieski',
                                '12AAA3232',
                                'GKA1312',
                                15000
                             );

INSERT INTO samochody VALUES (
                                samochody_seq.NEXTVAL,
                                'Ford',
                                'Focus',
                                'Zielony',
                                'XXX123AAA13AAA44',
                                'GWE1232',
                                232000
                                );
--------------------------------------------------------------------------------------------------------------------------------
                                            --Aktualizowanie danych w tabelach--
--------------------------------------------------------------------------------------------------------------------------------
UPDATE praca
SET
    min_salary = 4500
WHERE
    job_title = 'Programmer';

UPDATE regions_train
SET
    region_name = 'Australia and Oceania'
WHERE
    region_name = 'Australia';
--------------------------------------------------------------------------------------------------------------------------------
                                                    --Usuwanie danych z tabeli--
--------------------------------------------------------------------------------------------------------------------------------
DELETE FROM praca
WHERE
    min_salary BETWEEN 3000 AND 6000;
--------------------------------------------------------------------------------------------------------------------------------
                                                    --Konstrukcja CASE--
--------------------------------------------------------------------------------------------------------------------------------
SELECT
    *
FROM
    (
        SELECT
            last_name,
            salary,
            department_id,
            job_id,
            CASE
                WHEN commission_pct IS NULL THEN 'false'
                WHEN commission_pct IS NOT NULL THEN 'true'
            END posiada_prowizje
        FROM
            hr.employees
    )
WHERE
    posiada_prowizje = 'true';

SELECT
    first_name,
    last_name,
    CASE
        WHEN salary < 3000 THEN 'Ponizej 3k'
        WHEN salary >= 3000 AND salary <= 6000 THEN '3k-6k'
        WHEN salary >= 6000 AND salary <= 9000 THEN '6k-9k'
        WHEN salary > 9000 THEN 'Powyzej 9k'
    END AS Poziom_zarobkow,
    salary
FROM
    hr.employees
ORDER BY
    salary DESC;
--------------------------------------------------------------------------------------------------------------------------------    
                                                            --Funkcje dat--
--------------------------------------------------------------------------------------------------------------------------------
SELECT
    TO_CHAR(SYSDATE, 'DD-MM-YYYY')
    || ','
    || upper(TO_CHAR(SYSDATE, 'Day')) AS data_01,
    TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS') AS data_02,
    TO_CHAR(SYSDATE, 'YYYY-MON-DD')
    || ' '
    || TRIM(upper(TO_CHAR(SYSDATE, 'Day')))
    || ','
    || TO_CHAR(SYSDATE, 'HH24:MI:SS') AS data_03,
    TO_CHAR(SYSDATE, 'Q')
    || ' kwartal '
    || TO_CHAR(SYSDATE, 'YYYY') AS data_04
FROM
    dual;

SELECT
    TO_CHAR(last_day(TO_DATE('01-02-2100', 'DD-MM-YYYY')), 'DD') AS luty_2100
FROM
    dual;

SELECT
    TO_CHAR(round(add_months(SYSDATE, 150), 'MM'), 'DD-MM-YYYY') AS data_za_150_msc
FROM
    dual;

SELECT
    trunc(months_between(SYSDATE, TO_DATE('01-01-2000', 'DD-MM-YYYY'))) AS data
FROM
    dual;

SELECT
    first_name AS imie,
    last_name AS nazwisko,
    round(months_between(DATE '2009-01-01', emp.hire_date)) AS staz_pracy_msc,
    CASE
        WHEN round(months_between(DATE '2009-01-01', emp.hire_date)) < 13 THEN 'Junior'
        WHEN round(months_between(DATE '2009-01-01', emp.hire_date)) >= 13 AND round(months_between(DATE '2009-01-01', hire_date)) <= 40 THEN 'Regular'
        WHEN round(months_between(DATE '2009-01-01', emp.hire_date)) > 40 THEN 'Senior'
    END AS Staz
FROM
    hr.employees emp
ORDER BY
    staz DESC;
--------------------------------------------------------------------------------------------------------------------------------    
                                            --Rok, miesiac, dzien jako osobne kolumny--
--------------------------------------------------------------------------------------------------------------------------------
--P.1 z wykorzystaniem to_char
SELECT
    hire_date,
    to_char(hire_date,'YYYY') AS Rok,
    to_char(hire_date,'MM') AS Miesiac,
    to_char(hire_date,'DD') AS Dzien
FROM
    HR.employees;

--P.2 z wykorzystaniem funkcji extract
SELECT
    hire_date,
    EXTRACT(YEAR FROM hire_date) AS Rok,
    EXTRACT(MONTH FROM hire_date) AS Miesiac,
    EXTRACT(DAY FROM hire_date) AS Dzien
FROM
    HR.employees;

--------------------------------------------------------------------------------------------------------------------------------
                                                            --Funkcje znakowe--
--------------------------------------------------------------------------------------------------------------------------------
--P.1 Wyswietl wielkimi literami dwie pierwsze litery imienia pracownika
SELECT
    first_name,
    SUBSTR(UPPER(first_name),1,2) AS dwie_pierwsze_litery
FROM
    hr.employees;

--P.2 Wyswietl inicialy 

SELECT
    first_name,
    last_name,
    SUBSTR(first_name,1,1)|| SUBSTR(last_name,1,1)AS Inicialy
FROM
    hr.employees;

-- P.3 Dlugosc Imienia i nazwiska 
SELECT
    first_name || last_name,
    LENGTH(first_name || last_name) AS Dlugosc_znakow
FROM
    hr.employees
ORDER BY
    Dlugosc_znakow DESC;
    
--P.4
SELECT
    to_char(129.111,'999D999L')AS Symbol_Waluty
FROM
    Dual;

--Zadanie Wyswietl imie, nazwisko i roczne zarobki pracownikow uzwgledniajac, ze
--pracownicy dzialu o ID 80 otrzymuje premie roczna w wysokosci 5000, a dzialu o ID 50
--premie roczna w wysokosci 3000.
--Wynik przestaw wedlug formatu 288 000PLN.

SELECT
    first_name,
    last_name,
    TO_CHAR(
    CASE
        WHEN department_id ='80'THEN (salary*12)+5000
        WHEN department_id ='50'THEN (salary*12)+3000
        ELSE salary*12
    END,'999G999C') Pensja_Roczna
FROM
    hr.employees 
ORDER BY
    Pensja_Roczna DESC;

