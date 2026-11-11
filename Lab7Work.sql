--PART 1
--Task 1.1
--Using the employees, departments, and projects tables from Lab6Work.

--PART 2
--Task 2.1
CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

--4 rows are returned. Tom Brown has NULL dept_id, so there is no matching department.

--Task 2.2
CREATE VIEW dept_statistics AS
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count,
       AVG(e.salary) AS avg_salary, MAX(e.salary) AS max_salary,
       MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

--Marketing is included with 0 employees. COUNT(e.emp_id) does not count NULL values.

--Task 2.3
CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location,
       COUNT(e.emp_id) AS team_size
FROM projects p
INNER JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name, d.location;

SELECT * FROM project_overview;

--AI Research has NULL dept_id, so INNER JOIN excludes it.

--Task 2.4
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;

--Only employees with matching departments appear. INNER JOIN would exclude a high earner without a department.

--PART 3
--Task 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
       END AS salary_grade
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

--Task 3.2
ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;

--Task 3.3
CREATE TEMP VIEW temp_view AS
SELECT emp_name, salary
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;
DROP VIEW temp_view;

--A temporary view is also removed automatically when the session ends.

--PART 4
--Task 4.1
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

--Task 4.2
UPDATE employee_salaries SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';

--The employees table is updated because employee_salaries is an updatable view.

--Task 4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees WHERE emp_id = 6;

--The insert is successful and Alice Johnson appears in the employees table.

--Task 4.4
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

--This INSERT intentionally fails because dept_id 103 does not satisfy dept_id = 101.
--Run separately to see the CHECK OPTION error; leave commented for the remaining tasks.
--INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
--VALUES (7, 'Bob Wilson', 103, 60000);

--PART 5
--Task 5.1
--Employee and project totals are calculated separately to avoid duplicated rows after joining.
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id, d.dept_name,
       COALESCE(e.total_employees, 0) AS total_employees,
       COALESCE(e.total_salaries, 0) AS total_salaries,
       COALESCE(p.total_projects, 0) AS total_projects,
       COALESCE(p.total_budget, 0) AS total_budget
FROM departments d
LEFT JOIN (
    SELECT dept_id, COUNT(*) AS total_employees, SUM(salary) AS total_salaries
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id
LEFT JOIN (
    SELECT dept_id, COUNT(*) AS total_projects, SUM(budget) AS total_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

--Task 5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

REFRESH MATERIALIZED VIEW dept_summary_mv;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

--Before REFRESH the materialized view has old totals. After REFRESH it includes Charlie Brown.

--Task 5.3
CREATE UNIQUE INDEX dept_summary_mv_dept_id_idx ON dept_summary_mv(dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

--CONCURRENTLY allows other sessions to read the materialized view during refresh.
--It requires a populated materialized view and a suitable UNIQUE index.

--Task 5.4
--Employees assigned to each project's department are counted as its team size.
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name, p.budget, d.dept_name,
       COUNT(e.emp_id) AS assigned_employees
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

--This SELECT intentionally fails because the materialized view has not been populated.
--SELECT * FROM project_stats_mv;

REFRESH MATERIALIZED VIEW project_stats_mv;
SELECT * FROM project_stats_mv;

--The error says the materialized view has not been populated. REFRESH fixes it.

--PART 6
--Task 6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

--Task 6.2
CREATE ROLE db_creator WITH CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager WITH CREATEROLE LOGIN PASSWORD 'manager101';
--SUPERUSER requires administrator privileges and should only be used in a practice database.
CREATE ROLE admin_user WITH SUPERUSER LOGIN PASSWORD 'admin999';

--Task 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

--Task 6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

--Task 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

--Task 6.6
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
--Promoting a role to SUPERUSER requires administrator privileges.
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

--PART 7
--Task 7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

--The senior analyst has read-only group access plus additional writing privileges.

--Task 7.2
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';

--The current owner must be permitted to transfer ownership to project_manager.
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

--View ownership can be checked in pg_views.
SELECT viewname, viewowner
FROM pg_views
WHERE schemaname = 'public' AND viewname = 'dept_statistics';

--Task 7.3
CREATE ROLE temp_owner WITH LOGIN;
CREATE TABLE temp_table(id INTEGER);
ALTER TABLE temp_table OWNER TO temp_owner;

--Requires sufficient ownership/administrative privileges; postgres is the target role in the lab.
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

--The objects are reassigned first so they do not prevent removal of the role.

--Task 7.4
CREATE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;

--These views filter displayed rows or columns. Users must not have broader table access if restriction is intended.

--PART 8
--Task 8.1
--The projects table from Lab 6 has no status column, so all projects are counted as active.
--Employee and project totals are calculated separately to prevent duplicate budget sums.
CREATE VIEW dept_dashboard AS
SELECT d.dept_name, d.location,
       COALESCE(e.employee_count, 0) AS employee_count,
       ROUND(e.avg_salary, 2) AS avg_salary,
       COALESCE(p.active_projects, 0) AS active_projects,
       COALESCE(p.total_project_budget, 0) AS total_project_budget,
       ROUND(COALESCE(p.total_project_budget, 0) / NULLIF(e.employee_count, 0), 2) AS budget_per_employee
FROM departments d
LEFT JOIN (
    SELECT dept_id, COUNT(*) AS employee_count, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id
LEFT JOIN (
    SELECT dept_id, COUNT(*) AS active_projects, SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id;

SELECT * FROM dept_dashboard;

--NULLIF prevents division by zero for departments with no employees.

--Task 8.2
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT p.project_name, p.budget, d.dept_name, p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
       END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;

--Task 8.3
CREATE ROLE viewer_role;
--ALL TABLES also covers ordinary views in the public schema.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;

