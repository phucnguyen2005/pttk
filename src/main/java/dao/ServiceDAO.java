package dao;

import model.Service0;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO extends DAO {

    /** Services whose name contains the keyword. */
    public List<Service0> getListService(String keyword) {
        List<Service0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM tblService WHERE name LIKE ? ORDER BY name")) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /** Full information of one service, or null if not found. */
    public Service0 getServiceDetail(int serviceId) {
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblService WHERE id = ?")) {
            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private Service0 map(ResultSet rs) throws Exception {
        Service0 s = new Service0();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setDescription(rs.getString("description"));
        s.setPrice(rs.getInt("price"));
        return s;
    }
}
