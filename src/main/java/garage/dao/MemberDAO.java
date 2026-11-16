package garage.dao;

import garage.model.Member0;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class MemberDAO extends DAO {

    /** Returns the matching member, or null when username/password are wrong. */
    public Member0 checkLogin(String username, String password) {
        String sql = "SELECT * FROM tblMember WHERE username = ? AND password = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, sha256(password));
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Member0 m = new Member0();
                m.setId(rs.getInt("id"));
                m.setUsername(rs.getString("username"));
                m.setFullName(rs.getString("fullName"));
                m.setAddress(rs.getString("address"));
                m.setBirth(rs.getDate("birth"));
                m.setEmail(rs.getString("email"));
                m.setPhoneNumber(rs.getString("phoneNumber"));
                return m; // password hash intentionally not kept in the session object
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /** True if the member is a customer (row exists in tblCustomer). */
    public boolean isCustomer(int memberId) {
        try (PreparedStatement ps = con.prepareStatement("SELECT 1 FROM tblCustomer WHERE tblMemberid = ?")) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /** Role of a member: "customer", "sales", "management", "warehouse", "technical" or "unknown". */
    public String getRole(int memberId) {
        String[][] tables = {
            {"tblCustomer", "tblMemberid", "customer"},
            {"tblSalesStaff", "id", "sales"},
            {"tblManagementStaff", "id", "management"},
            {"tblWarehouseStaff", "id", "warehouse"},
            {"tblTechnicalStaff", "id", "technical"}};
        try {
            for (String[] t : tables) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT 1 FROM " + t[0] + " WHERE " + t[1] + " = ?")) {
                    ps.setInt(1, memberId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) return t[2];
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return "unknown";
    }

    static String sha256(String s) throws Exception {
        byte[] d = MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : d) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
