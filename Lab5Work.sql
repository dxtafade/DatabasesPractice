CREATE DATABASE Lab5Work;

--PART 1
--Task 1.1
CREATE TABLE employees(
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK(age BETWEEN 18 AND 65),
    salary NUMERIC CHECK(salary > 0)
);

--Task 1.2
CREATE TABLE products_catalog(
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discounted_price NUMERIC,

    CONSTRAINT valid_discount CHECK(
        regular_price > 0
        AND discounted_price > 0
        AND discounted_price < regular_price
    )
);

--Task 1.3
CREATE TABLE bookings(
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK(num_guests BETWEEN 1 AND 10),
    CHECK(check_out_date > check_in_date)
);

--Task 1.4
INSERT INTO employees VALUES (1, 'John', 'Smith', 25, 3000);
INSERT INTO employees VALUES (2, 'Anna', 'Brown', 40, 4500);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000, 800);
INSERT INTO products_catalog VALUES (2, 'Mouse', 50, 40);

INSERT INTO bookings VALUES (1, '2026-10-10', '2026-10-12', 2);
INSERT INTO bookings VALUES (2, '2026-11-01', '2026-11-05', 4);

--PART 2
--Task 2.1
CREATE TABLE customers(
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

--Task 2.2
CREATE TABLE inventory(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK(unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

--Task 2.3
INSERT INTO customers VALUES (1, 'john@example.com', '123456789', '2026-10-01');
INSERT INTO customers VALUES (2, 'anna@example.com', '987654321', '2026-10-02');
INSERT INTO inventory VALUES (1, 'Pen', 100, 2.50, '2026-10-01 10:00:00');
INSERT INTO inventory VALUES (2, 'Notebook', 50, 5.00, '2026-10-02 11:00:00');
INSERT INTO customers VALUES (3, 'sam@example.com', NULL, '2026-10-03');

--PART 3
--Task 3.1
CREATE TABLE users(
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

--Task 3.2
CREATE TABLE course_enrollments(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE(student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 101, 'CS101', 'Fall 2026');
INSERT INTO course_enrollments VALUES (2, 101, 'CS101', 'Spring 2027');

--Task 3.3
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE(username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE(email);

INSERT INTO users VALUES (1, 'john123', 'john@example.com', '2026-10-01 09:00:00');
INSERT INTO users VALUES (2, 'anna123', 'anna@example.com', '2026-10-02 09:00:00');

--PART 4
--Task 4.1
CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'IT', 'Boston');
INSERT INTO departments VALUES (2, 'HR', 'New York');
INSERT INTO departments VALUES (3, 'Finance', 'Chicago');

--Task 4.2
CREATE TABLE student_courses(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY(student_id, course_id)
);

INSERT INTO student_courses VALUES (101, 1, '2026-09-01', 'A');
INSERT INTO student_courses VALUES (101, 2, '2026-09-01', 'B');
INSERT INTO student_courses VALUES (102, 1, '2026-09-01', 'A');

--Task 4.3

--PART 5
--Task 5.1
CREATE TABLE employees_dept(
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'John Smith', 1, '2026-01-10');
INSERT INTO employees_dept VALUES (2, 'Anna Brown', 2, '2026-02-10');

--Task 5.2
CREATE TABLE authors(
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books(
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'George Orwell', 'United Kingdom');
INSERT INTO authors VALUES (2, 'Jane Austen', 'United Kingdom');
INSERT INTO publishers VALUES (1, 'Penguin Books', 'London');
INSERT INTO publishers VALUES (2, 'Oxford University Press', 'Oxford');
INSERT INTO books VALUES (1, '1984', 1, 1, 1949, '9780000000001');
INSERT INTO books VALUES (2, 'Pride and Prejudice', 2, 2, 1813, '9780000000002');

--Task 5.3
CREATE TABLE categories(
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK(quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Stationery');
INSERT INTO products_fk VALUES (1, 'Laptop', 1);
INSERT INTO products_fk VALUES (2, 'Pen', 2);
INSERT INTO orders VALUES (1, '2026-10-01');
INSERT INTO orders VALUES (2, '2026-10-02');
INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 2, 3);
INSERT INTO order_items VALUES (3, 2, 1, 1);

DELETE FROM orders WHERE order_id = 1;
SELECT * FROM order_items;

--PART 6
--Task 6.1
CREATE SCHEMA ecommerce;

CREATE TABLE ecommerce.customers(
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce.products(
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK(price >= 0),
    stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0)
);

CREATE TABLE ecommerce.orders(
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES ecommerce.customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK(total_amount >= 0),
    status TEXT NOT NULL CHECK(status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE ecommerce.order_details(
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES ecommerce.orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES ecommerce.products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price NUMERIC NOT NULL CHECK(unit_price >= 0)
);

INSERT INTO ecommerce.customers VALUES (1, 'John Smith', 'john@shop.com', '111111', '2026-09-01');
INSERT INTO ecommerce.customers VALUES (2, 'Anna Brown', 'anna@shop.com', NULL, '2026-09-02');
INSERT INTO ecommerce.customers VALUES (3, 'Sam Lee', 'sam@shop.com', '333333', '2026-09-03');
INSERT INTO ecommerce.customers VALUES (4, 'Max White', 'max@shop.com', '444444', '2026-09-04');
INSERT INTO ecommerce.customers VALUES (5, 'Kate Green', 'kate@shop.com', '555555', '2026-09-05');

INSERT INTO ecommerce.products VALUES (1, 'Laptop', 'Portable computer', 1000, 10);
INSERT INTO ecommerce.products VALUES (2, 'Mouse', 'Wireless mouse', 25, 100);
INSERT INTO ecommerce.products VALUES (3, 'Keyboard', 'USB keyboard', 50, 50);
INSERT INTO ecommerce.products VALUES (4, 'Monitor', '24 inch monitor', 200, 30);
INSERT INTO ecommerce.products VALUES (5, 'Headphones', 'Stereo headphones', 75, 40);

INSERT INTO ecommerce.orders VALUES (1, 1, '2026-10-01', 1000, 'pending');
INSERT INTO ecommerce.orders VALUES (2, 2, '2026-10-02', 50, 'processing');
INSERT INTO ecommerce.orders VALUES (3, 3, '2026-10-03', 100, 'shipped');
INSERT INTO ecommerce.orders VALUES (4, 4, '2026-10-04', 200, 'delivered');
INSERT INTO ecommerce.orders VALUES (5, 5, '2026-10-05', 75, 'cancelled');

INSERT INTO ecommerce.order_details VALUES (1, 1, 1, 1, 1000);
INSERT INTO ecommerce.order_details VALUES (2, 2, 2, 2, 25);
INSERT INTO ecommerce.order_details VALUES (3, 3, 3, 2, 50);
INSERT INTO ecommerce.order_details VALUES (4, 4, 4, 1, 200);
INSERT INTO ecommerce.order_details VALUES (5, 5, 5, 1, 75);

SELECT * FROM ecommerce.customers;
SELECT * FROM ecommerce.products;
SELECT * FROM ecommerce.orders;
SELECT * FROM ecommerce.order_details;

BEGIN;
DELETE FROM ecommerce.orders WHERE order_id = 1;
SELECT * FROM ecommerce.order_details WHERE order_id = 1;
ROLLBACK;
SELECT * FROM ecommerce.order_details WHERE order_id = 1;
