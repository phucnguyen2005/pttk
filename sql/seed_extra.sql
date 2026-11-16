USE garage;
SET NAMES utf8mb4;
-- Extra demo data for Module 2 (Receive payment). Run AFTER seed.sql, once.
-- Password of every new account: 123456
-- Search "Nguyễn"  -> Nguyễn Văn A, Nguyễn Văn An, Nguyễn Thị Lan, Nguyễn Minh Tuấn
-- Search "Văn"     -> Nguyễn Văn A, Nguyễn Văn An, Trần Văn An (+ staff are not customers)
-- Search "An"      -> Nguyễn Văn An, Trần Văn An
-- Search "Lan"     -> Nguyễn Thị Lan, Lê Thị Lan
-- Search "Minh Tuấn" -> Nguyễn Minh Tuấn, Phạm Minh Tuấn

INSERT INTO tblMember(id,username,password,fullName,address,birth,email,phoneNumber) VALUES
 (7, 'customer3','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Nguyễn Văn An',   'Hà Nội','1990-05-12','an.nv@mail.com',  '0903000001'),
 (8, 'customer4','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Nguyễn Thị Lan',  'Hải Phòng','1993-08-25','lan.nt@mail.com','0903000002'),
 (9, 'customer5','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Nguyễn Minh Tuấn','Hà Nội','1988-02-14','tuan.nm@mail.com','0903000003'),
 (10,'customer6','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Trần Văn An',     'Nam Định','1991-11-03','an.tv@mail.com',  '0903000004'),
 (11,'customer7','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Lê Thị Lan',      'Hà Nội','1996-06-19','lan.lt@mail.com',  '0903000005'),
 (12,'customer8','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Phạm Minh Tuấn',  'Hà Nam','1987-12-30','tuan.pm@mail.com', '0903000006');
INSERT INTO tblCustomer(tblMemberid) VALUES (7),(8),(9),(10),(11),(12);

INSERT INTO tblVehicle(id,licensePlate,brand,model,tblCustomerid) VALUES
 (3,'29B-11111','Toyota','Camry',7),
 (4,'30G-22222','Mazda','3',8),
 (5,'51H-33333','Kia','Morning',9),
 (6,'29C-44444','Hyundai','i10',10),
 (7,'30E-55555','Ford','Ranger',11),
 (8,'29D-66666','Honda','CR-V',12);

-- Invoices: 4..9 unpaid (one per new customer), 10..11 paid history. Staff: sales 3, technical 6.
-- Unpaid totals = sum of their detail rows below.
INSERT INTO tblInvoice(id,issueDate,totalAmount,status,tblSalesStaffid,tblTechnicalStaffid,tblVehicleid) VALUES
 (4, '2026-11-12 09:00:00',  540000,'Chưa thanh toán',3,6,3),
 (5, '2026-11-12 10:30:00',  780000,'Chưa thanh toán',3,6,4),
 (6, '2026-11-13 08:45:00',  930000,'Chưa thanh toán',3,6,5),
 (7, '2026-11-13 15:20:00', 2500000,'Chưa thanh toán',3,6,6),
 (8, '2026-11-14 11:10:00', 1600000,'Chưa thanh toán',3,6,7),
 (9, '2026-11-14 16:00:00',  720000,'Chưa thanh toán',3,6,8),
 (10,'2026-09-20 10:00:00', 1200000,'Đã thanh toán',  3,6,3),
 (11,'2026-10-05 13:30:00',  100000,'Đã thanh toán',  3,6,4);

-- service details (unitPrice = service price at that time)
INSERT INTO tblInvoiceServiceDetail(unitPrice,tblInvoiceid,tblServiceid) VALUES
 (350000, 4,1),(100000, 4,3),   -- inv 4: thay dầu động cơ + rửa xe
 (500000, 5,2),                 -- inv 5: thay dầu hộp số
 (450000, 6,5),                 -- inv 6: cân chỉnh thước lái
 (1200000,7,4),                 -- inv 7: bảo dưỡng định kỳ
 (100000, 8,3),                 -- inv 8: rửa xe
 (350000, 9,1),                 -- inv 9: thay dầu động cơ
 (1200000,10,4),                -- inv 10 (paid)
 (100000, 11,3);                -- inv 11 (paid)

-- part details (unitPrice = part price at that time)
INSERT INTO tblInvoicePartDetail(quantity,unitPrice,tblInvoiceid,tblPartid) VALUES
 (1, 90000,  4,2),              -- lọc dầu
 (1, 280000, 5,1),              -- dầu nhớt 5W-30
 (4, 120000, 6,4),              -- 4 bugi
 (2, 650000, 7,3),              -- 2 bộ má phanh
 (1, 1500000,8,5),              -- ắc quy
 (1, 280000, 9,1),(1,90000,9,2);-- dầu nhớt + lọc dầu
