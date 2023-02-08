SELECT
    *
FROM
    hr.employees     e
    JOIN hr.departments   d USING ( department_id )
WHERE
    d.department_name = 'Sales';
--
--Z.14.3

SELECT
    *
FROM
    hr.employees
WHERE
    salary > (
        SELECT
            min_salary
        FROM
            hr.jobs
        WHERE
            job_title = 'Programmer'
    );
-- podzapytanie musi byæ ujête w nawiasach !!!!
--Zad.14.4

SELECT
    *
FROM
    hr.employees
WHERE
    salary > (
        SELECT
            AVG(min_salary)
        FROM
            hr.jobs
    )
ORDER BY
    salary DESC;
                 
--P.14.2

SELECT
    d.department_name,
    SUM(e.salary)
FROM
    hr.employees     e
    JOIN hr.departments   d USING ( department_id )
GROUP BY
    d.department_name
HAVING
    COUNT(*) > (
        SELECT
            COUNT(*)
        FROM
            hr.employees
            JOIN hr.departments d USING ( department_id )
        WHERE
            d.department_name = 'IT'
    );

--Zad.14.5
-- gdy u¿ywamy USING przy laczeniu tabel nie uzywamy odnosnika do TABEL d.department_id - poniewa¿ traktuje on je jako jedna tabele, 
-- w przypadku u¿ycia ON -stosujemy odwolanie do tabeli

SELECT
    department_id,
    d.department_name,
    COUNT(*),
    SUM(e.salary)
FROM
    hr.employees     e
    JOIN hr.departments   d USING ( department_id )
GROUP BY
    department_id,
    d.department_name
HAVING
    COUNT(*) > (
        SELECT
            AVG(COUNT(*))
        FROM
            hr.employees     e
            JOIN hr.departments   d USING ( department_id )
        GROUP BY
            department_id
    );
--Zad.14.7

SELECT
    *
FROM
    hr.employees
WHERE
    ( job_id,
      department_id ) IN (
        SELECT
            job_id,
            department_id
        FROM
            hr.job_history
    );

--Zad.14.8

SELECT
    * --zwróæ mi wszystkie dane pracowników
FROM
    hr.employees
WHERE
    job_id = ANY (
        SELECT
            job_id -- których job_id  w którym rozpiêtoœæ plac
        FROM
            hr.jobs
        WHERE
            max_salary - min_salary = 
                                                            -- równa siê najmniejszej rozpiêtoœci plac
             (
                SELECT
                    MIN(max_salary - min_salary) - jest najmniejsza
                FROM
                    hr.jobs
            )
    );

--Zad.15.1
-- zadanie na dolaczanie

SELECT
    job_id,
    MIN(salary),
    MAX(salary)
FROM
    hr.employees
GROUP BY
    job_id
UNION ALL
SELECT
    job_id,
    min_salary,
    max_salary
FROM
    hr.jobs;
-- ROLLUP - sumy czêœæiowe wierszy

SELECT
    c.cust_first_name,
    c.cust_last_name,
    SUM(s.amount_sold)
FROM
    sh.sales       s
    JOIN sh.customers   c USING ( cust_id )
WHERE
    c.cust_first_name IN (
        'Adele',
        'Grace'
    )
GROUP BY
    ROLLUP(cust_first_name,
           cust_last_name)
ORDER BY
    1,
    2; 
--Zad.16.2

SELECT
    prod_category,
    prod_name,
    SUM(s.amount_sold)
FROM
    sh.products   p
    JOIN sh.sales s USING ( prod_id )
WHERE
    p.prod_category IN (
        'Photo',
        'Electronics',
        'Hardware'
    )
GROUP BY
    ROLLUP(prod_category,
           prod_name)
ORDER BY
    1,
    2,
    3;
--Zad.16.3
SELECT
prod_category as  Kategoria, 
count(*) as Liczba_Produktow
FROM
SH.products
GROUP BY ROLLUP
(prod_category)
ORDER BY 2 ;

--Zad.16.4
SELECT

FROM
sh.sales s 
JOIN SH.products;


-------------------------------------------------------FUNKCJE ANALITYCZNE------------------------------------------------------
SELECT
prod_name,
SUM(amount_sold),
rank () over(order by SUM(amount_sold)desc)
FROM
sh.sales s JOIN sh.products p USING (prod_id)
GROUP BY prod_name;

---Przyklad 02 z wykorzystaniem partiton by - kazda grupa ma swoj osobny ranking
SELECT
prod_category,
prod_name,
SUM(amount_sold),
rank () over(partition by prod_category order by SUM(amount_sold)desc)
FROM
sh.sales s JOIN sh.products p USING (prod_id)
GROUP BY prod_category, prod_name;

Zad.17.1
SELECT
first_name as Imie,
last_name as Nazwisko,
salary as Pensja,
rank() over(order by salary desc)as Ranking
FROM
HR.employees
Order by Ranking;
--Zad.17.2
SELECT
first_name as Imie,
last_name as Nazwisko,
department_id as Dzial,
salary as Pensja,
rank()over(partition by department_id  order by salary desc)as Ranking
FROM
HR.employees
ORDER BY department_id;
------------------------------------------------FUNKCJE RAPORTUJ¥CE-------------------------------------------------------------
SELECT
    prod_category AS kat,
    prod_name AS prod, 
    SUM(amount_sold) AS  sprzed,
    SUM(SUM(amount_sold)) OVER (PARTITION BY prod_category)as sprzed_kat -- sumujemy sprzeda¿ dla calej kategorii, dlatego jest suma z sumy
FROM
    sh.products
    JOIN sh.sales USING (prod_id)
GROUP BY
    prod_name,
    prod_category;
--Zad.17.8
SELECT *
FROM
    (SELECT
        p.prod_category,
        cou.country_region,
        SUM(s.amount_sold) as sprzed_kat,
        MAX(SUM(s.amount_sold)) OVER (PARTITION BY p.prod_category) as max_sprz
    FROM
        sh.sales s
        JOIN sh.products p USING (prod_id)
        JOIN sh.customers cust USING (cust_id)--laczymy sie z tabela posrednia 
        JOIN sh.countries cou USING (country_id)
    WHERE
    s.time_id ='2000/12/24'
    GROUP BY
    p.prod_category,
    cou.country_region)
WHERE sprzed_kat = max_sprz;
 --------------------------------------------------LISTAGG----------------------------------------------------------------------
 SELECT
    department_id,
    LISTAGG(last_name, ',')WITHIN GROUP (ORDER BY last_name)
FROM
    hr.employees
GROUP BY
    department_id;
Zad.17.11
SELECT
    job_title AS Stanowisko, -- po sredniku wypisujemy wszystkie nazwiska znajdujace sie w grupie (job_title)
    LISTAGG(emp.last_name,';')WITHIN GROUP (ORDER BY last_name) AS Nazwiska_Pracownikow
FROM
    hr.employees emp 
    JOIN HR.jobs j using(job_id)
GROUP BY
job_title;
--------------------------------------------------------LAG/LEAD----------------------------------------------------------------------------------
SELECT
    t.calendar_month_number,
    SUM(s.amount_sold) AS month_amount,
    lag(SUM(s.amount_sold),1,0) over (order by t.calendar_month_number) as abc,
    lead(SUM(s.amount_sold),1,0) over (order by t.calendar_month_number)
FROM
    SH.sales s
    JOIN SH.times t ON s.time_id = t.time_id
WHERE
    t.calendar_year = 2000
GROUP BY
    t.calendar_month_number
ORDER BY
    t.calendar_month_number;

-----
SELECT
        to_char(time_id,'DD-MM-YYYY'),
        sum(amount_sold) as Sprzedaz,
        lag(sum(amount_sold),1,0) over (order by time_id) as Dzien_wstecz,
        sum(amount_sold)-lag(sum(amount_sold),1,0) over (order by time_id) as Roznica
FROM
        sh.sales
WHERE
        time_id between '2001-01-01' and '2001-03-31'

GROUP BY
        time_id
ORDER BY
        time_id;

-- Zad.1_Prezentacja_06
SELECT
c.nls_territory as Kraj,
sum(o.order_total) as Sprzedaz
FROM
    oe.orders o 
    JOIN oe.customers c USING (customer_id)
WHERE
    o.order_status IN(2,3,4,5)
GROUP BY
c.nls_territory
ORDER BY
Sprzedaz desc; 
--Zad.3
SELECT
    trunc(last_day(order_date)),
    SUM(case when order_mode = 'direct'then order_total end) Direct, 
    SUM(case when order_mode = 'online' then order_total end )Online_,
    round (sum(case when order_mode = 'online' then order_total end )/sum(order_total),2)
FROM
    oe.orders
GROUP BY
trunc(last_day(order_date));


