# Garage management — Module 1 (Search service/spare parts info) + Module 2 (Receive payment)

Design: `28_B23DCVT340.docx`. Both modules read/write MySQL through the DAO layer.

## Layout
- `src/main/java/garage/model` – 20 entity classes
- `src/main/java/garage/dao` – JDBC/MySQL DAOs: `MemberDAO` (login, role), `ServiceDAO`, `PartDAO` (Module 1), `CustomerDAO`, `InvoiceDAO` (Module 2)
- `sql/` – `schema.sql`, `seed.sql`
- `src/main/webapp`
  - Module 1: `LoginScreen0` → `CustomerHomeScreen0` → `SearchScreen0` → `DetailScreen0`
  - Module 2: `LoginScreen0` → `SalesStaffScreen0` → `SearchCustomerScreen0` → `InvoiceScreen0`

## Run
1. Load the database (fresh): `sql/schema.sql` then `sql/seed.sql` into MySQL.
2. DB settings via env vars `GARAGE_DB_URL`, `GARAGE_DB_USER`, `GARAGE_DB_PASSWORD` (defaults: `localhost:3306/garage`, `root`, empty).
3. `mvn package` and deploy `target/garage.war` on Tomcat 9, or run `run.bat` (needs `mysql-connector-j` jar in `lib\`).
4. Open `http://localhost:8080/garage/`. All demo passwords: `123456`.
   - Module 1: `customer1`, search "thay dầu".
   - Module 2: `sales1`, Thanh toán → search "Nguyễn" → select customer → add service/part if needed → Xác nhận hóa đơn → In hóa đơn.

Payment rules: invoice must have ≥1 line and total > 0; confirming sets status "Đã thanh toán". Adding a part deducts stock and is refused when stock is insufficient.
