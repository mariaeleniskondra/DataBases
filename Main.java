import javax.swing.*;
import javax.swing.UIManager.LookAndFeelInfo;

public class Main {
    public static void main(String[] args) {

        try {
            for (LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (Exception e) {

        }

        SwingUtilities.invokeLater(() -> {
            MainMenu frame = new MainMenu();
            frame.setVisible(true);
        });
    }
}

