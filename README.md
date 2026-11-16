# GarageManagement – Code J2EE (JSP + JDBC + MySQL + DAO)

Code của 2 module trong pha Thiết kế (đề số 28, file thiết kế `28_B23DCVT340.docx`):

- **Module 1** – Khách hàng tìm kiếm thông tin dịch vụ/phụ tùng
- **Module 2** – Nhân viên bán hàng nhận thanh toán

Code được viết theo biểu đồ lớp thiết kế trong file thiết kế. Không có Servlet tự viết: toàn bộ xử lý nằm trong các trang JSP, gọi xuống lớp DAO.

## Cấu trúc (khớp biểu đồ gói: `model`, `dao`, `view` chia gói con theo loại người dùng)

```
garage/
├── pom.xml                                   (đóng gói garage.war)
├── run.bat                                   (biên dịch + deploy nhanh lên Tomcat 9 trên Windows)
├── sql/                                      (schema.sql, seed.sql, seed_extra.sql – tạo CSDL + dữ liệu mẫu)
└── src/main/
    ├── java/
    │   ├── dao/     DAO, MemberDAO, ServiceDAO, PartDAO, CustomerDAO, InvoiceDAO,
    │   │            InvoicePartDetailDAO, InvoiceServiceDetailDAO
    │   └── model/   20 lớp thực thể: Member0, Customer0, Staff0, SalesStaff0, ...,
    │                Service0, Part0, Invoice0, InvoiceServiceDetail0, InvoicePartDetail0, ...
    └── webapp/
        ├── index.jsp                         (chuyển sang view/member/LoginScreen0.jsp)
        ├── css/style.css
        ├── view/member/                      LoginScreen0, Logout (.jsp) – dùng chung 2 module
        ├── view/customer/                    CustomerHomeScreen0, SearchScreen0, DetailScreen0 (.jsp)        – Module 1
        ├── view/salesstaff/                  SalesStaffScreen0, SearchCustomerScreen0, InvoiceScreen0 (.jsp) – Module 2
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
| InvoiceDAO | `getInvoiceByCustomer(customer) : Invoice0` | InvoiceScreen0.jsp |
| InvoiceDAO | `getInvoiceDetail(invoiceId) : Invoice0` (xem hóa đơn đã thanh toán để in) | InvoiceScreen0.jsp |
| InvoicePartDetailDAO | `addPartDetail(invoice, part, quantity) : boolean` | InvoiceScreen0.jsp |
| InvoiceServiceDetailDAO | `addServiceDetail(invoice, service) : boolean` | InvoiceScreen0.jsp |
| InvoiceDAO | `calculateTotalAmount(invoice) : int` | InvoiceScreen0.jsp |
| InvoiceDAO | `confirmInvoice(invoice) : boolean` | InvoiceScreen0.jsp |

## Luồng màn hình

- **Module 1:** `LoginScreen0` → `CustomerHomeScreen0` → `SearchScreen0` → `DetailScreen0`
- **Module 2:** `LoginScreen0` → `SalesStaffScreen0` → `SearchCustomerScreen0` → `InvoiceScreen0`
- Sau khi đăng nhập, hệ thống xác định vai trò: khách hàng vào `CustomerHomeScreen0`, nhân viên bán hàng vào `SalesStaffScreen0`.

Luồng `InvoiceScreen0` theo kịch bản: hiển thị hóa đơn chưa thanh toán hiện tại của khách → nhập từ khóa để tìm dịch vụ/phụ tùng gợi ý → nhập số lượng (mặc định 0) và bấm "Thêm vào hóa đơn" (chỉ các dòng có số lượng > 0; hệ thống tính lại tổng tiền) → bấm "Xác nhận hóa đơn" → thông báo thành công, in hóa đơn, OK quay về `SalesStaffScreen0`. Có thể bỏ qua bước bổ sung và xác nhận ngay.

Quy tắc: hóa đơn phải có ít nhất một dòng dịch vụ/phụ tùng và tổng tiền lớn hơn 0 mới xác nhận được, nếu không `confirmInvoice` trả về `false` và hiển thị "Xác nhận hóa đơn không thành công". Thêm phụ tùng sẽ trừ tồn kho và trả về `false` nếu không đủ hàng. Nếu khách có nhiều hóa đơn chưa thanh toán, màn hình xử lý hóa đơn mới nhất trước.

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
4. Mở `http://localhost:8080/garage/` (tự chuyển sang `/garage/view/member/LoginScreen0.jsp`).

## Tài khoản mẫu (mật khẩu: `123456`)

| Tài khoản | Vai trò | Dùng cho |
|---|---|---|
| `customer1`, `customer2` | Khách hàng | Module 1: tìm "thay dầu" |
| `sales1` | Nhân viên bán hàng | Module 2: Thanh toán → tìm "Nguyễn" → chọn khách hàng → Xác nhận hóa đơn → In hóa đơn |
