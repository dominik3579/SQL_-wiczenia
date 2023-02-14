--------------------------------------------------------------------------------------------------------------------------------
                                    *****Łaczenie_Tabel_Funkcje_Analityczne_Ćwiczenia*****
--------------------------------------------------------------------------------------------------------------------------------
--P.1
SELECT
    *
FROM
    hr.employees e
    JOIN hr.departments d USING (department_id)
WHERE
    d.department_name = 'Sales';

--P.2

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
-- Podzapytanie musi być ujęte w nawiasach !!!!

--P.3
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
                 
--P.4

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

--P.5
-- Zlaczenie USING używamy tylko wtedy gdy laczone pola moaja dokladnie taka sama nazwe
-- Zlaczenie ON stosujemy gdy odpowiadajace sobie pola maja rozne nazwy (zalecane 'W razie W')

SELECT
    department_id,
    d.department_name,
    COUNT(*),
    SUM(e.salary)
FROM
    hr.employees e
    JOIN hr.departments d USING (department_id)
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
--P.6

SELECT
    *
FROM
    hr.employees
WHERE
    (job_id, department_id)IN(
                                SELECT
                                    job_id,
                                    department_id
                                FROM
                                    hr.job_history
                              );
--------------------------------------------------------------------------------------------------------------------------------
                                            *****FUNKCJE ANALITYCZNE*****
--------------------------------------------------------------------------------------------------------------------------------
--P.1

SELECT
    prod_category,
    prod_name,
    SUM(s.amount_sold)
FROM
    sh.products   p
    JOIN sh.sales s USING (prod_id)
WHERE
    p.prod_category IN (
                        'Photo',
                        'Electronics',
                        'Hardware'
                        )
GROUP BY
    ROLLUP(prod_category, prod_name)
ORDER BY
    1,
    2,
    3;
    
--P.2
SELECT
    prod_category as  Kategoria, 
    COUNT(*) as Liczba_Produktow
FROM
    SH.products
GROUP BY ROLLUP
    (prod_category)
ORDER BY 
    2;
    
--P.3
SELECT
prod_name,
SUM(amount_sold),
rank () over(order by SUM(amount_sold)desc)
FROM
sh.sales s JOIN sh.products p USING (prod_id)
GROUP BY prod_name;

--P.4 
--z wykorzystaniem partiton by - kazda grupa ma swoj osobny ranking
SELECT
    prod_category,
    prod_name,
    SUM(amount_sold),
    rank () over(partition by prod_category order by SUM(amount_sold)desc)
FROM
    sh.sales s JOIN sh.products p USING (prod_id)
GROUP BY 
    prod_category, prod_name;

--P.5
SELECT
    first_name as Imie,
    last_name as Nazwisko,
    salary as Pensja,
    rank() over(order by salary desc)as Ranking
FROM
    HR.employees
Order by 
    Ranking;
    
--P.6
SELECT
    first_name as Imie,
    last_name as Nazwisko,
    department_id as Dzial,
    salary as Pensja,
    rank()over(partition by department_id  order by salary desc)as Ranking
FROM
    HR.employees
ORDER BY 
    department_id;
--------------------------------------------------------------------------------------------------------------------------------
                                            *****FUNKCJE RAPORTUJĄCE*****
--------------------------------------------------------------------------------------------------------------------------------
--P.1
SELECT
    prod_category AS kat,
    prod_name AS prod, 
    SUM(amount_sold) AS  sprzed,
    SUM(SUM(amount_sold)) OVER (PARTITION BY prod_category)as sprzed_kat -- sumujemy sprzedaż dla calej kategorii, dlatego jest suma z sumy
FROM
    sh.products
    JOIN sh.sales USING (prod_id)
GROUP BY
    prod_name,
    prod_category;
    
--P.2
SELECT 
    *
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
--P.1 
 
 SELECT
    department_id,
    LISTAGG(last_name, ',')WITHIN GROUP (ORDER BY last_name)
FROM
    hr.employees
GROUP BY
    department_id;

--P.2
SELECT
    job_title AS Stanowisko, -- po sredniku wypisujemy wszystkie nazwiska znajdujace sie w grupie (job_title)
    LISTAGG(emp.last_name,';')WITHIN GROUP (ORDER BY last_name) AS Nazwiska_Pracownikow
FROM
    hr.employees emp 
    JOIN HR.jobs j using(job_id)
GROUP BY
    job_title;
--------------------------------------------------------LAG/LEAD----------------------------------------------------------------------------------
--P.1
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

--P.2
SELECT
    to_char(time_id,'DD-MM-YYYY'),
    sum(amount_sold) as Sprzedaz,
    lag(sum(amount_sold),1,0) over (order by time_id) as Dzien_wstecz,
    sum(amount_sold)-lag(sum(amount_sold),1,0) over (order by time_id) as Roznica
FROM
    sh.sales
WHERE
    time_id between DATE'2001-01-01' and DATE'2001-03-31'
GROUP BY
    time_id
ORDER BY
    time_id;

-- P.2
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
    
--P.3
SELECT
    trunc(last_day(order_date)),
    SUM(case when order_mode = 'direct'then order_total end) Direct, 
    SUM(case when order_mode = 'online' then order_total end )Online_,
    round (sum(case when order_mode = 'online' then order_total end )/sum(order_total),2)
FROM
    oe.orders
GROUP BY
    trunc(last_day(order_date));


