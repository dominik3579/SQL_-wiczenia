--------------------------------------------------------------------------------------------------------------------------------
                                                    *****£¥CZENIE TABEL*****
--------------------------------------------------------------------------------------------------------------------------------
--P.1 Zlaczenie wewnetrzne z wykorzystaniem klauzuli ON
SELECT
    e.first_name,
    e.last_name,
    d.department_name
FROM
    HR.employees e
INNER JOIN HR.departments d ON e.department_id = d.department_id;
--P.2 Zlaczenie wewnetrzne z wykorzystaniem klauzuli USING
SELECT
    e.first_name,
    e.last_name,
    d.department_name
FROM
    HR.employees e
INNER JOIN HR.departments d USING ( department_id );

--P.3 Z³¹czenie wiêcej ni¿ 2 tabel
SELECT
    j.job_title,
    d.department_name,
    e.first_name || ' ' || e.last_name AS employee_name,
    jh.start_date
FROM
    HR.job_history jh
    JOIN HR.jobs j USING ( job_id )
    JOIN HR.departments d ON jh.department_id = d.department_id
    JOIN HR.employees e ON jh.employee_id = e.employee_id;
--P.4
SELECT
    d.department_name,
    l.city,
    c.country_name
FROM
    HR.departments d
    right OUTER JOIN HR.locations l ON d.location_id = l.location_id
    right OUTER JOIN HR.countries c ON l.country_id = c.country_id
WHERE 
    department_name is null and city is not null;
--P.5
SELECT
    w.employee_id AS worker_id,
    w.first_name AS worker_first_name,
    w.last_name AS worker_last_name,
    w.salary AS worker_salary,
    d.department_name,
    m.employee_id AS manager_id,
    m.first_name AS manager_first_name,
    m.last_name AS manager_last_name,
    m.salary AS manager_salary
FROM
    HR.employees w
    LEFT JOIN HR.departments d ON d.department_id = w.department_id
    LEFT OUTER JOIN HR.employees m ON m.employee_id = w.manager_id
ORDER BY
    manager_first_name,
    manager_last_name,
    worker_first_name,
    worker_last_name;


--------------------------------------------------------------------------------------------------------------------------------
                                                    *****PODZAPYTANIA*****
                                                      ^^JEDNOWIERSZOWE^^
--------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie jednowierszowe musi zwracaæ jeden rekord wynikowy, przyklad wykorzystania w klauzuli WHERE:
SELECT
	first_name, 
	last_name 
FROM 
	HR.employees
WHERE
	salary>=(
            SELECT 
                salary 
            FROM 
                HR.employees
            WHERE
                employee_id = 163
            );
-- U¿ycie podzayptania w klauzuli HAVING:
SELECT
	d.department_name,
	SUM (salary)
FROM
	HR.employees e
	JOIN HR.departments d ON e.department_id = d.department_id
GROUP BY 
	d.department_name
HAVING
	COUNT (*)>=
				(SELECT COUNT (*)
				FROM
                    HR.employees e
				JOIN
                    HR.departments d ON e.department_id=d.department_id
				WHERE
                    lower (d.department_name) LIKE 'it'
				);

--------------------------------------------------------------------------------------------------------------------------------
                                                    *****PODZAPYTANIA*****
                                                      ^^WIELOWIERSZOWE^^
--------------------------------------------------------------------------------------------------------------------------------
--U¿awamy do nich operatora logicznego [>, <, >=,<=] + slowo kluczowe ALL, ANY, IN;
--All warunek musi zostaæ spelniony dla kazdego elementu w zwroconej tablicy;
--Any, In warunek musi zostaæ speniony dla któregokolwiek elementu w zwróconej tablicy

--P.1
--Operator IN mo¿e porównywaæ równie¿ pary wartoœci 
SELECT
    *
FROM
    hr.employees
WHERE (job_id, department_id) IN
                                (
                                SELECT
                                    job_id,
                                    department_id
                                FROM
                                    HR.job_history
                                );
--P.2
SELECT
    *
FROM
    HR.employees
WHERE job_id IN(      
                SELECT
                    job_id
                FROM
                    hr.jobs
                WHERE max_salary - min_salary = 
                             (
                              SELECT
                                min(max_salary - min_salary)
                              FROM
                                hr.jobs
                              )
          );
    
--------------------------------------------------------------------------------------------------------------------------------
                                                    *****OPERATORY ZBIOROWE*****                                                
--------------------------------------------------------------------------------------------------------------------------------
--Mamy dawa zapytania, których wyniki stanowia dwa zbiory, mozemy wykoniac na nich nastepujace operacje:
-- UNION ALL - suma zbiorow z duplikatami (dolacz, cale drugie zapytanie)
-- UNION - suma zbiorow bez duplikatow (dolacz tylko te rekordy z drugiego zapytania, ktore nie znajduja sie w pierwszym)
-- MINUS - roznica
-- INTERSECT - czesc wspolna
-- Musi byc ta sama liczba kolumn
-- Typy danych w laczonych polach musza byc takie same !!!

--P.1
SELECT
    city,
    street
FROM
    customers
WHERE
    country = 'Poland'

UNION ALL

SELECT
    city_name,
    street_name
FROM
    suppliers
WHERE
    country = 'Poland'
    
ORDER BY
    city; 

--P.2
SELECT
    to_char(department_id,'999999') AS ID_Stanowiska,
    min(salary)AS Min_Salary,
    max(salary)AS Max_Salary
FROM
    HR.employees
GROUP BY
    department_id
UNION ALL
SELECT
    job_id,
    min_salary,
    max_salary
FROM
    hr.jobs
ORDER BY
    1,2,3;

--P.3
SELECT
    ROUND(AVG(salary),2)AS Wynik,
    'Srednia_Wszystkich_Pracownikow' AS Opis
FROM
    hr.employees
UNION ALL
SELECT
    AVG(salary),
    'Œrednia_Na_Stanowisku_SA_REP'
FROM
    HR.employees
WHERE
    job_id = 'SA_REP'



