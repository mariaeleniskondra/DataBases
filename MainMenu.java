import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.border.CompoundBorder;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.JTableHeader;
import java.awt.*;
import java.sql.*;
import java.util.Vector;
import java.util.List;
import java.util.ArrayList;

public class MainMenu extends JFrame {

    private JComboBox<String> tableSelector;
    private JTable dataTable;
    private DefaultTableModel tableModel;
    private JButton btnInsert, btnUpdate, btnDelete;
    private JButton btnAssignVehicle;

    private final Color SIDEBAR_COLOR = new Color(102, 51, 153);
    private final Color TEXT_COLOR = Color.WHITE;
    private final Font MAIN_FONT = new Font("Segoe UI", Font.PLAIN, 14);

    public MainMenu() {
        // --- Setup Window ---
        setTitle("Travel Agency 2025 - Modular Edition");
        setSize(1250, 800);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        // --- Sidebar ---
        JPanel sidebarPanel = new JPanel();
        sidebarPanel.setBackground(SIDEBAR_COLOR);
        sidebarPanel.setPreferredSize(new Dimension(320, 0));
        sidebarPanel.setLayout(new BoxLayout(sidebarPanel, BoxLayout.Y_AXIS));
        sidebarPanel.setBorder(new EmptyBorder(30, 30, 30, 30));

        JLabel lblTitle = new JLabel("TRAVEL AGENCY");
        lblTitle.setForeground(TEXT_COLOR);
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 24));
        lblTitle.setAlignmentX(Component.LEFT_ALIGNMENT);

        JLabel lblYear = new JLabel("2025");
        lblYear.setForeground(new Color(200, 200, 250));
        lblYear.setFont(new Font("Segoe UI", Font.BOLD, 20));
        lblYear.setAlignmentX(Component.LEFT_ALIGNMENT);

        JLabel lblSelect = new JLabel("Επιλογή Πίνακα:");
        lblSelect.setForeground(TEXT_COLOR);
        lblSelect.setFont(new Font("Segoe UI", Font.BOLD, 14));
        lblSelect.setAlignmentX(Component.LEFT_ALIGNMENT);

        tableSelector = new JComboBox<>();
        tableSelector.setMaximumSize(new Dimension(Integer.MAX_VALUE, 40));
        tableSelector.setFont(MAIN_FONT);
        fillTableSelector();
        tableSelector.addActionListener(e -> {
            if(tableSelector.getSelectedItem() != null) loadTableData((String)tableSelector.getSelectedItem());
        });
        tableSelector.setAlignmentX(Component.LEFT_ALIGNMENT);

        btnInsert = createSidebarButton("Insert");
        btnUpdate = createSidebarButton("Update");
        btnDelete = createSidebarButton("Delete");
        btnAssignVehicle = createSidebarButton(" Assign Vehicle");

        btnInsert.addActionListener(e -> showForm(true));
        btnUpdate.addActionListener(e -> showForm(false));
        btnDelete.addActionListener(e -> deleteAction());
        btnAssignVehicle.addActionListener(e -> showAssignmentDialog());



        // Layout
        sidebarPanel.add(lblTitle); sidebarPanel.add(lblYear);
        sidebarPanel.add(Box.createVerticalStrut(50));
        sidebarPanel.add(lblSelect); sidebarPanel.add(Box.createVerticalStrut(10));
        sidebarPanel.add(tableSelector); sidebarPanel.add(Box.createVerticalGlue());
        sidebarPanel.add(btnInsert); sidebarPanel.add(Box.createVerticalStrut(15));
        sidebarPanel.add(btnUpdate); sidebarPanel.add(Box.createVerticalStrut(15));
        sidebarPanel.add(btnDelete); sidebarPanel.add(Box.createVerticalStrut(20));
        sidebarPanel.add(btnAssignVehicle);
        sidebarPanel.add(Box.createVerticalStrut(20));

        add(sidebarPanel, BorderLayout.WEST);

        // --- Table ---
        tableModel = new DefaultTableModel();
        dataTable = new JTable(tableModel);
        styleTable();
        add(new JScrollPane(dataTable), BorderLayout.CENTER);

        setLocationRelativeTo(null);
    }

    // --- FORM LOGIC (Calls LogicRouter) ---
    private void showForm(boolean isInsert) {
        String tableName = (String) tableSelector.getSelectedItem();
        if (tableName == null) return;

        int selectedRow = -1;
        if (!isInsert) {
            selectedRow = dataTable.getSelectedRow();
            if (selectedRow == -1) { JOptionPane.showMessageDialog(this, "Επιλέξτε γραμμή."); return; }
        }

        JPanel panel = new JPanel(new GridLayout(0, 1, 5, 5));
        List<JComponent> inputFields = new ArrayList<>();
        List<String> columnNames = new ArrayList<>();
        String pkColName = getPrimaryKeyColumn(tableName);

        try (Connection conn = DBConnection.connect()) {
            ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM " + tableName + " LIMIT 1");
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();

            for (int i = 1; i <= columnCount; i++) {
                String colName = metaData.getColumnName(i);
                columnNames.add(colName);
                panel.add(new JLabel(colName + ":"));

                String currentStr = "";
                if (!isInsert) {
                    Object val = dataTable.getValueAt(selectedRow, i - 1);
                    currentStr = (val != null) ? val.toString() : "";
                }

                // *** ΤΟ ΣΗΜΑΝΤΙΚΟ: ΚΑΛΟΥΜΕ ΤΟΝ LOGIC ROUTER ***
                // Το MainMenu δεν ξέρει τίποτα για Dropdowns. Ρωτάει τον Router.
                JComponent customField = LogicRouter.getComponentFor(tableName, colName, currentStr);

                if (customField != null) {
                    if (  tableName.equalsIgnoreCase("trip") && colName.equalsIgnoreCase("tr_veh_id")) {
                        customField.setEnabled(false); // Το κάνουμε γκρι (ανενεργό)
                        customField.setToolTipText("Για αλλαγή οχήματος χρησιμοποιήστε το κουμπί 'Assign Vehicle' στο μενού.");
                    }
                    panel.add(customField);
                    inputFields.add(customField);
                } else {
                    // Default behavior
                    JTextField tf = new JTextField(currentStr, 20);
                    if (isInsert && metaData.isAutoIncrement(i)) {
                        tf.setText("(Auto)"); tf.setEditable(false);
                    } else if (!isInsert && colName.equalsIgnoreCase(pkColName)) {
                        tf.setEditable(false); tf.setBackground(Color.LIGHT_GRAY);
                    }
                    panel.add(tf);
                    inputFields.add(tf);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); return; }

        int result = JOptionPane.showConfirmDialog(this, new JScrollPane(panel), (isInsert?"Εισαγωγή":"Τροποποίηση"), JOptionPane.OK_CANCEL_OPTION);
        if (result == JOptionPane.OK_OPTION) {
            Object pkValue = null;
            if (!isInsert && pkColName != null) {
                for (int i=0; i<dataTable.getColumnCount(); i++) {
                    if (dataTable.getColumnName(i).equalsIgnoreCase(pkColName)) {
                        pkValue = dataTable.getValueAt(selectedRow, i);
                        break;
                    }
                }
            }
            saveDataToDB(tableName, columnNames, inputFields, isInsert, pkColName, pkValue);
        }
    }

    private void saveDataToDB(String tableName, List<String> cols, List<JComponent> inputs, boolean isInsert, String pkCol, Object pkVal) {

        // Μεταβλητές για να κρατήσουμε τις ημερομηνίες που θα βρούμε
        String dateStart = null;
        String dateEnd = null;

        // Βρίσκουμε ποια ονόματα στηλών πρέπει να ψάξουμε ανάλογα με τον πίνακα
        String startColName = "";
        String endColName = "";

        if (tableName.equalsIgnoreCase("trip")) {
            startColName = "tr_departure";
            endColName = "tr_return";
        } else if (tableName.equalsIgnoreCase("travel_to")) {
            startColName = "to_arrival";
            endColName = "to_departure";
        } else if (tableName.equalsIgnoreCase("event")) {
            startColName = "ev_start";
            endColName = "ev_end";
        } else if (tableName.equalsIgnoreCase("trip_accommodation")) {
            startColName = "re_check_in";
            endColName = "re_check_out";
        }

        // --- ΕΛΕΓΧΟΣ ΔΕΔΟΜΕΝΩΝ (VALIDATION) ΠΡΙΝ ΤΗΝ ΕΚΤΕΛΕΣΗ ---
        for (int i = 0; i < inputs.size(); i++) {
            JComponent input = inputs.get(i);
            String colName = cols.get(i).toLowerCase();
            String value = "";

            if (input instanceof JTextField) value = ((JTextField) input).getText();
            else if (input instanceof JComboBox) {
                Object item = ((JComboBox) input).getSelectedItem();
                if (item != null) {
                    value = item.toString();
                    if (value.contains(" - ")) value = value.split(" - ")[0];
                }
            }

            // 1. ΕΛΕΓΧΟΣ ΑΡΙΘΜΩΝ (Να μην βάζεις γράμματα σε ποσά/νούμερα)
            if ((colName.contains("salary") || colName.contains("cost") || colName.contains("capacity") || colName.contains("seats"))
                    && !value.isEmpty() && !value.equals("(Auto)")) {
                try {
                    Double.parseDouble(value);
                } catch (NumberFormatException e) {
                    JOptionPane.showMessageDialog(this, "Το πεδίο '" + cols.get(i) + "' πρέπει να είναι αριθμός!", "Σφάλμα Εγκυρότητας", JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }

            // 2. ΕΛΕΓΧΟΣ ΗΜΕΡΟΜΗΝΙΩΝ (ΓΕΝΙΚΟΣ)
            // Αν το όνομα της στήλης ταιριάζει με αυτό που ψάχνουμε, κρατάμε την τιμή
            if (!startColName.isEmpty() && colName.equals(startColName)) {
                dateStart = value;
            }
            if (!endColName.isEmpty() && colName.equals(endColName)) {
                dateEnd = value;
            }
        }

        // Εδώ κάνουμε τη σύγκριση αν βρήκαμε και τις δύο ημερομηνίες
        if (dateStart != null && !dateStart.isEmpty() && dateEnd != null && !dateEnd.isEmpty()) {
            // Η compareTo επιστρέφει θετικό αριθμό αν το dateStart είναι μεγαλύτερο από dateEnd
            // (δηλαδή αν η Έναρξη είναι ΜΕΤΑ τη Λήξη)
            if (dateStart.compareTo(dateEnd) > 0) {
                JOptionPane.showMessageDialog(this,
                        "Λάθος Χρονική Σειρά!\nΗ ημερομηνία Λήξης/Επιστροφής (" + dateEnd + ") \nείναι ΠΡΙΝ την Έναρξη/Αναχώρηση (" + dateStart + ").",
                        "Σφάλμα Λογικής", JOptionPane.ERROR_MESSAGE);
                return; // Σταματάμε, δεν κάνουμε Save
            }
        }


        StringBuilder query = new StringBuilder();
        if (isInsert) {
            query.append("INSERT INTO ").append(tableName).append(" (");
            for(int i=0; i<cols.size(); i++) query.append(cols.get(i)).append(i<cols.size()-1?", ":"");
            query.append(") VALUES (");
            for(int i=0; i<cols.size(); i++) query.append("?").append(i<cols.size()-1?", ":"");
            query.append(")");
        } else {
            query.append("UPDATE ").append(tableName).append(" SET ");
            for(int i=0; i<cols.size(); i++) query.append(cols.get(i)).append("=?").append(i<cols.size()-1?", ":"");
            query.append(" WHERE ").append(pkCol).append("=?");
        }
        try (Connection conn = DBConnection.connect(); PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
            int paramIndex = 1;
            for (JComponent input : inputs) {
                String val = null;
                if (input instanceof JTextField) val = ((JTextField)input).getText();
                else if (input instanceof JComboBox) {
                    String s = (String)((JComboBox)input).getSelectedItem();
                    if (s != null) {
                        if (s.contains(" - ")) val = s.split(" - ")[0];
                        else val = s;
                    }
                }

                if (val != null && (val.equals("(Auto)") || val.trim().isEmpty())) {
                    pstmt.setObject(paramIndex++, null);
                } else {
                    pstmt.setObject(paramIndex++, val);
                }
            }
            if (!isInsert) pstmt.setObject(paramIndex, pkVal);

            pstmt.executeUpdate();
            JOptionPane.showMessageDialog(this, "Επιτυχία!");
            loadTableData(tableName);

        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this, "Σφάλμα SQL: " + ex.getMessage());
        }
    }



    // --- Helpers ---
    private void deleteAction() { /* Standard delete code same as before */
        int selectedRow = dataTable.getSelectedRow();
        if (selectedRow == -1) { JOptionPane.showMessageDialog(this, "Επιλέξτε γραμμή."); return; }
        String tableName = (String) tableSelector.getSelectedItem();
        String pkCol = getPrimaryKeyColumn(tableName);
        if (pkCol == null) return;
        int pkIndex = -1;
        for(int i=0; i<dataTable.getColumnCount(); i++) if(dataTable.getColumnName(i).equalsIgnoreCase(pkCol)) pkIndex = i;
        Object pkVal = dataTable.getValueAt(selectedRow, pkIndex);
        if (JOptionPane.showConfirmDialog(this, "Delete?", "Confirm", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION) {
            try (Connection c = DBConnection.connect(); PreparedStatement p = c.prepareStatement("DELETE FROM "+tableName+" WHERE "+pkCol+"=?")) {
                p.setObject(1, pkVal); p.executeUpdate(); loadTableData(tableName);
            } catch(Exception e) { JOptionPane.showMessageDialog(this, e.getMessage()); }
        }
    }
    private void fillTableSelector() {
        try(Connection c=DBConnection.connect()){ ResultSet rs=c.getMetaData().getTables(c.getCatalog(),null,"%",new String[]{"TABLE"});
            while(rs.next()) tableSelector.addItem(rs.getString("TABLE_NAME")); }
        catch
        (Exception e){}
    }
    private void loadTableData(String t) {
        tableModel.setRowCount(0); tableModel.setColumnCount(0);
        try(Connection c=DBConnection.connect(); ResultSet rs=c.createStatement().executeQuery("SELECT * FROM "+t)){ ResultSetMetaData m=rs.getMetaData();
            for(int i=1; i<=m.getColumnCount(); i++) tableModel.addColumn(m.getColumnName(i)); while(rs.next()){ Vector<Object> r=new Vector<>();
                for(int i=1; i<=m.getColumnCount(); i++) r.add(rs.getObject(i)); tableModel.addRow(r);
            }
        }catch
        (Exception e){}
    }
    private String getPrimaryKeyColumn(String t) {
        try(Connection c=DBConnection.connect()){ ResultSet rs=c.getMetaData().getPrimaryKeys(null,null,t); if(rs.next()) return rs.getString("COLUMN_NAME");
        }catch
        (Exception e){

        } return null;
    }
    private void styleTable() {
        dataTable.setFont(MAIN_FONT); dataTable.setRowHeight(30); dataTable.setGridColor(new Color(230,230,230)); JTableHeader h=dataTable.getTableHeader();
        h.setFont(new Font("Segoe UI", Font.BOLD, 14));
        h.setBackground(SIDEBAR_COLOR); h.setForeground(Color.WHITE);
        h.setOpaque(true);
    }
    private JButton createSidebarButton(String text) { JButton btn=new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 16));
        btn.setBackground(Color.WHITE);
        btn.setForeground(SIDEBAR_COLOR);
        btn.setMaximumSize(new Dimension(Integer.MAX_VALUE, 50));
        btn.setFocusPainted(false);
        btn.setBorder(new CompoundBorder(new LineBorder(SIDEBAR_COLOR, 2), new EmptyBorder(5, 15, 5, 15)));
        btn.setAlignmentX(Component.LEFT_ALIGNMENT);
        return btn;
    }




    // --- SPECIAL ACTION: ASSIGN VEHICLE (STORED PROCEDURE) ---
    // --- SPECIAL ACTION: ASSIGN VEHICLE (STORED PROCEDURE + BONUS SMART FILTER) ---
    private void showAssignmentDialog() {
        // 1. Έλεγχος: Πρέπει να είμαστε στον πίνακα TRIP
        String currentTable = (String) tableSelector.getSelectedItem();

        if (currentTable == null || !currentTable.equalsIgnoreCase("trip")) {
            JOptionPane.showMessageDialog(this, "Παρακαλώ επιλέξτε τον πίνακα TRIP για να κάνετε ανάθεση οχήματος.");
            return;
        }

        // 2. Έλεγχος: Πρέπει να έχει επιλεγεί γραμμή (Ταξίδι)
        int selectedRow = dataTable.getSelectedRow();
        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this, "Επιλέξτε ένα ταξίδι από τη λίστα.");
            return;
        }

        // 3. Έλεγχος: ΥΠΑΡΧΕΙ ΟΔΗΓΟΣ; (ΑΠΑΡΑΙΤΗΤΟ ΓΙΑ ΤΗΝ PROCEDURE)
        int driverColIndex = -1;
        for (int i = 0; i < dataTable.getColumnCount(); i++) {
            if (dataTable.getColumnName(i).equalsIgnoreCase("tr_drv_at")) {
                driverColIndex = i;
                break;
            }
        }

        if (driverColIndex != -1) {
            Object driverVal = dataTable.getValueAt(selectedRow, driverColIndex);
            if (driverVal == null || driverVal.toString().trim().isEmpty()) {
                JOptionPane.showMessageDialog(this,
                        "ΠΡΟΣΟΧΗ: Το ταξίδι δεν έχει Οδηγό!\n" +
                                "Για να λειτουργήσει ο έλεγχος διπλώματος, πρέπει πρώτα να αναθέσετε Οδηγό.\n" +
                                "Χρησιμοποιήστε το κουμπί 'Update' για να βάλετε οδηγό και ξαναδοκιμάστε.",
                        "Λείπει Οδηγός",
                        JOptionPane.WARNING_MESSAGE);
                return;
            }
        }

        // Βρίσκουμε το Trip ID
        Object trIdObj = dataTable.getValueAt(selectedRow, 0);
        int tripId = Integer.parseInt(trIdObj.toString());

        // --- BONUS LOGIC: Υπολογισμός Κρατήσεων για το φίλτρο ---
        int reservationsCount = 0;
        try (Connection conn = DBConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM reservation WHERE res_tr_id = ? AND res_status != 'CANCELLED'")) {
            pstmt.setInt(1, tripId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                reservationsCount = rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }


        // 4. Δημιουργία της Φόρμας Ανάθεσης
        JPanel panel = new JPanel(new GridLayout(0, 1, 5, 5));

        // Ενημέρωση χρήστη
        JLabel lblInfo = new JLabel("Απαιτούμενες Θέσεις (Κρατήσεις): " + reservationsCount);
        lblInfo.setForeground(new Color(0, 100, 0)); // Dark Green
        panel.add(lblInfo);

        panel.add(new JLabel("Διαθέσιμα & Κατάλληλα Οχήματα:"));

        // *** ΚΑΛΕΣΜΑ ΤΗΣ ΕΞΥΠΝΗΣ ΛΙΣΤΑΣ ***
        JComboBox<String> comboVehicles = LogicRouter.createSmartVehicleCombo(reservationsCount);
        panel.add(comboVehicles);

        panel.add(new JLabel("Τρέχοντα Χιλιόμετρα Οχήματος:"));
        JTextField tfKilometers = new JTextField();
        panel.add(tfKilometers);

        // 5. Εμφάνιση Διαλόγου
        int result = JOptionPane.showConfirmDialog(this, panel, "Smart Vehicle Assignment", JOptionPane.OK_CANCEL_OPTION);

        if (result == JOptionPane.OK_OPTION) {
            try {
                // Ανάκτηση δεδομένων
                String selectedVeh = (String) comboVehicles.getSelectedItem();

                // Αν δεν βρέθηκε όχημα ή ο χρήστης επέλεξε το μήνυμα λάθους
                if (selectedVeh == null || selectedVeh.startsWith("Κανένα")) {
                    JOptionPane.showMessageDialog(this, "Δεν επιλέχθηκε έγκυρο όχημα.");
                    return;
                }

                // Παίρνουμε το ID από το String "ID - ..."
                int vehId = Integer.parseInt(selectedVeh.split(" - ")[0]);

                String kmText = tfKilometers.getText().trim();
                if (kmText.isEmpty()) {
                    JOptionPane.showMessageDialog(this, "Παρακαλώ εισάγετε χιλιόμετρα.");
                    return;
                }
                int kilometers = Integer.parseInt(kmText);

                // Κλήση της Procedure
                callVehicleAssignmentProc(tripId, vehId, kilometers);

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this, "Παρακαλώ εισάγετε έγκυρο αριθμό χιλιομέτρων.");
            }
        }
    }
    private void callVehicleAssignmentProc(int tripId, int vehId, int kilometers) {
        // Η SQL εντολή για κλήση Procedure
        String sql = "{CALL vehicle_assignment(?, ?, ?)}";

        try (Connection conn = DBConnection.connect();
             CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setInt(1, tripId);
            stmt.setInt(2, vehId);
            stmt.setInt(3, kilometers);

            // Εκτέλεση. Η procedure επιστρέφει ResultSet με μήνυμα (SELECT 'Message'...)
            boolean hasResults = stmt.execute();

            if (hasResults) {
                try (ResultSet rs = stmt.getResultSet()) {
                    if (rs.next()) {
                        String message = rs.getString("message"); // Το alias που έβαλες στην SQL
                        JOptionPane.showMessageDialog(this, "Αποτέλεσμα Βάσης:\n" + message);

                        // Ανανέωση του πίνακα για να φανούν οι αλλαγές
                        loadTableData("trip");
                    }
                }
            }

        } catch (SQLException e) {
            // Εδώ πιάνονται και τα SIGNAL SQLSTATE '45000' που μπορεί να πετάξει η βάση (αν άλλαζες τον κώδικα της procedure)
            JOptionPane.showMessageDialog(this, "Σφάλμα Procedure: " + e.getMessage());
        }
    }

}