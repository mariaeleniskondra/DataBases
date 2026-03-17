import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/travel_agency_2025";
    private static final String USER = "root";
    private static final String PASSWORD = "327069milena!";

    public static Connection connect() {
        Connection conn = null;
        try {

            Class.forName("com.mysql.cj.jdbc.Driver");



            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Εγινε συνδεση στη βαση.");

        } catch (ClassNotFoundException e) {
            System.err.println("Δεν βρεθηκε ο Driver");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Δεν συνδεθηκε.Λαθος κωδικος ή URL");
            e.printStackTrace();
        }
        return conn;
    }

    public static void main(String[] args) {

        connect();
    }

}
