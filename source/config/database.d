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
			logInfo("Creating database tables...");
			factory.getDBMetaData().updateDBSchema(conn, true, true); // bools are: dropTables, createTables
		}

		immutable bool createTestData = _properties.as!(bool)("db.createTestData", false);
		if(createTestData) {
			Session session = factory.openSession();
			scope(exit) session.close();

			import std.datetime;
			SysTime now = Clock.currTime(UTC());

			User user = new User;
			user.username = "test";

			string salt = _properties.as!(string)("auth.salt");
			import vibe.crypto.passwordhash;
			string hash = generateSimplePasswordHash("password", salt);
			user.pass = hash;

			user.nicename = "Ben";
			user.displayname = "Benny";
			user.email = "test@domain.com";
			user.url = "";
			user.registered = cast(DateTime) now;
			user.status = UserStatus.DEFAULT;
			session.save(user);

			BlogPost bp = new BlogPost;
			bp.author = user;
			bp.created = cast(DateTime) now;
			bp.modified = cast(DateTime) now;
			bp.title = "Test Post 1";
			bp.content = "blah blah blah blah blah blah blah blah blah blah";
			bp.excerpt = "some post about stuff";
			bp.postType = "post";
			session.save(bp);
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
