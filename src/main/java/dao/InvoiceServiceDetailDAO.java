package dao;

import model.Invoice0;
import model.Service0;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class InvoiceServiceDetailDAO extends DAO {

    /**
     * Design: addServiceDetail(invoice, service) : boolean. Adds a service line (unit price taken from the
     * database) to an unpaid invoice. Returns false, changing nothing, when the invoice is not unpaid or the
     * service does not exist.
     */
    public boolean addServiceDetail(Invoice0 invoice, Service0 service) {
        try {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement("SELECT status FROM tblInvoice WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, invoice.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !InvoiceDAO.UNPAID.equals(rs.getString(1))) { con.rollback(); return false; }
                    }
                }
                int price;
                try (PreparedStatement ps = con.prepareStatement("SELECT price FROM tblService WHERE id = ?")) {
                    ps.setInt(1, service.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { con.rollback(); return false; }
                        price = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblInvoiceServiceDetail(unitPrice, tblInvoiceid, tblServiceid) VALUES (?,?,?)")) {
                    ps.setInt(1, price); ps.setInt(2, invoice.getId()); ps.setInt(3, service.getId());
                    ps.executeUpdate();
                }
                con.commit();
                return true;
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
}
