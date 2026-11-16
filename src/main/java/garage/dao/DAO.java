package garage.dao;

import java.sql.Connection;
import java.sql.DriverManager;

/** Base class of all DAOs: holds the database connection (design: DAO.con + DAO()). */
public class DAO {
    protected Connection con;

    public DAO() {
        String url = env("GARAGE_DB_URL",
                "jdbc:mysql://localhost:3306/garage?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC");
        String user = env("GARAGE_DB_USER", "root");
        String pass = env("GARAGE_DB_PASSWORD", "");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            throw new RuntimeException("Cannot connect to database: " + e.getMessage(), e);
        }
    }

    public void close() {
        try { if (con != null) con.close(); } catch (Exception ignored) { }
    }

    private static String env(String key, String def) {
        String v = System.getenv(key);
        return v == null || v.isEmpty() ? def : v;
    }
}
