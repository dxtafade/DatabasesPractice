--PART 1
--Task 1.1
SELECT first_name || ' ' || last_name AS full_name,
       department,
       salary
FROM employees;

--Task 1.2
SELECT DISTINCT department
FROM employees;

--Task 1.3
SELECT project_name,
       budget,
       CASE
           WHEN budget > 150000 THEN 'Large'
           WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
           ELSE 'Small'
END AS budget_category
FROM projects;

--Task 1.4
SELECT first_name,
       COALESCE(email, 'No email provided') as email
FROM employees;


--PART 2
--Task 2.1
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
WHERE hire_date > '2020-01-01';

--Task 2.2
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
WHERE salary BETWEEN 60000 and 70000;

--Task 2.3
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

--Task 2.4
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees

EXCEPT

SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
WHERE manager_id IS NULL


--PART 3
--Task 3.1
SELECT UPPER(first_name),
       LENGTH(last_name),
       SUBSTRING(email, 1, 3) as email
FROM employees;

--Task 3.2
SELECT first_name,
       salary AS annual_salary,
       ROUND(salary / 12, 2) AS monthly_salary,
       salary * 0.10 AS raise
FROM employees;

--Task 3.3
SELECT FORMAT(
       'Project: %s - Budget $%s - Status: %s',
       project_name,
       budget,
       status
       )
FROM projects;

--Task 3.4
SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_worked
FROM employees;


--PART 4
--Task 4.1
SELECT department,
       AVG(salary)
FROM employees
GROUP BY department;

--Task 4.2
SELECT p.project_name,
       SUM(a.hours_worked) AS total_hours
FROM projects p
JOIN assignments a
    ON p.project_id = a.project_id
GROUP BY p.project_name;

--Task 4.3
SELECT COUNT(*),
       department
FROM employees
GROUP BY department
HAVING COUNT(*)>1

--Task 4.4
SELECT MAX(salary) AS maximum_salary,
       MIN(salary) AS minimum_salary,
       SUM(salary) AS total_payroll
FROM employees


--PART 5
--Task 5.1
SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE salary >  65000

UNION

SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE hire_date > '2020-01-01'

--Task 5.2
SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE salary >  65000

INTERSECT

SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE department = 'IT'

--Task 5.3
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
EXCEPT
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
WHERE employee_id IN (SELECT employee_id
                      FROM assignments)

-- PART 6
-- Task 6.1
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
);


-- Task 6.2
SELECT employee_id,
       first_name || ' ' || last_name AS full_name
FROM employees
WHERE employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    JOIN projects p
        ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);


-- Task 6.3
SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);



-- PART 7
-- Task 7.1
SELECT e.first_name || ' ' || e.last_name AS full_name,
       e.department,
       AVG(a.hours_worked) AS average_hours,
       RANK() OVER (
           PARTITION BY e.department
           ORDER BY e.salary DESC
       ) AS salary_rank
FROM employees e
LEFT JOIN assignments a
    ON e.employee_id = a.employee_id
GROUP BY e.employee_id,
         e.first_name,
         e.last_name,
         e.department,
         e.salary;


-- Task 7.2
SELECT p.project_name,
       SUM(a.hours_worked) AS total_hours,
       COUNT(DISTINCT a.employee_id) AS number_of_employees
FROM projects p
JOIN assignments a
    ON p.project_id = a.project_id
GROUP BY p.project_id,
         p.project_name
HAVING SUM(a.hours_worked) > 150;


-- Task 7.3
SELECT e.department,
       COUNT(*) AS total_employees,
       AVG(e.salary) AS average_salary,

       (
           SELECT e2.first_name || ' ' || e2.last_name
           FROM employees e2
           WHERE e2.department = e.department
           ORDER BY e2.salary DESC
           LIMIT 1
       ) AS highest_paid_employee,

       GREATEST(MAX(e.salary), AVG(e.salary)) AS greatest_salary_value,
       LEAST(MIN(e.salary), AVG(e.salary)) AS least_salary_value

FROM employees e
GROUP BY e.department;