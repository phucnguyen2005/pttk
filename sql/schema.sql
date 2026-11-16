-- Garage management system - database schema (design phase 7)
CREATE DATABASE IF NOT EXISTS garage CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE garage;
SET NAMES utf8mb4;

CREATE TABLE tblMember (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,          -- SHA-256 hex
  fullName VARCHAR(100) NOT NULL,
  address VARCHAR(255),
  birth DATE,
  email VARCHAR(100),
  phoneNumber VARCHAR(15)
);
CREATE TABLE tblGarage (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL, address VARCHAR(255), contactPhoneNumber VARCHAR(15)
);
CREATE TABLE tblCustomer (
  tblMemberid INT PRIMARY KEY,
  FOREIGN KEY (tblMemberid) REFERENCES tblMember(id)
);
CREATE TABLE tblStaff (
  tblMemberid INT PRIMARY KEY,
  `position` VARCHAR(50),
  tblGarageid INT,
  FOREIGN KEY (tblMemberid) REFERENCES tblMember(id),
  FOREIGN KEY (tblGarageid) REFERENCES tblGarage(id)
);
CREATE TABLE tblManagementStaff (id INT PRIMARY KEY, FOREIGN KEY (id) REFERENCES tblStaff(tblMemberid));
CREATE TABLE tblSalesStaff      (id INT PRIMARY KEY, FOREIGN KEY (id) REFERENCES tblStaff(tblMemberid));
CREATE TABLE tblTechnicalStaff  (id INT PRIMARY KEY, FOREIGN KEY (id) REFERENCES tblStaff(tblMemberid));
CREATE TABLE tblWarehouseStaff  (id INT PRIMARY KEY, FOREIGN KEY (id) REFERENCES tblStaff(tblMemberid));
CREATE TABLE tblRepairBay (
  id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), status VARCHAR(20), description TEXT,
  tblGarageid INT NOT NULL, FOREIGN KEY (tblGarageid) REFERENCES tblGarage(id)
);
CREATE TABLE tblWarehouse (
  id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), location VARCHAR(255),
  tblGarageid INT NOT NULL, FOREIGN KEY (tblGarageid) REFERENCES tblGarage(id)
);
CREATE TABLE tblSupplier (
  id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), address VARCHAR(255),
  phoneNumber VARCHAR(15), email VARCHAR(100)
);
CREATE TABLE tblVehicle (
  id INT AUTO_INCREMENT PRIMARY KEY, licensePlate VARCHAR(20), brand VARCHAR(50), model VARCHAR(50),
  tblCustomerid INT NOT NULL, FOREIGN KEY (tblCustomerid) REFERENCES tblCustomer(tblMemberid)
);
CREATE TABLE tblAppointment (
  id INT AUTO_INCREMENT PRIMARY KEY, `time` DATETIME, status VARCHAR(20), note VARCHAR(255),
  tblCustomerid INT NOT NULL, FOREIGN KEY (tblCustomerid) REFERENCES tblCustomer(tblMemberid)
);
CREATE TABLE tblService (
  id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, description TEXT, price INT NOT NULL
);
CREATE TABLE tblPart (
  id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, description TEXT,
  unit VARCHAR(20), stockQuantity INT NOT NULL DEFAULT 0, importPrice INT NOT NULL
);
CREATE TABLE tblInvoice (
  id INT AUTO_INCREMENT PRIMARY KEY, issueDate DATETIME, totalAmount INT NOT NULL DEFAULT 0, status VARCHAR(20),
  tblSalesStaffid INT NOT NULL, tblTechnicalStaffid INT NOT NULL, tblVehicleid INT NOT NULL,
  FOREIGN KEY (tblSalesStaffid) REFERENCES tblSalesStaff(id),
  FOREIGN KEY (tblTechnicalStaffid) REFERENCES tblTechnicalStaff(id),
  FOREIGN KEY (tblVehicleid) REFERENCES tblVehicle(id)
);
CREATE TABLE tblInvoiceServiceDetail (
  id INT AUTO_INCREMENT PRIMARY KEY, unitPrice INT NOT NULL,
  tblInvoiceid INT NOT NULL, tblServiceid INT NOT NULL,
  FOREIGN KEY (tblInvoiceid) REFERENCES tblInvoice(id), FOREIGN KEY (tblServiceid) REFERENCES tblService(id)
);
CREATE TABLE tblInvoicePartDetail (
  id INT AUTO_INCREMENT PRIMARY KEY, quantity INT NOT NULL, unitPrice INT NOT NULL,
  tblInvoiceid INT NOT NULL, tblPartid INT NOT NULL,
  FOREIGN KEY (tblInvoiceid) REFERENCES tblInvoice(id), FOREIGN KEY (tblPartid) REFERENCES tblPart(id)
);
CREATE TABLE tblImportReceipt (
  id INT AUTO_INCREMENT PRIMARY KEY, importDate DATE, status VARCHAR(20),
  tblSupplierid INT NOT NULL, tblWarehouseStaffid INT NOT NULL,
  FOREIGN KEY (tblSupplierid) REFERENCES tblSupplier(id),
  FOREIGN KEY (tblWarehouseStaffid) REFERENCES tblWarehouseStaff(id)
);
CREATE TABLE tblImportReceiptDetail (
  id INT AUTO_INCREMENT PRIMARY KEY, quantity INT NOT NULL, importPrice INT NOT NULL,
  tblImportReceiptid INT NOT NULL, tblPartid INT NOT NULL,
  FOREIGN KEY (tblImportReceiptid) REFERENCES tblImportReceipt(id), FOREIGN KEY (tblPartid) REFERENCES tblPart(id)
);
