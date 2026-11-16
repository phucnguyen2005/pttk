package garage.dao;

import garage.model.Customer0;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO extends DAO {

    /** Customers whose full name contains the keyword (Module 2: searchCustomer). */
    public List<Customer0> searchCustomer(String name) {
        List<Customer0> list = new ArrayList<>();
        String sql = "SELECT m.* FROM tblMember m JOIN tblCustomer c ON c.tblMemberid = m.id "
                + "WHERE m.fullName LIKE ? ORDER BY m.fullName";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + name + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /** One customer by member id, or null. */
    public Customer0 getCustomer(int customerId) {
        String sql = "SELECT m.* FROM tblMember m JOIN tblCustomer c ON c.tblMemberid = m.id WHERE m.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private Customer0 map(ResultSet rs) throws Exception {
        Customer0 c = new Customer0();
        c.setId(rs.getInt("id"));
        c.setUsername(rs.getString("username"));
        c.setFullName(rs.getString("fullName"));
        c.setAddress(rs.getString("address"));
        c.setBirth(rs.getDate("birth"));
        c.setEmail(rs.getString("email"));
        c.setPhoneNumber(rs.getString("phoneNumber"));
        return c;
    }
}
