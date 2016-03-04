module eloquent.config.context;

import properd; // for loading in app.properties
import hibernated.core;
import poodinis;
import vibe.d;

import eloquent.model.User;
import eloquent.model.BlogPost;
import eloquent.services.UserService;
import eloquent.services.BlogService;

class PoodinisContext : ApplicationContext {

    public override void registerDependencies(shared(DependencyContainer) container) {
        logInfo("loading app.properties");
        auto properties = readProperties("./app.properties");

        configureLogFile(properties);
        SessionFactoryImpl sessionFactory = configureDatabase(properties);

        container.register!(SessionFactory, SessionFactoryImpl)([RegistrationOption.doNotAddConcreteTypeRegistration]).existingInstance(sessionFactory);
        container.register!(UserService, UserServiceImpl);
        container.register!(BlogService, BlogServiceImpl);
    }

    //@Component
    SessionFactoryImpl configureDatabase(string[string] properties) {
    	auto dbHost = properties.as!(string)("db.domain", "localhost");
    	auto dbPort = properties.as!(ushort)("db.port", 3306);
    	auto dbName = properties.as!(string)("db.name");
    	auto dbUser = properties.as!(string)("db.user");
    	auto dbPass = properties.as!(string)("db.password");

    	logInfo("connecting to MySQL...  %s@%s:%s/%s", dbUser, dbHost, dbPort, dbName);

    	MySQLDriver driver = new MySQLDriver();
    	string url = MySQLDriver.generateUrl(dbHost, dbPort, dbName);
    	string[string] params = MySQLDriver.setUserAndPassword(dbUser, dbPass);
    	DataSource dataSource = new ConnectionPoolDataSourceImpl(driver, url, params);
    	Dialect dialect = new MySQLDialect();

    	logDebug("Creating schema meta data from annotations...");
    	EntityMetaData schema = new SchemaInfoImpl!(User, UserData, BlogPost, BlogPostData);

    	logDebug("Creating session factory...");
    	return new SessionFactoryImpl(schema, dialect, dataSource);
    }

    private void configureLogFile(string[string] properties) {
        auto logFile = properties.as!(string)("log.file", "eloquent-error.log");
        //auto logLevel = properties.as!(string)("log.level");
        //logInfo("setting log file: %s, level %s", logFile, logLevel);
        setLogFile(logFile, LogLevel.error);
    }
}