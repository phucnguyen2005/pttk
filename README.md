# GarageManagement – Code J2EE (JSP + JDBC + MySQL + DAO)

Code của 2 module trong pha Thiết kế (đề số 28, file thiết kế `28_B23DCVT340.docx`):

- **Module 1** – Khách hàng tìm kiếm thông tin dịch vụ/phụ tùng
- **Module 2** – Nhân viên bán hàng nhận thanh toán

Code được viết theo biểu đồ lớp thiết kế trong file thiết kế. Không có Servlet tự viết: toàn bộ xử lý nằm trong các trang JSP, gọi xuống lớp DAO.

## Cấu trúc

```
garage/
├── pom.xml                                   (đóng gói garage.war)
├── run.bat                                   (biên dịch + deploy nhanh lên Tomcat 9 trên Windows)
├── sql/                                      (schema.sql, seed.sql, seed_extra.sql – tạo CSDL + dữ liệu mẫu)
└── src/main/
    ├── java/garage/
    │   ├── dao/     DAO, MemberDAO, ServiceDAO, PartDAO, CustomerDAO, InvoiceDAO
    │   └── model/   20 lớp thực thể: Member0, Customer0, Staff0, SalesStaff0, ...,
    │                Service0, Part0, Invoice0, InvoiceServiceDetail0, InvoicePartDetail0, ...
    └── webapp/
        ├── index.jsp                         (chuyển sang LoginScreen0.jsp)
        ├── LoginScreen0.jsp, Logout.jsp      (đăng nhập / đăng xuất, dùng chung 2 module)
        ├── style.css
        ├── CustomerHomeScreen0, SearchScreen0, DetailScreen0 (.jsp)        – Module 1
        ├── SalesStaffScreen0, SearchCustomerScreen0, InvoiceScreen0 (.jsp) – Module 2
        └── WEB-INF/web.xml
```

## Phương thức DAO và trang JSP gọi

| Lớp | Phương thức | Trang JSP gọi |
|---|---|---|
| MemberDAO | `checkLogin(username, password) : Member0` | LoginScreen0.jsp |
| MemberDAO | `getRole(memberId) : String` | LoginScreen0.jsp |
| ServiceDAO | `getListService(keyword) : List<Service0>` | SearchScreen0.jsp, InvoiceScreen0.jsp |
| PartDAO | `getListPart(keyword) : List<Part0>` | SearchScreen0.jsp, InvoiceScreen0.jsp |
| ServiceDAO | `getServiceDetail(serviceId) : Service0` | DetailScreen0.jsp |
| PartDAO | `getPartDetail(partId) : Part0` | DetailScreen0.jsp |
| CustomerDAO | `searchCustomer(name) : List<Customer0>` | SearchCustomerScreen0.jsp |
| CustomerDAO | `getCustomer(customerId) : Customer0` | InvoiceScreen0.jsp |
| InvoiceDAO | `getInvoicesOfCustomer(customerId, unpaidOnly) : List<Invoice0>` | InvoiceScreen0.jsp |
| InvoiceDAO | `getInvoiceDetail(invoiceId) : Invoice0` | InvoiceScreen0.jsp |
| InvoiceDAO | `addService(invoiceId, serviceId)`, `addPart(invoiceId, partId, quantity)` | InvoiceScreen0.jsp |
| InvoiceDAO | `confirmInvoice(invoiceId)` | InvoiceScreen0.jsp |

## Luồng màn hình

- **Module 1:** `LoginScreen0` → `CustomerHomeScreen0` → `SearchScreen0` → `DetailScreen0`
- **Module 2:** `LoginScreen0` → `SalesStaffScreen0` → `SearchCustomerScreen0` → `InvoiceScreen0`
- Sau khi đăng nhập, hệ thống xác định vai trò: khách hàng vào `CustomerHomeScreen0`, nhân viên bán hàng vào `SalesStaffScreen0`.

Quy tắc thanh toán: hóa đơn phải có ít nhất một dòng dịch vụ/phụ tùng và tổng tiền lớn hơn 0 mới xác nhận được; xác nhận xong trạng thái chuyển thành "Đã thanh toán" và có thể in hóa đơn. Thêm phụ tùng vào hóa đơn sẽ trừ tồn kho, và bị từ chối nếu không đủ hàng.

## Cách chạy

Cần: JDK 11 trở lên, Apache Tomcat 9 (dùng `javax.servlet`, không dùng Tomcat 10+), MySQL 8.0.

1. **Tạo CSDL:** chạy `sql/schema.sql`, sau đó `sql/seed.sql` (và `sql/seed_extra.sql` nếu muốn thêm dữ liệu mẫu cho Module 2, chạy sau `seed.sql`, chỉ chạy một lần). Ví dụ:
   ```
   mysql -uroot -p --default-character-set=utf8mb4 < sql/schema.sql
   mysql -uroot -p --default-character-set=utf8mb4 < sql/seed.sql
   ```
   Bắt buộc dùng `utf8mb4`, nếu không tiếng Việt bị lỗi mã hóa.
2. **Cấu hình kết nối MySQL** bằng biến môi trường (nếu không đặt sẽ dùng giá trị mặc định):

   | Biến | Mặc định |
   |---|---|
   | `GARAGE_DB_URL` | `jdbc:mysql://localhost:3306/garage?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC` |
   | `GARAGE_DB_USER` | `root` |
   | `GARAGE_DB_PASSWORD` | (rỗng) |
3. **Build và deploy:**
   - Dòng lệnh: `mvn clean package` rồi copy `target/garage.war` vào thư mục `webapps/` của Tomcat 9.
   - Hoặc trên Windows: đặt jar `mysql-connector-j` vào thư mục `lib\` rồi chạy `run.bat` (cần sửa `CATALINA_HOME` trong file nếu Tomcat không ở `D:\tomcat9`).
4. Mở `http://localhost:8080/garage/`.

## Tài khoản mẫu (mật khẩu: `123456`)

| Tài khoản | Vai trò | Dùng cho |
|---|---|---|
| `customer1`, `customer2` | Khách hàng | Module 1: tìm "thay dầu" |
| `sales1` | Nhân viên bán hàng | Module 2: Thanh toán → tìm "Nguyễn" → chọn khách hàng → Xác nhận hóa đơn → In hóa đơn |
