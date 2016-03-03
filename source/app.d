

import eloquent.model.User;
import eloquent.model.BlogPost;

import properd; // for loading in app.properties
import hibernated.core;
import poodinis;
import vibe.d;

import eloquent.controllers;
import eloquent.services.UserService;
import eloquent.services.BlogService;

shared static this() {

	logInfo("loading app.properties");
	auto properties = readProperties("./app.properties");

	configureLogFile(properties);
	SessionFactoryImpl sessionFactory = configureDatabase(properties);

	auto container = DependencyContainer.getInstance();
	container.register!(SessionFactory, SessionFactoryImpl)(RegistrationOption.DO_NOT_ADD_CONCRETE_TYPE_REGISTRATION).existingInstance(sessionFactory);
	container.register!(UserService, UserServiceImpl);
	container.register!(BlogService, BlogServiceImpl);

	//container.register!WebappController;
	//auto webapp = container.resolve!WebappController;

	//WebappController webapp = new WebappController();
	//container.register!(WebappController).existingInstance(webapp);

	auto router = new URLRouter;
	router.registerWebInterface(new WebappController);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.sessionStore = new MemorySessionStore;
	settings.errorPageHandler = toDelegate(&errorPage);
	listenHTTP(settings, router);

	logInfo("Eloquent server ready...");
}

shared static ~this() {
	logInfo("Clearing all Registered dependencies...");
	DependencyContainer.getInstance().clearAllRegistrations();
	logInfo("Application shutting down - goodbye!"); // see also logError and logDiagnostic
}

void errorPage(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
    bool authenticated = false; // kludge for getting template to render when serving error page
    render!("error.dt", req, error, authenticated)(res);
}

void configureLogFile(string[string] properties) {
	auto logFile = properties.as!(string)("log.file", "eloquent-error.log");
	//auto logLevel = properties.as!(string)("log.level");
	//logInfo("setting log file: %s, level %s", logFile, logLevel);
	setLogFile(logFile, LogLevel.error);
}

SessionFactoryImpl configureDatabase(string[string] properties) {
	auto dbHost = properties.as!(string)("db.domain", "localhost");
	auto dbPort = properties.as!(ushort)("db.port", 3306);
	auto dbName = properties.as!(string)("db.name");
	auto dbUser = properties.as!(string)("db.user");
	auto dbPass = properties.as!(string)("db.password");
	logInfo("db properties: %s:%s %s", dbHost, dbPort, dbName);

	logInfo("connecting to MySQL...");
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