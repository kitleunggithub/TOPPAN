package dash.properties;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Properties;

public class ConfigGen {

    public static void main(String[] args) {

        try (OutputStream output = new FileOutputStream("config.properties")) {

            Properties prop = new Properties();

            // set the properties value
            prop.setProperty("db.driver", "<ORACLE,SQLSERVER,MYSQL>");
            prop.setProperty("db.url", "<JDBC_URL>");
            prop.setProperty("db.user", "<DB_LOGIN>");
            prop.setProperty("db.password", "<PASSWORD>");
            // save properties to project root folder
            prop.store(output, null);

            System.out.println(prop);

        } catch (IOException io) {
            io.printStackTrace();
        }

    }
}
