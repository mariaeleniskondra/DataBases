import javax.swing.*;

public class Member3 {

    public static JComponent getCustomField(String tableName, String colName, String currentValue) {
        tableName = tableName.toLowerCase();
        colName = colName.toLowerCase();

        // --- BRANCH ---
        if (tableName.equals("branch")) {
            if (colName.equals("br_manager_at"))
                return LogicRouter.createDBCombo("admin", "adm_AT", "adm_type", currentValue);
        }

        // --- WORKER ---
        if (tableName.equals("worker")) {
            if (colName.equals("wrk_br_code"))
                return LogicRouter.createDBCombo("branch", "br_code", "br_street", currentValue);
        }

        // --- ADMIN ---
        if (tableName.equals("admin")) {
            if (colName.equals("adm_type"))
                return LogicRouter.createCombo(new String[]{"LOGISTICS", "ADMINISTRATIVE", "ACCOUNTING"}, currentValue);
        }


        // --- DESTINATION ---
        if (tableName.equals("destination")) {
            if (colName.equals("dst_rtype"))
                return LogicRouter.createCombo(new String[]{"LOCAL", "ABROAD"}, currentValue);
            if (colName.equals("dst_language_code"))
                return LogicRouter.createDBCombo("language_ref", "lang_code", "lang_name", currentValue);
            if (colName.equals("dst_location"))
                return LogicRouter.createDBCombo("destination", "dst_id", "dst_name", currentValue);
        }

        // --- TRAVEL_TO (Απαίτηση 3.2.2: Dropdown για Destination) ---
        if (tableName.equals("travel_to")) {
            if (colName.equals("to_dst_id"))
                return LogicRouter.createDBCombo("destination", "dst_id", "dst_name", currentValue);
            if (colName.equals("to_tr_id"))
                return LogicRouter.createDBCombo("trip", "tr_id", "tr_departure", currentValue);
        }

        // --- EVENT ---
        if (tableName.equals("event")) {
            if (colName.equals("ev_tr_id"))
                return LogicRouter.createDBCombo("trip", "tr_id", "tr_departure", currentValue);
        }

        // --- LANGUAGES ---
        if (tableName.equals("languages")) {
            if (colName.equals("lng_gui_at"))
                return LogicRouter.createJoinedWorkerCombo("guide", currentValue);
            if (colName.equals("lng_language_code"))
                return LogicRouter.createDBCombo("language_ref", "lang_code", "lang_name", currentValue);
        }

        // --- DATABASE_ADMIN ---
        if (tableName.equals("database_admin")) {
            if (colName.equals("dbadmin_at"))
                return LogicRouter.createDBCombo("admin", "adm_AT", "adm_type", currentValue);
        }

        // --- MANAGES ---
        if (tableName.equals("manages")) {
            if (colName.equals("mng_adm_at"))
                return LogicRouter.createDBCombo("admin", "adm_AT", "adm_type", currentValue);
            if (colName.equals("mng_br_code"))
                return LogicRouter.createDBCombo("branch", "br_code", "br_street", currentValue);
        }

        // --- PHONES ---
        if (tableName.equals("phones")) {
            if (colName.equals("ph_br_code"))
                return LogicRouter.createDBCombo("branch", "br_code", "br_street", currentValue);
        }

        return null; // Δεν είναι δική μου ευθύνη
    }
}