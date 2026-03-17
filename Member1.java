import javax.swing.*;

public class Member1 {

    public static JComponent getCustomField(String tableName, String colName, String currentValue) {

        // --- ΠΙΝΑΚΑΣ RESERVATION ---
        if (tableName.equals("reservation")) {

            if (colName.equals("res_tr_id")) {
                return LogicRouter.createDBCombo("trip", "tr_id", "tr_departure", currentValue);
            }
            if (colName.equals("res_cust_id")) {
                return LogicRouter.createDBCombo("customer", "cust_id", "cust_lname", currentValue);
            }
            if (colName.equals("res_status")) {
                return LogicRouter.createCombo(new String[]{"PENDING", "CONFIRMED", "PAID", "CANCELLED"}, currentValue);
            }
        }

        // --- ΠΙΝΑΚΑΣ ACCOMMODATION ---
        if (tableName.equals("accommodation")) {

            if (colName.equals("acc_type")) {
                return LogicRouter.createCombo(new String[]{"HOTEL", "HOSTEL", "RESORT", "APARTMENT", "ROOMS_TO_RENT"}, currentValue);
            }

            if (colName.equals("acc_status")) {
                return LogicRouter.createCombo(new String[]{"AVAILABLE", "UNAVAILABLE"}, currentValue);
            }

            // Λόγος που είναι ανενεργό
            if (colName.equals("acc_inactive")) {
                return LogicRouter.createCombo(new String[]{"", "RENOVATION", "CLOSE", "OTHER REASON"}, currentValue);
            }

            // Σύνδεση με Προορισμό
            if (colName.equals("acc_dst_id")) {
                return LogicRouter.createDBCombo("destination", "dst_id", "dst_name", currentValue);
            }


            if (colName.equals("acc_wifi") || colName.equals("acc_restaurant_bar") ||
                    colName.equals("acc_ac") || colName.equals("acc_accesibility")) {
                return LogicRouter.createCombo(new String[]{"1 - Yes", "0 - No"}, currentValue);
            }
        }

        return null;
    }
}