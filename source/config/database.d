module eloquent.config.database;

import hibernated.core;
import poodinis.autowire;
import vibe.core.log; // only the logger is needed

import eloquent.config.properties;
import eloquent.model.user, eloquent.model.blogpost, eloquent.model.comment;

interface EloquentDatabase {
	SessionFactoryImpl configure();
}

class EloquentDatabaseImpl : EloquentDatabase {

	@Autowire
	private Properties _properties;

	public this() {
		logInfo("configuring Eloquent database");
	}

	//@Component
	SessionFactoryImpl configure() {

		DataSource dataSource;
		Dialect dialect;

		immutable string dbType = _properties.as!(string)("db.dialect");

		import std.regex : toUpper;

		final switch(dbType.toUpper) {
			case "SQLITE":
				version(USE_SQLITE) {
					dataSource = createSQLiteDataSource();
					dialect = new SQLiteDialect();
				} else {
					logError("DB configured for SQLite dialect but SQLite was not enabled in the build");
				}
				break;
			case "MYSQL":
				version(USE_MYSQL) {
					dataSource = createMySQLDataSource();
					dialect = new MySQLDialect();
				} else {
					logError("DB configured for MySQL dialect but MySQL was not enabled in the build");
				}
				break;
		}

		logDebug("Creating schema meta data from annotations...");
		EntityMetaData schema = new SchemaInfoImpl!(User, UserData, BlogPost, BlogPostData, Comment, CommentData);

		logDebug("Creating session factory...");
		SessionFactoryImpl factory = new SessionFactoryImpl(schema, dialect, dataSource);

		immutable bool createSchema = _properties.as!(bool)("db.createSchema", false);
		if(createSchema) {
			Connection conn = dataSource.getConnection();
			scope(exit) conn.close();
			// create tables if not exist
			logDebug("Creating database tables...");
			factory.getDBMetaData().updateDBSchema(conn, false, true);
		}
		return factory;
	}

    version(USE_SQLITE) {
    	private DataSource createSQLiteDataSource() {
    		auto sqliteFile = _properties.as!(string)("db.file");
    		logInfo("PoodinisContext -> loading SQLite file...  %s", sqliteFile);
    		SQLITEDriver driver = new SQLITEDriver();
    		return new ConnectionPoolDataSourceImpl(driver, sqliteFile, null);
    	}
    }

    version(USE_MYSQL) {
    	private DataSource createMySQLDataSource() {
    		auto dbHost = _properties.as!(string)("db.domain", "localhost");
    		auto dbPort = _properties.as!(ushort)("db.port", 3306);
    		auto dbName = _properties.as!(string)("db.name");
    		auto dbUser = _properties.as!(string)("db.user");
    		auto dbPass = _properties.as!(string)("db.password");

    		logInfo("PoodinisContext -> connecting to MySQL...  %s@%s:%s/%s", dbUser, dbHost, dbPort, dbName);

    		MySQLDriver driver = new MySQLDriver();
    		string url = MySQLDriver.generateUrl(dbHost, dbPort, dbName);
    		string[string] params = MySQLDriver.setUserAndPassword(dbUser, dbPass);
    		return new ConnectionPoolDataSourceImpl(driver, url, params);
    	}
    }
}
