package garage.dao;

import garage.model.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/** Module 2 (Receive payment): invoices of a customer, their details, adding lines, confirming payment. */
public class InvoiceDAO extends DAO {

    public static final String UNPAID = "Chưa thanh toán";
    public static final String PAID = "Đã thanh toán";

    /** Invoices (header + lines) of all vehicles of a customer, newest first. */
    public List<Invoice0> getInvoicesOfCustomer(int customerId, boolean unpaidOnly) {
        List<Invoice0> list = new ArrayList<>();
        String sql = "SELECT i.id FROM tblInvoice i JOIN tblVehicle v ON v.id = i.tblVehicleid "
                + "WHERE v.tblCustomerid = ? " + (unpaidOnly ? "AND i.status = ? " : "")
                + "ORDER BY i.issueDate DESC, i.id DESC";
        List<Integer> ids = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            if (unpaidOnly) ps.setString(2, UNPAID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        for (int id : ids) list.add(getInvoiceDetail(id));
        return list;
    }

    /** Full invoice with vehicle, staff, service lines and part lines; null if not found. */
    public Invoice0 getInvoiceDetail(int invoiceId) {
        String sql = "SELECT i.*, v.licensePlate, v.brand, v.model, "
                + "sm.fullName AS salesName, tm.fullName AS techName "
                + "FROM tblInvoice i JOIN tblVehicle v ON v.id = i.tblVehicleid "
                + "JOIN tblMember sm ON sm.id = i.tblSalesStaffid "
                + "JOIN tblMember tm ON tm.id = i.tblTechnicalStaffid WHERE i.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            Invoice0 inv;
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                inv = new Invoice0();
                inv.setId(rs.getInt("id"));
                inv.setIssueDate(rs.getTimestamp("issueDate"));
                inv.setTotalAmount(rs.getInt("totalAmount"));
                inv.setStatus(rs.getString("status"));
                Vehicle0 v = new Vehicle0();
                v.setId(rs.getInt("tblVehicleid"));
                v.setLicensePlate(rs.getString("licensePlate"));
                v.setBrand(rs.getString("brand"));
                v.setModel(rs.getString("model"));
                inv.setVehicle(v);
                SalesStaff0 s = new SalesStaff0();
                s.setId(rs.getInt("tblSalesStaffid"));
                s.setFullName(rs.getString("salesName"));
                inv.setSalesStaff(s);
                TechnicalStaff0 t = new TechnicalStaff0();
                t.setId(rs.getInt("tblTechnicalStaffid"));
                t.setFullName(rs.getString("techName"));
                inv.setTechnicalStaff(t);
            }
            inv.setInvoiceServiceDetail(loadServiceLines(invoiceId));
            inv.setInvoicePartDetail(loadPartLines(invoiceId));
            return inv;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private List<InvoiceServiceDetail0> loadServiceLines(int invoiceId) throws Exception {
        List<InvoiceServiceDetail0> list = new ArrayList<>();
        String sql = "SELECT d.id, d.unitPrice, s.id AS sid, s.name, s.description, s.price "
                + "FROM tblInvoiceServiceDetail d JOIN tblService s ON s.id = d.tblServiceid "
                + "WHERE d.tblInvoiceid = ? ORDER BY d.id";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Service0 s = new Service0();
                    s.setId(rs.getInt("sid"));
                    s.setName(rs.getString("name"));
                    s.setDescription(rs.getString("description"));
                    s.setPrice(rs.getInt("price"));
                    InvoiceServiceDetail0 d = new InvoiceServiceDetail0();
                    d.setId(rs.getInt("id"));
                    d.setUnitPrice(rs.getInt("unitPrice"));
                    d.setService(s);
                    list.add(d);
                }
            }
        }
        return list;
    }

    private List<InvoicePartDetail0> loadPartLines(int invoiceId) throws Exception {
        List<InvoicePartDetail0> list = new ArrayList<>();
        String sql = "SELECT d.id, d.quantity, d.unitPrice, p.id AS pid, p.name, p.unit "
                + "FROM tblInvoicePartDetail d JOIN tblPart p ON p.id = d.tblPartid "
                + "WHERE d.tblInvoiceid = ? ORDER BY d.id";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Part0 p = new Part0();
                    p.setId(rs.getInt("pid"));
                    p.setName(rs.getString("name"));
                    p.setUnit(rs.getString("unit"));
                    InvoicePartDetail0 d = new InvoicePartDetail0();
                    d.setId(rs.getInt("id"));
                    d.setQuantity(rs.getInt("quantity"));
                    d.setUnitPrice(rs.getInt("unitPrice"));
                    d.setPart(p);
                    list.add(d);
                }
            }
        }
        return list;
    }

    /** Adds a service line to an unpaid invoice. Returns an error message, or null on success. */
    public String addService(int invoiceId, int serviceId) {
        try {
            con.setAutoCommit(false);
            try {
                if (!isUnpaid(invoiceId)) { con.rollback(); return "Hóa đơn không còn ở trạng thái chưa thanh toán."; }
                int price;
                try (PreparedStatement ps = con.prepareStatement("SELECT price FROM tblService WHERE id = ?")) {
                    ps.setInt(1, serviceId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { con.rollback(); return "Dịch vụ không tồn tại."; }
                        price = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblInvoiceServiceDetail(unitPrice, tblInvoiceid, tblServiceid) VALUES (?,?,?)")) {
                    ps.setInt(1, price); ps.setInt(2, invoiceId); ps.setInt(3, serviceId);
                    ps.executeUpdate();
                }
                recalcTotal(invoiceId);
                con.commit();
                return null;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /** Adds a part line (and takes it out of stock). Returns an error message, or null on success. */
    public String addPart(int invoiceId, int partId, int quantity) {
        if (quantity <= 0) return "Số lượng phải lớn hơn 0.";
        try {
            con.setAutoCommit(false);
            try {
                if (!isUnpaid(invoiceId)) { con.rollback(); return "Hóa đơn không còn ở trạng thái chưa thanh toán."; }
                int price, stock;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT importPrice, stockQuantity FROM tblPart WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, partId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { con.rollback(); return "Phụ tùng không tồn tại."; }
                        price = rs.getInt(1);
                        stock = rs.getInt(2);
                    }
                }
                if (stock < quantity) { con.rollback(); return "Không đủ tồn kho (còn " + stock + ")."; }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE tblPart SET stockQuantity = stockQuantity - ? WHERE id = ?")) {
                    ps.setInt(1, quantity); ps.setInt(2, partId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblInvoicePartDetail(quantity, unitPrice, tblInvoiceid, tblPartid) VALUES (?,?,?,?)")) {
                    ps.setInt(1, quantity); ps.setInt(2, price); ps.setInt(3, invoiceId); ps.setInt(4, partId);
                    ps.executeUpdate();
                }
                recalcTotal(invoiceId);
                con.commit();
                return null;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Confirm payment (Module 2: confirmInvoice). Validates the invoice has at least one line and a positive
     * total, then marks it paid. Returns an error message, or null on success.
     */
    public String confirmInvoice(int invoiceId) {
        try {
            con.setAutoCommit(false);
            try {
                if (!isUnpaid(invoiceId)) { con.rollback(); return "Hóa đơn đã được thanh toán hoặc không tồn tại."; }
                recalcTotal(invoiceId);
                int lines = 0, total = 0;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT totalAmount, (SELECT COUNT(*) FROM tblInvoiceServiceDetail WHERE tblInvoiceid = ?) "
                        + "+ (SELECT COUNT(*) FROM tblInvoicePartDetail WHERE tblInvoiceid = ?) FROM tblInvoice WHERE id = ?")) {
                    ps.setInt(1, invoiceId); ps.setInt(2, invoiceId); ps.setInt(3, invoiceId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) { total = rs.getInt(1); lines = rs.getInt(2); }
                    }
                }
                if (lines == 0 || total <= 0) {
                    con.rollback();
                    return "Hóa đơn không hợp lệ: danh sách dịch vụ/phụ tùng rỗng hoặc tổng tiền bằng 0.";
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE tblInvoice SET status = ? WHERE id = ? AND status = ?")) {
                    ps.setString(1, PAID); ps.setInt(2, invoiceId); ps.setString(3, UNPAID);
                    ps.executeUpdate();
                }
                con.commit();
                return null;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private boolean isUnpaid(int invoiceId) throws Exception {
        try (PreparedStatement ps = con.prepareStatement("SELECT status FROM tblInvoice WHERE id = ? FOR UPDATE")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && UNPAID.equals(rs.getString(1));
            }
        }
    }

    private void recalcTotal(int invoiceId) throws Exception {
        String sql = "UPDATE tblInvoice SET totalAmount = "
                + "COALESCE((SELECT SUM(unitPrice) FROM tblInvoiceServiceDetail WHERE tblInvoiceid = ?),0) + "
                + "COALESCE((SELECT SUM(unitPrice * quantity) FROM tblInvoicePartDetail WHERE tblInvoiceid = ?),0) "
                + "WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoiceId); ps.setInt(2, invoiceId); ps.setInt(3, invoiceId);
            ps.executeUpdate();
        }
    }
}
