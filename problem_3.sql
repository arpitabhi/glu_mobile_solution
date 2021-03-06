
-- Problem 3: Assuming our company (Glu Mobile, Inc) has tree-like employee structure, for example,

-- CEO
--   VP of Engineering
--     Director of Engineering
--       Studio A
--         Manager A of Testing
--           Team A
--             Group A
--             Group B
--             Group C
--           Team B
--           Team C
--         Manager B of Development
--           Team A
--           Team B
--           Team C
--         Manager C of QA
--           Team A
--           Team B
--           Team C
--       Studio B
--         Manager A of Testing
--           Team A
--             Group A
--             Group B
--             Group C
--           Team B
--           Team C
--         Manager B of Development
--           Team A
--           Team B
--           Team C
--         Manager C of QA
--           Team A
--           Team B
--           Team C
--   VP of Marketing
--   VP of Product
--   VP of Finance
--   VP of Accounting
--   VP of Human Resource
-- Notice that some of the department won’t have such detailed structure as Engineering. It might be just having Manager(s) only.

-- We would like to create some database tables to store employee data reflecting such organizational structure. 
-- Using MySQL database as the storage of data source. Please do the following:

-- a.  Create database table(s) to reflect such a structure.
-- Solution 3.a - 
--      I have created 6 tables as per below.
--          1. employess(emp_no(PK),birth_date,first_name,last_name,gender,hire_date)
--          2. departments(dept_no(PK),dept_name)
--          3. dept_emp(emp_no(FK),dept_no(FK),from_date,to_date,emp_no+dept_no(PK))
--          4. dept_manager(dept_no(FK),emp_no(FK),from_date,to_date,emp_no+dept_no(PK))
--          5. titles(emp_no(FK),title,from_date,to_date,emp_no+title+from_date(PK))
--          6. salaries(emp_no(FK),salary,from_date,to_date,emp_no+from_date(PK))

CREATE DATABASE glu_mobile_org

USE glu_mobile_org
CREATE TABLE employees (
    emp_no      INT             NOT NULL,  -- UNSIGNED AUTO_INCREMENT??
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      ENUM ('M','F')  NOT NULL,  -- Enumeration of either 'M' or 'F'  
    hire_date   DATE            NOT NULL,
    manager_no  INT             NOT NULL,
    PRIMARY KEY (emp_no),                   -- Index built automatically on primary-key column
                                           -- INDEX (first_name)
                                           -- INDEX (last_name)
    FOREIGN KEY (manager_no) REFERENCES employees (emp_no) ON DELETE CASCADE
);

CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,  -- in the form of 'dxxx'
    dept_name   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (dept_no),                 -- Index built automatically
    UNIQUE  KEY (dept_name)                -- Build INDEX on this unique-value column
);


CREATE TABLE dept_emp (
    emp_no      INT         NOT NULL,
    dept_no     CHAR(4)     NOT NULL,
    from_date   DATE        NOT NULL,
    to_date     DATE        NOT NULL,
    KEY         (emp_no),   -- Build INDEX on this non-unique-value column
    KEY         (dept_no),  -- Build INDEX on this non-unique-value column
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
           -- Cascade DELETE from parent table 'employee' to this child table
           -- If an emp_no is deleted from parent 'employee', all records
           --  involving this emp_no in this child table are also deleted
           -- ON UPDATE CASCADE??
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
           -- ON UPDATE CASCADE??
    PRIMARY KEY (emp_no, dept_no)
           -- Might not be unique?? Need to include from_date
);

CREATE TABLE dept_manager (
   dept_no      CHAR(4)  NOT NULL,
   emp_no       INT      NOT NULL,
   from_date    DATE     NOT NULL,
   to_date      DATE     NOT NULL,
   KEY         (emp_no),
   KEY         (dept_no),
   FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
                                  -- ON UPDATE CASCADE??
   FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
   PRIMARY KEY (emp_no, dept_no)  -- might not be unique?? Need from_date
);


CREATE TABLE titles (
    emp_no      INT          NOT NULL,
    title       VARCHAR(50)  NOT NULL,
    from_date   DATE         NOT NULL,
    to_date     DATE,
    KEY         (emp_no),
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
                         -- ON UPDATE CASCADE??
    PRIMARY KEY (emp_no, title, from_date)
       -- This ensures unique combination. 
       -- An employee may hold the same title but at different period
);

CREATE TABLE salaries (
    emp_no      INT    NOT NULL,
    salary      INT    NOT NULL,
    from_date   DATE   NOT NULL,
    to_date     DATE   NOT NULL,
    KEY         (emp_no),
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no, from_date)
);


-- b.  Count how many employees are in their own department under each of VPs.

-- Solution 3.b
SELECT NAME1.first_name1 AS 'VP First Name',NAME1.last_name1 AS 'VP Last Name',COUNT_NO.Number1 AS 'Number of Employees Under VP' FROM 

(SELECT DEP.dept_no AS dept_no1,EMP.Number_of_Employees AS Number1 FROM departments DEP
INNER JOIN (SELECT COUNT(emp_no) AS 'Number_of_Employees', dept_no FROM dept_emp GROUP BY dept_no) EMP
ON DEP.dept_no = EMP.dept_no) COUNT_NO

INNER JOIN 

(SELECT VP_NAME.dept_no AS dept_no2,VP_NAME.first_name AS first_name1,VP_NAME.last_name AS last_name1 FROM dept_emp DEPART1
INNER JOIN (SELECT emp_no,first_name,last_name FROM employees
WHERE emp_no IN (SELECT emp_no FROM titles WHERE title LIKE 'VP %')) VP_NAME
ON DEPART1.emp_no=VP_NAME.emp_no) NAME1

ON COUNT_NO.dept_no1 = NAME1.dept_no2


-- c.  List all departments that just have the managers only.
-- Solution 3.c

SELECT dept_name AS 'Department with Only Managers' FROM departments
WHERE dept_no NOT IN
                    (SELECT DISTINCT(dept_no) FROM dept_emp
                    WHERE
                    emp_no IN (SELECT emp_no FROM titles WHERE title NOT IN ('VP%','%Manager%')))



-- d.  Assuming we have the salary column for the employee table, write a query to fetch all employees’ 
-- first name and last name who have salary over $80000.
-- Solution 3.d

SELECT EMP.first_name, EMP.last_name FROM employees EMP
INNER JOIN salaries SAL
ON SAL.emp_no=EMP.emp_no
WHERE SAL.salary>80000 

-- e.  Assuming we also have hiring date for the employee table, write a query to list out each 
-- unique hiring date with how many total company employees on that date. (hiring_date, total_employees)
-- Solution 3.e

SELECT hire_date,COUNT(emp_no) AS 'Number of Employee' FROM employee
GROUP BY hire_date
ORDER BY hire_date ASC


-- f.  This is the bonus question. Assuming we have more than 100k+ employees and so many 
-- groups, sometimes, reorganizing may happen. Write the query to reflect the following actions:
-- a.  What if the employees under the Team A of Manager B in Development under Studio A were laid off?

-- Solution 3.f.a
--              Since we have manitained a parent-child relationship amoung employees- department ,
--              employee-dept_emp, employee-dept-manager, employee-title, employee-salaries tables
--              If an employee is laid off we can simply delete the emp_no corresponding to the particular employee
--              Since we have put the Foreign key mapping with Delete cascade on all the details related to that employee 
--              would be automatically be deleted.
--              



-- b.  What if We need to add employees to form a Team D to Manager B of Development under Studio B, 
--     assuming Team D would be the node after Team C?

-- Solution 3.f.b
--              Since here we make use of recursive relationship between employees and Manager.
--              We can add any team with the same Manager.