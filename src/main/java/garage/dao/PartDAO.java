package garage.dao;

import garage.model.Part0;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PartDAO extends DAO {

    /** Parts whose name contains the keyword. */
    public List<Part0> getListPart(String keyword) {
        List<Part0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM tblPart WHERE name LIKE ? ORDER BY name")) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /** Full information of one part, or null if not found. */
    public Part0 getPartDetail(int partId) {
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblPart WHERE id = ?")) {
            ps.setInt(1, partId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private Part0 map(ResultSet rs) throws Exception {
        Part0 p = new Part0();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setUnit(rs.getString("unit"));
        p.setStockQuantity(rs.getInt("stockQuantity"));
        p.setImportPrice(rs.getInt("importPrice"));
        return p;
    }
}
