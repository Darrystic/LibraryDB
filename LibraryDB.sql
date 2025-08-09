-- Library Management System Database
-- Database: LibraryDB
-- Created for MySQL
-- Description: A relational database for managing a library, including books, members, authors, loans, and categories.
-- Normalization: 3NF (satisfies 1NF and 2NF)
-- Relationships: 1-M (Categories-Books, Members-Loans, Books-Loans), M-M (Books-Authors via Book_Authors)

-- Create the database
CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- Table: Categories
-- Stores book categories/genres (e.g., Fiction, Non-Fiction)
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT,
    -- Ensure category name is unique and not null
    CONSTRAINT chk_category_name CHECK (CategoryName <> '')
);

-- Table: Books
-- Stores book details
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    ISBN VARCHAR(13) NOT NULL UNIQUE,
    PublicationYear INT,
    CategoryID INT NOT NULL,
    TotalCopies INT NOT NULL DEFAULT 1,
    AvailableCopies INT NOT NULL DEFAULT 1,
    -- Constraints
    CONSTRAINT fk_book_category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT chk_isbn CHECK (ISBN REGEXP '^[0-9]{13}$'), -- ISBN must be 13 digits
    CONSTRAINT chk_copies CHECK (TotalCopies >= AvailableCopies AND AvailableCopies >= 0),
    CONSTRAINT chk_title CHECK (Title <> '')
);

-- Table: Authors
-- Stores author details
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    -- Ensure names are not empty
    CONSTRAINT chk_author_name CHECK (FirstName <> '' AND LastName <> '')
);

-- Table: Book_Authors
-- Junction table for M-M relationship between Books and Authors
CREATE TABLE Book_Authors (
    BookID INT,
    AuthorID INT,
    PRIMARY KEY (BookID, AuthorID),
    CONSTRAINT fk_book_author_book FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CONSTRAINT fk_book_author_author FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE
);

-- Table: Members
-- Stores library member details
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15),
    JoinDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    -- Constraints
    CONSTRAINT chk_member_email CHECK (Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_member_name CHECK (FirstName <> '' AND LastName <> '')
);

-- Table: Loans
-- Stores book loan records
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    LoanDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    FineAmount DECIMAL(5,2) DEFAULT 0.00,
    -- Constraints
    CONSTRAINT fk_loan_book FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT fk_loan_member FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CONSTRAINT chk_due_date CHECK (DueDate >= LoanDate),
    CONSTRAINT chk_fine CHECK (FineAmount >= 0)
);

-- Index for faster lookup on Loans by BookID and MemberID
CREATE INDEX idx_loan_book ON Loans(BookID);
CREATE INDEX idx_loan_member ON Loans(MemberID);