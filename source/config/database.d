module eloquent.config.database;

private import hibernated.core;
private import poodinis.autowire;
private import vibe.core.log; // only the logger is needed

private import eloquent.config.properties;
private import eloquent.model.user, eloquent.model.blogpost, eloquent.model.comment;

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

		static if(__VERSION__ < 2085) {
			import std.regex : toUpper;
		} else {
			import std.string : toUpper; // previously had:		import std.uni : toUpper;
		}

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
			logInfo("Creating database tables...");
			factory.getDBMetaData().updateDBSchema(conn, true, true); // bools are: dropTables, createTables
		}

		immutable bool createTestData = _properties.as!(bool)("db.createTestData", false);
		if(createTestData) {
			Session session = factory.openSession();
			scope(exit) session.close();

			import std.datetime;
			immutable SysTime now = Clock.currTime(UTC());

			User user = new User;
			user.username = "test";

			//string salt = _properties.as!(string)("auth.salt"); // todo: use salt again?

			// SHA 3:
			import sha3d.sha3 : sha3_256Of;
			import std.digest : toHexString;

			user.pass = toHexString(sha3_256Of("password"));

			user.nicename = "Ben";
			user.displayname = "Benny";
			user.email = "test@domain.com";
			user.url = "";
			user.registered = cast(DateTime) now;
			user.status = UserStatus.DEFAULT;
			session.save(user);
			logInfo("Created user: %s", user);

			User adminUser = new User;
			adminUser.username = "admin";
			adminUser.pass = toHexString(sha3_256Of("password"));
			adminUser.nicename = "Administrator";
			adminUser.displayname = "Administrator";
			adminUser.email = "admin@domain.com";
			adminUser.url = "";
			adminUser.registered = cast(DateTime) now;
			adminUser.status = UserStatus.DEFAULT;
			session.save(adminUser);
			logInfo("Created user: %s", adminUser);

			UserData adminMetaData = new UserData;
			adminMetaData.user = adminUser;
			adminMetaData.key = "wp_user_level";
			adminMetaData.value = "10";
			session.save(adminMetaData);

			BlogPost bp = new BlogPost;
			bp.author = user;
			bp.created = cast(DateTime) now;
			bp.modified = cast(DateTime) now;
			bp.title = "Lorem ipsum";
			bp.content = "Lorem ipsum dolor sit amet, ius eu suscipit honestatis consequuntur, velit cotidieque at eam.";
			bp.excerpt = "ius eu suscipit honestatis consequuntur";
			bp.type = "post";
			session.save(bp);
			logInfo("Created BlogPost: %s", bp);
		}
		return factory;
	}

    version(USE_SQLITE) {
    	private DataSource createSQLiteDataSource() {
    		auto sqliteFile = _properties.as!(string)("db.file");
    		logInfo("PoodinisContext -> loading SQLite file...  %s", sqliteFile);
    		import ddbc.drivers.sqliteddbc : SQLITEDriver;
    		return new ConnectionPoolDataSourceImpl(new SQLITEDriver(), sqliteFile, null);
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

			import ddbc.drivers.mysqlddbc : MySQLDriver;
    		string url = MySQLDriver.generateUrl(dbHost, dbPort, dbName);
    		string[string] params = MySQLDriver.setUserAndPassword(dbUser, dbPass);
    		return new ConnectionPoolDataSourceImpl(new MySQLDriver(), url, params);
    	}
    }
}
