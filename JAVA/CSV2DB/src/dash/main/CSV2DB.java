package dash.main;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.io.File;
import java.io.FileInputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;
import java.util.concurrent.TimeUnit;

import dash.util.CSVLoader;
import dash.util.CryptoUtil;

public class CSV2DB {

	private static String JDBC_CONNECTION_URL = "";
	
	public static Properties loadPropertiesFile() throws Exception {

		Properties prop = new Properties();
		InputStream in = new FileInputStream("config.properties");
		prop.load(in);
		in.close();
		return prop;
	}	
	
	public static void main(String[] args) {
		try {
			for(int i=0;i<args.length;i++)
			{
				System.out.println("arg["+i+"]="+args[i]); 	  
			}  
			
			String filePath = args[0];
			String fileName = args[1];
			String tableName = args[2];
			//boolean deleteBeforeLoad = Boolean.parseBoolean(args[3]);
			boolean deleteBeforeLoad = false;
			if (args[3].equalsIgnoreCase("Y")) {
				deleteBeforeLoad = true;
			}
			//boolean houseKeepJob = Boolean.parseBoolean(args[4]);
			boolean houseKeepJob = false;
			if (args[4].equalsIgnoreCase("Y")) {
				houseKeepJob = true;
			}
			
			String os = System.getProperty("os.name").toLowerCase();
			String absoluteFilePath = "";
			String archFilePath = "";
			String absoluteArchFilePath = "";
			
	        if (os.indexOf("win") >= 0) {
	            //if windows
	        	if (filePath.endsWith("\\") == false) {
	        			filePath += "\\";
	        	}
	        	archFilePath = filePath + "archive\\";
	        } else if (os.indexOf("nix") >= 0 ||
                       os.indexOf("nux") >= 0 || 
                       os.indexOf("mac") >= 0) 
	        {           
	            //if unix or mac 
	        	if (filePath.endsWith("/") == false) {
	        		filePath += "/"; 
	        	}
	        	archFilePath = filePath + "archive/";
	        } else {
	            //unknow os?
	        	if (filePath.endsWith("/") == false) {
        			filePath += "/";
	        	}	                
	        	archFilePath = filePath + "archive/";
	        }			

	        absoluteArchFilePath = archFilePath + fileName;;
			absoluteFilePath = filePath + fileName;;	        
	        
			CSVLoader loader = new CSVLoader(getCon());
			
			Calendar calendar = Calendar.getInstance();
			SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
			SimpleDateFormat formatter2 = new SimpleDateFormat("yyyyMMddHHmmss");
			System.out.println("Start Load CSV File:" + formatter2.format(calendar.getTime()));
			//loader.loadCSV("C:\\Eclipse\\workspace\\CSV2DB\\test.csv", "XXTEST_CSV", false);
			loader.loadCSV(absoluteFilePath, tableName, deleteBeforeLoad);
			
			calendar = Calendar.getInstance();
			System.out.println("End Load CSV File:" + formatter2.format(calendar.getTime()));
			
			System.out.println("File Upload -- Done");
			
			Files.move(Paths.get(absoluteFilePath), Paths.get(absoluteArchFilePath+"."+formatter.format(calendar.getTime())), StandardCopyOption.REPLACE_EXISTING);
			
			System.out.println("Archive File -- Done");
			
			if (houseKeepJob) {
				cleanUpOldFiles(archFilePath,30);
				System.out.println("Clean Up Old Files -- Done");
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(-1);
		}
	}

	private static Connection getCon() throws Exception {
		Connection connection = null;
		try {
			CryptoUtil cryptoUtil=new CryptoUtil();
			
			Properties prop = loadPropertiesFile();

			String driverClass = prop.getProperty("db.driver");
			String url = prop.getProperty("db.url");
			String username = prop.getProperty("db.user");
			String password = cryptoUtil.decrypt("DASH",prop.getProperty("db.password"));
			//String password = prop.getProperty("db.password");
			if (driverClass.equalsIgnoreCase("ORACLE"))
			{
				Class.forName("oracle.jdbc.driver.OracleDriver");
				//JDBC_CONNECTION_URL = "jdbc:oracle:thin://@"+url+":"+port+dbname;
			}
			else if (driverClass.equalsIgnoreCase("MYSQL"))
			{
				Class.forName("com.mysql.jdbc.Driver");
				//JDBC_CONNECTION_URL = "jdbc:mysql://"+url+":"+port+"/"+dbname+"?"+dbprops;				
			}
			else if (driverClass.equalsIgnoreCase("SQLSERVER"))
			{
				Class.forName("com.sqlserver.jdbc.driver");
			}
			else
			{
			    throw new Exception("Invalid driverClass["+driverClass+"].");
			}
			JDBC_CONNECTION_URL = url;
			connection = DriverManager.getConnection(url,username,password);

		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return connection;
	}
	
	public static void cleanUpOldFiles(String folderPath, int expirationPeriod) {
	    File targetDir = new File(folderPath);
	    if (!targetDir.exists()) {
	        throw new RuntimeException(String.format("Log files directory '%s' " +
	                "does not exist in the environment", folderPath));
	    }

	    File[] files = targetDir.listFiles();
	    for (File file : files) {
	        long diff = new Date().getTime() - file.lastModified();

	        // Granularity = DAYS;
	        long desiredLifespan = TimeUnit.DAYS.toMillis(expirationPeriod); 

	        if (diff > desiredLifespan) {
	            file.delete();
	            System.out.println("Deleted File: "+file.getName());
	        }
	    }
	}

}
