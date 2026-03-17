import javax.swing.*;
import java.sql.*;
import java.util.Vector;

public class LogicRouter {


    public static JComponent getComponentFor(String tableName, String colName, String currentValue) {
        JComponent component = null;

        // 1. Έλεγχος Μέλους 1
        component = Member1.getCustomField(tableName, colName, currentValue);
        if (component != null) return component;

        // 2. Έλεγχος Μέλους 2
        component = Member2.getCustomField(tableName, colName, currentValue);
        if (component != null) return component;

        // 3. Έλεγχος Μέλους 3
        component = Member3.getCustomField(tableName, colName, currentValue);
        if (component != null) return component;

        // 4. Global Logic (Κοινά για όλους, π.χ. Branch)
        if (colName.toLowerCase().endsWith("br_code")) {
            return createDBCombo("branch", "br_code", "br_street", currentValue);
        }

        return null; // Κανείς δεν ανέλαβε το πεδίο, γύρνα null
    }

    // --- ΒΟΗΘΗΤΙΚΑ ΕΡΓΑΛΕΙΑ ΓΙΑ ΟΛΟΥΣ (SHARED TOOLS) ---

    public static JComboBox<String> createCombo(String[] items, String current) {
        JComboBox<String> combo = new JComboBox<>(items);
        if (current != null) combo.setSelectedItem(current);
        return combo;
    }

    public static JComboBox<String> createDBCombo(String table, String idCol, String nameCol, String current) {
        Vector<String> data = new Vector<>();
        try (Connection conn = DBConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT " + idCol + ", " + nameCol + " FROM " + table)) {
            while (rs.next()) data.add(rs.getString(1) + " - " + rs.getString(2));
        } catch (SQLException e) { e.printStackTrace(); }

        JComboBox<String> combo = new JComboBox<>(data);
        selectInCombo(combo, current);
        return combo;
    }



    public static JComboBox<String> createJoinedWorkerCombo(String roleTable, String current) {
        Vector<String> data = new Vector<>();

        String roleID = "";
        if (roleTable.equals("driver")) {
            roleID = "drv_AT";
        } else if (roleTable.equals("guide")) {
            roleID = "gui_AT";
        } else if (roleTable.equals("admin")) {
            roleID = "adm_AT";
        } else {

            roleID = roleTable.substring(0, 3) + "_AT";
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT t.").append(roleID).append(", w.wrk_lname ");
        sql.append("FROM ").append(roleTable).append(" t ");
        sql.append("JOIN worker w ON t.").append(roleID).append(" = w.wrk_AT ");


        // Ελέγχουμε αν ο Οδηγός ή ο Ξεναγός είναι ήδη σε "ACTIVE" ταξίδι
        if (roleTable.equals("driver")) {
            sql.append("WHERE t.").append(roleID).append(" NOT IN ");
            sql.append("(SELECT tr_drv_at FROM trip WHERE tr_status = 'ACTIVE' AND tr_drv_at IS NOT NULL)");
        } else if (roleTable.equals("guide")) {
            sql.append("WHERE t.").append(roleID).append(" NOT IN ");
            sql.append("(SELECT tr_gui_at FROM trip WHERE tr_status = 'ACTIVE' AND tr_gui_at IS NOT NULL)");
        }


        try (Connection conn = DBConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql.toString())) {

            while (rs.next()) {
                data.add(rs.getString(1) + " - " + rs.getString(2));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        JComboBox<String> combo = new JComboBox<>(data);
        selectInCombo(combo, current);
        return combo;
    }

    private static void selectInCombo(JComboBox<String> combo, String valueToFind) {
        if (valueToFind == null || valueToFind.isEmpty()) return;
        for (int i = 0; i < combo.getItemCount(); i++) {
            if (combo.getItemAt(i).startsWith(valueToFind + " -") || combo.getItemAt(i).equals(valueToFind)) {
                combo.setSelectedIndex(i);
                break;
            }
        }
    }




    public static JComboBox<String> createSmartVehicleCombo(int minCapacity) {
        Vector<String> data = new Vector<>();

        // Φέρνουμε μόνο τα ΔΙΑΘΕΣΙΜΑ που ΧΩΡΑΝΕ τους επιβάτες
        String sql = "SELECT veh_id, veh_traffic_number, veh_capacity, veh_type " +
                "FROM vehicle " +
                "WHERE veh_status = 'AVAILABLE' AND veh_capacity >= ?";

        try (Connection conn = DBConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, minCapacity);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {

                    String label = rs.getString("veh_id") + " - " +
                            rs.getString("veh_traffic_number") +
                            " (" + rs.getString("veh_type") + ", Seats: " + rs.getInt("veh_capacity") + ")";
                    data.add(label);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Αν δεν βρεθεί κανένα όχημα, βάζουμε ένα ενημερωτικό μήνυμα
        if (data.isEmpty()) {
            data.add("Κανένα διαθέσιμο όχημα με επαρκή χωρητικότητα");
        }

        return new JComboBox<>(data);
    }
}
