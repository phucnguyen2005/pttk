USE garage;
SET NAMES utf8mb4;
-- All demo accounts use password: 123456
INSERT INTO tblGarage(id,name,address,contactPhoneNumber) VALUES (1,'Ga-ra Trung Tam','12 Nguyen Trai, Ha Noi','0241234567');

INSERT INTO tblMember(id,username,password,fullName,address,birth,email,phoneNumber) VALUES
 (1,'customer1','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Nguyễn Văn A','Hà Nội','1995-03-10','a@mail.com','0901000001'),
 (2,'customer2','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Trần Thị B','Hà Nội','1998-07-21','b@mail.com','0901000002'),
 (3,'sales1','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Lê Văn C','Hà Nội','1992-01-05','c@mail.com','0902000001'),
 (4,'manager1','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Phạm Văn D','Hà Nội','1985-09-15','d@mail.com','0902000002'),
 (5,'warehouse1','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Hoàng Thị E','Hà Nội','1990-11-30','e@mail.com','0902000003'),
 (6,'tech1','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Vũ Văn F','Hà Nội','1993-04-18','f@mail.com','0902000004');
INSERT INTO tblCustomer(tblMemberid) VALUES (1),(2);
INSERT INTO tblStaff(tblMemberid,`position`,tblGarageid) VALUES
 (3,'Nhân viên bán hàng',1),(4,'Nhân viên quản lý',1),(5,'Nhân viên kho',1),(6,'Nhân viên kỹ thuật',1);
INSERT INTO tblSalesStaff(id) VALUES (3);
INSERT INTO tblManagementStaff(id) VALUES (4);
INSERT INTO tblWarehouseStaff(id) VALUES (5);
INSERT INTO tblTechnicalStaff(id) VALUES (6);

INSERT INTO tblService(name,description,price) VALUES
 ('Thay dầu động cơ','Thay dầu động cơ và lọc dầu, kiểm tra mức dầu. Thời gian thực hiện ước tính: 30 phút.',350000),
 ('Thay dầu hộp số','Xả và thay dầu hộp số. Thời gian ước tính: 45 phút.',500000),
 ('Rửa xe','Rửa xe toàn diện, hút bụi nội thất. Thời gian ước tính: 30 phút.',100000),
 ('Bảo dưỡng định kỳ','Kiểm tra tổng thể 30 hạng mục. Thời gian ước tính: 2 giờ.',1200000),
 ('Cân chỉnh thước lái','Cân chỉnh góc đặt bánh xe. Thời gian ước tính: 1 giờ.',450000);
INSERT INTO tblPart(name,description,unit,stockQuantity,importPrice) VALUES
 ('Dầu nhớt động cơ 5W-30','Dầu tổng hợp 5W-30, can 4 lít.','Can',40,280000),
 ('Lọc dầu','Lọc dầu động cơ, phù hợp nhiều dòng xe.','Cái',60,90000),
 ('Má phanh trước','Bộ má phanh đĩa trước.','Bộ',25,650000),
 ('Bugi','Bugi iridium tuổi thọ cao.','Cái',100,120000),
 ('Ắc quy 12V 60Ah','Ắc quy khô, bảo hành 12 tháng.','Cái',15,1500000);

INSERT INTO tblVehicle(licensePlate,brand,model,tblCustomerid) VALUES ('29A-12345','Toyota','Vios',1);
INSERT INTO tblVehicle(licensePlate,brand,model,tblCustomerid) VALUES ('30F-67890','Honda','City',2);

-- Module 2 demo invoices (sales staff 3, technical staff 6). Status strings must match InvoiceDAO.UNPAID/PAID.
INSERT INTO tblInvoice(id,issueDate,totalAmount,status,tblSalesStaffid,tblTechnicalStaffid,tblVehicleid) VALUES
 (1,'2026-11-10 09:30:00',440000,'Chưa thanh toán',3,6,1),
 (2,'2026-11-11 14:00:00',100000,'Chưa thanh toán',3,6,2),
 (3,'2026-10-02 10:00:00',1200000,'Đã thanh toán',3,6,1);
INSERT INTO tblInvoiceServiceDetail(unitPrice,tblInvoiceid,tblServiceid) VALUES (350000,1,1),(100000,2,3),(1200000,3,4);
INSERT INTO tblInvoicePartDetail(quantity,unitPrice,tblInvoiceid,tblPartid) VALUES (1,90000,1,2);
