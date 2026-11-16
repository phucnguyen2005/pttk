package dao;

import model.Invoice0;
import model.Part0;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class InvoicePartDetailDAO extends DAO {

    /**
     * Design: addPartDetail(invoice, part, quantity) : boolean. Adds a part line (unit price taken from the
     * database) to an unpaid invoice and takes the quantity out of stock. Returns false, changing nothing, when
     * the quantity is not positive, the invoice is not unpaid, the part does not exist or stock is insufficient.
     */
    public boolean addPartDetail(Invoice0 invoice, Part0 part, int quantity) {
        if (quantity <= 0) return false;
        try {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement("SELECT status FROM tblInvoice WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, invoice.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !InvoiceDAO.UNPAID.equals(rs.getString(1))) { con.rollback(); return false; }
                    }
                }
                int price, stock;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT importPrice, stockQuantity FROM tblPart WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, part.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { con.rollback(); return false; }
                        price = rs.getInt(1);
                        stock = rs.getInt(2);
                    }
                }
                if (stock < quantity) { con.rollback(); return false; }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE tblPart SET stockQuantity = stockQuantity - ? WHERE id = ?")) {
                    ps.setInt(1, quantity); ps.setInt(2, part.getId());
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblInvoicePartDetail(quantity, unitPrice, tblInvoiceid, tblPartid) VALUES (?,?,?,?)")) {
                    ps.setInt(1, quantity); ps.setInt(2, price); ps.setInt(3, invoice.getId()); ps.setInt(4, part.getId());
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
