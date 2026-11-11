-- Считает общее количество покупателей
SELECT COUNT(*) AS customers_count
FROM customers;


-- Показывает 10 продавцов с наибольшей суммарной выручкой
SELECT CONCAT (e.first_name,' ', e.last_name) AS seller, COUNT(s.sales_id) AS operations, FLOOR(SUM(s.quantity*p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e
ON s.sales_person_id=e.employee_id
INNER JOIN products AS p
ON s.product_id=p.product_id
GROUP BY e.employee_id
ORDER BY income DESC LIMIT 10;


-- Показывает продавцов, чья средняя выручка за сделку ниже средней по компании
SELECT CONCAT (e.first_name,' ', e.last_name) AS seller, FLOOR(AVG(s.quantity*p.price)) AS average_income
FROM sales AS s
INNER JOIN employees AS e
ON s.sales_person_id=e.employee_id
INNER JOIN products AS p
ON s.product_id=p.product_id  
GROUP BY e.employee_id
HAVING AVG(s.quantity*p.price)<(SELECT AVG(s_all.quantity * p_all.price)
FROM sales AS s_all     
INNER JOIN products AS p_all         
ON s_all.product_id = p_all.product_id)
ORDER BY average_income asc;

-- Считает суммарную выручку каждого продавца по дням недели
SELECT CONCAT (e.first_name,' ', e.last_name) AS seller, TO_CHAR(s.sale_date, 'FMday') AS day_of_week, FLOOR(SUM(s.quantity*p.price)) AS income  
FROM sales AS s
INNER JOIN employees AS e
ON s.sales_person_id=e.employee_id
INNER JOIN  products AS p
ON s.product_id=p.product_id
GROUP BY e.employee_id, TO_CHAR(s.sale_date, 'FMday'), EXTRACT(ISODOW FROM s.sale_date)
ORDER BY EXTRACT(ISODOW FROM s.sale_date) ASC, seller ASC;

-- Считает количество покупателей в каждой возрастной группе
SELECT CASE
WHEN age between 16 AND 25 THEN '16-25'
WHEN age BETWEEN 26 AND 40 THEN '26-40'
WHEN age>40 THEN '40+'
END AS age_category, COUNT(*) AS age_count
FROM customers
WHERE age>=16 
GROUP BY age_category
ORDER BY age_category asc;

-- Считает количество уникальных покупателей и суммарную выручку за каждый месяц
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month, COUNT(DISTINCT s.customer_id) AS total_customers, FLOOR(SUM(s.quantity*p.price)) AS income  
FROM sales AS s
INNER JOIN products AS p 
ON s.product_id=p.product_id
GROUP BY selling_month 
ORDER BY selling_month ASC;

-- Находит покупателей, чья первая покупка была акционной, и выводит дату покупки и имя продавца
WITH first_sales AS 
(SELECT  s.customer_id, s.sale_date, ROW_NUMBER() OVER (
    PARTITION BY s.customer_id
    ORDER BY s.sale_date, s.sales_id) AS rn,  s.sales_person_id, p.price
FROM sales AS s
INNER JOIN products AS p
ON s.product_id=p.product_id)
SELECT CONCAT (c.first_name,' ', c.last_name) AS customer, first_sales.sale_date, CONCAT (e.first_name,' ', e.last_name) AS seller
FROM first_sales
INNER JOIN customers AS c
ON first_sales.customer_id=c.customer_id
INNER JOIN employees AS e
ON first_sales.sales_person_id=e.employee_id
WHERE rn=1 AND price=0
ORDER BY first_sales.customer_id ASC;
