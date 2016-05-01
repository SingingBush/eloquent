module eloquent.config.context;

import hibernated.core;
import poodinis;
import vibe.d;

import eloquent.config.properties;
import eloquent.model.user, eloquent.model.blogpost, eloquent.model.comment;
import eloquent.services.userservice, eloquent.services.blogservice;

class PoodinisContext : ApplicationContext {

    private Properties properties;

    public this() {
        properties = new Properties;
    }

    public override void registerDependencies(shared(DependencyContainer) container) {
        configureLogging();
        logInfo("Creating Poodinis Context");
        container.register!Properties.existingInstance(properties);

        SessionFactoryImpl sessionFactory = configureDatabase();

        container.register!(SessionFactory, SessionFactoryImpl)([RegistrationOption.doNotAddConcreteTypeRegistration]).existingInstance(sessionFactory);
        container.register!(UserService, UserServiceImpl);
        container.register!(BlogService, BlogServiceImpl);
    }

    //@Component
    SessionFactoryImpl configureDatabase() {
    	auto dbHost = properties.as!(string)("db.domain", "localhost");
    	auto dbPort = properties.as!(ushort)("db.port", 3306);
    	auto dbName = properties.as!(string)("db.name");
    	auto dbUser = properties.as!(string)("db.user");
    	auto dbPass = properties.as!(string)("db.password");

    	logInfo("PoodinisContext -> connecting to MySQL...  %s@%s:%s/%s", dbUser, dbHost, dbPort, dbName);

    	MySQLDriver driver = new MySQLDriver();
    	string url = MySQLDriver.generateUrl(dbHost, dbPort, dbName);
    	string[string] params = MySQLDriver.setUserAndPassword(dbUser, dbPass);
    	DataSource dataSource = new ConnectionPoolDataSourceImpl(driver, url, params);
    	Dialect dialect = new MySQLDialect();

    	logDebug("Creating schema meta data from annotations...");
    	EntityMetaData schema = new SchemaInfoImpl!(User, UserData, BlogPost, BlogPostData, Comment, CommentData);

    	logDebug("Creating session factory...");
    	return new SessionFactoryImpl(schema, dialect, dataSource);
    }

    private void configureLogging() {
        auto logFile = properties.as!(string)("log.file", "eloquent-error.log");
        //auto logLevel = properties.as!(string)("log.level");
        setLogFormat(FileLogger.Format.threadTime, FileLogger.Format.threadTime); // plain, thread, or threadTime
        logInfo("PoodinisContext -> setting log file: %s", logFile);
        setLogFile(logFile, LogLevel.error);
    }
}