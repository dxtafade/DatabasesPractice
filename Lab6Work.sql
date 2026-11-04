CREATE DATABASE Lab6Work;

--PART 1
--Task 1.1
CREATE TABLE employees(
    emp_id INTEGER PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INTEGER,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects(
    project_id INTEGER PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INTEGER,
    budget DECIMAL(10, 2)
);

--Task 1.2
INSERT INTO employees VALUES (1, 'John Smith', 101, 50000);
INSERT INTO employees VALUES (2, 'Jane Doe', 102, 60000);
INSERT INTO employees VALUES (3, 'Mike Johnson', 101, 55000);
INSERT INTO employees VALUES (4, 'Sarah Williams', 103, 65000);
INSERT INTO employees VALUES (5, 'Tom Brown', NULL, 45000);

INSERT INTO departments VALUES (101, 'IT', 'Building A');
INSERT INTO departments VALUES (102, 'HR', 'Building B');
INSERT INTO departments VALUES (103, 'Finance', 'Building C');
INSERT INTO departments VALUES (104, 'Marketing', 'Building D');

INSERT INTO projects VALUES (1, 'Website Redesign', 101, 100000);
INSERT INTO projects VALUES (2, 'Employee Training', 102, 50000);
INSERT INTO projects VALUES (3, 'Budget Analysis', 103, 75000);
INSERT INTO projects VALUES (4, 'Cloud Migration', 101, 150000);
INSERT INTO projects VALUES (5, 'AI Research', NULL, 200000);

--PART 2
--Task 2.1
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

--5 employees x 4 departments = 20 rows.

--Task 2.2
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

--Task 2.3
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;

--PART 3
--Task 3.1
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

--4 rows are returned. Tom Brown has NULL dept_id, so there is no matching department.

--Task 3.2
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING(dept_id);

--The selected columns are the same as in Task 3.1.
--With SELECT *, USING returns dept_id once, while ON returns both dept_id columns.

--Task 3.3
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

--Task 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

--PART 4
--Task 4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

--Tom Brown is included with NULL values for emp_dept, dept_dept, and dept_name.

--Task 4.2
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d USING(dept_id);

--Task 4.3
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

--Task 4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

--PART 5
--Task 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

--Task 5.2
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

--Task 5.3
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--PART 6
--Task 6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

--Marketing has NULL employee columns because it has no employees.
--Tom Brown has NULL department columns because he has no department.

--Task 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

--Task 6.3
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--PART 7
--Task 7.1
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

--Task 7.2
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--Task 7.1 returns all 5 employees, matching only departments in Building A.
--Other employees have NULL dept_name because the ON condition finds no match.
--Task 7.2 returns only John Smith and Mike Johnson.
--WHERE removes rows where the location condition is false or NULL.

--Task 7.3
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--Both queries return John Smith and Mike Johnson.
--INNER JOIN returns only rows satisfying both the join condition and the location filter.

--PART 8
--Task 8.1
--Separate LEFT JOINs preserve all departments, including Marketing without employees or projects.
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

--Task 8.2
ALTER TABLE employees ADD COLUMN manager_id INTEGER;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

--Task 8.3
--The subquery calculates average salaries and keeps departments above 50000.
SELECT d.dept_name, s.avg_salary
FROM departments d
INNER JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
    HAVING AVG(salary) > 50000
) s ON d.dept_id = s.dept_id;

--LAB QUESTIONS
--Question 1
--INNER JOIN returns matching rows only.
--LEFT JOIN also returns unmatched left-table rows, with NULLs for right-table columns.

--Question 2
--CROSS JOIN can create an availability matrix pairing every employee with every project.

--Question 3
--For outer joins, ON determines matches while preserving unmatched rows from the preserved side.
--WHERE filters the joined result and can remove those unmatched rows.
--For inner joins, moving the same filter between ON and WHERE gives the same result.

--Question 4
--5 x 10 = 50 rows.

--Question 5
--NATURAL JOIN uses equality comparisons on all columns with the same names in both tables.

--Question 6
--Adding or renaming a shared column can silently change the join condition.
--Unrelated columns with the same name may cause incorrect matches or exclude valid rows.
--With no shared column names, NATURAL INNER JOIN produces a Cartesian product.

--Question 7
--SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
--This preserves the same rows; SELECT * lists B columns before A columns.
--SELECT A.*, B.* FROM B RIGHT JOIN A ON A.id = B.id preserves the original column order.

--Question 8
--Use FULL OUTER JOIN when all rows from both tables must be included, even without matches.
--For example, it finds employees without departments and departments without employees together.

--ADDITIONAL CHALLENGES
--Task 1
--UNION combines both outer joins and removes the repeated matched rows.
--The primary key columns keep distinct employees and departments distinguishable.
SELECT e.emp_id, e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_id, e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

--Task 2
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(*) > 1
);

--Task 3
--Recursive self-joins follow each employee's managers until the top-level manager is reached.
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        emp_id,
        emp_name AS employee,
        manager_id,
        emp_name::TEXT AS management_chain,
        0 AS manager_count
    FROM employees
    UNION ALL
    SELECT
        h.emp_id,
        h.employee,
        m.manager_id,
        h.management_chain || ' -> ' || m.emp_name,
        h.manager_count + 1
    FROM employee_hierarchy h
    INNER JOIN employees m ON h.manager_id = m.emp_id
)
SELECT employee, management_chain, manager_count
FROM employee_hierarchy
WHERE manager_id IS NULL
ORDER BY emp_id;

--Task 4
--Comparing employee IDs avoids pairing an employee with themselves or repeating reversed pairs.
SELECT e1.emp_name AS employee_1, e2.emp_name AS employee_2, d.dept_name
FROM employees e1
INNER JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
INNER JOIN departments d ON e1.dept_id = d.dept_id;
