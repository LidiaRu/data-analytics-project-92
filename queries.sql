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