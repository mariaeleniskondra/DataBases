
import javax.swing.*;

public class Member2 {

    public static JComponent getCustomField(String tableName, String colName, String currentValue) {
        tableName = tableName.toLowerCase();
        colName = colName.toLowerCase();


        if (tableName.equals("driver")) {

            if (colName.equals("drv_licence")) {
                return LogicRouter.createCombo(new String[]{"A", "B", "C", "D"}, currentValue);
            }

            if (colName.equals("drv_route")) {
                return LogicRouter.createCombo(new String[]{"LOCAL", "ABROAD"}, currentValue);
            }

        }
        if (tableName.equals("trip") && colName.equals("tr_status"))
            return LogicRouter.createCombo(new String[]{"PLANNED", "CONFIRMED", "ACTIVE", "COMPLETED", "CANCELLED"}, currentValue);

        if (tableName.equals("vehicle") && colName.equals("veh_type"))
            return LogicRouter.createCombo(new String[]{"BUS", "MINI BUS", "VAN", "CAR"}, currentValue);

        if (colName.equals("tr_veh_id"))
            return LogicRouter.createDBCombo("vehicle", "veh_id", "veh_traffic_number", currentValue);

        if (tableName.equals("vehicle") && colName.equals("veh_status"))
            return LogicRouter.createCombo(new String[]{"AVAILABLE", "UNDER MAINTENANCE", "IN USE"}, currentValue);


        //mh diathesimoi odigoi
        if (colName.equals("tr_drv_at"))
            return LogicRouter.createJoinedWorkerCombo("driver", currentValue);

        if (colName.equals("tr_gui_at"))
            return LogicRouter.createJoinedWorkerCombo("guide", currentValue);

        return null;
    }
}