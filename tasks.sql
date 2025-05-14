-- CRUD Opertation

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES (978-1-60129-456-2, 'To Kill a Mockingbird', 'Classic',6.00, 'yes','Harper Lee','J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
	issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;


-- CTAS (Create Table As Select)

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_issued_cnt
AS
SELECT 
	b.isbn,
    b.book_title,
    COUNT(ist.issued_id) as no_issued
FROM books b
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;


-- Data Analysis & Findings

-- Task 7. Retrieve All Books in a Specific Category
SELECT * 
FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category
SELECT 
	b.category,
    SUM(b.rental_price) as total_rental_income,
    COUNT(*)
FROM issued_status ist
JOIN books b ON ist.issued_book_isbn = b.isbn
GROUP BY b.category;

-- Task 9: List Members Who Registered in the Last 180 Days
SELECT *
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details
SELECT 
	e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name AS manager
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON e2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold (CTAS - Create Table As Select)
CREATE TABLE expensive_books 
AS
SELECT *
FROM books
WHERE rental_price > 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT
	DISTINCT ist.issued_book_name
FROM issued_status ist
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


-- Advanced SQL Operations


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT 
	ist.issued_member_id,
	m.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date AS over_dues_days
FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rst ON rst.issued_id = ist.issued_id
WHERE 
	rst.return_id IS NULL
    AND 
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY ist.issued_member_id;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

-- inserting a sample record
INSERT INTO return_status (return_id, issued_id, return_date, return_book_name, return_book_isbn)
VALUES ('RS150', 'IS150', CURDATE(), 'The Alchemist', '978-0-307-58837-1');

-- checking before updating book status
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';

-- Creating Stored Procedure
DELIMITER $$

CREATE PROCEDURE update_book_status_on_return()
BEGIN
	UPDATE books b
	JOIN return_status rs ON b.isbn = rs.return_book_isbn
	SET b.status = 'Yes';
    
    SELECT ROW_COUNT() AS books_updated;
END $$

DELIMITER ;

-- Calling the procedure
CALL update_book_status_on_return();

-- Verifying the update
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';
