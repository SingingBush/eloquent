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
        immutable auto logFile = properties.as!(string)("log.file", "eloquent-server.log");
        immutable auto logLevel = properties.as!(string)("log.level", "info");

        setLogFormat(FileLogger.Format.threadTime, FileLogger.Format.threadTime); // plain, thread, or threadTime

        LogLevel level;

        switch(logLevel) {
            case "verbose":
                level = LogLevel.debugV;
                setLogFile(logFile, LogLevel.debugV);
                break;
            case "debug":
                level = LogLevel.debug_;
                setLogFile(logFile, LogLevel.debug_);
                break;
            case "trace":
                level = LogLevel.trace;
                setLogFile(logFile, LogLevel.trace);
                break;
            case "error":
                level = LogLevel.error;
                setLogFile(logFile, LogLevel.error);
                break;
            default:
                level = LogLevel.info;
                setLogFile(logFile, LogLevel.info);
                break;
        }

        setLogLevel(LogLevel.none); // this effectively deactivates vibe.d's stdout logger

        // now register a custom Logger that's nicer than the one provided by vibe.d (and outputs correct time)
        auto console = cast(shared)new ConsoleLogger(level);
        registerLogger(console);

        logInfo("PoodinisContext -> Logging Configured [%s] will be output to: %s", logLevel, logFile);

        // todo: consider options for HTML Logger and SyslogLogger, see: https://github.com/rejectedsoftware/vibe.d/blob/master/source/vibe/core/log.d
//        auto logger = cast(shared)new HTMLLogger("log.html");
//        registerLogger(logger);
    }
}


import std.stdio;
import consoled;

final class ConsoleLogger : Logger {

    alias Debug = ColorTheme!(Color.blue, Color.initial);
    alias Info = ColorTheme!(Color.lightGray, Color.initial);
    alias Error = ColorTheme!(Color.red, Color.initial);
    alias ReallyBad = ColorTheme!(Color.white, Color.red);

    this(LogLevel level) {
        minLevel = level;
    }

	override void beginLine(ref LogLine msg) @trusted {
		string level;
		Color fg = foreground;
		Color bg = background;

		final switch (msg.level) {
			case LogLevel.trace:
			    level = "TRACE";
			    fg = Color.green;
			    break;
			case LogLevel.debugV:
			    level = "VERBOSE";
			    fg = Color.green;
			    break;
			case LogLevel.debug_:
                level = "DEBUG";
                fg = Color.green;
                break;
			case LogLevel.diagnostic:
			    level = "DIAGNOSTIC";
			    fg = Color.blue;
			    break;
			case LogLevel.info:
			    level = "INFO";
			    fg = Color.blue;
			    break;
			case LogLevel.warn:
			    level = "WARN";
			    fg = Color.yellow;
			    break;
			case LogLevel.error:
                level = "ERROR";
                fg = Color.red;
                break;
			case LogLevel.critical:
			    level = "CRITICAL";
			    fg = Color.white;
			    bg = Color.red;
			    break;
			case LogLevel.fatal:
			    level = "FATAL";
			    fg = Color.white;
			    bg = Color.red;
			    break;
			case LogLevel.none: assert(false);
		}

        write(Clock.currTime().toISOExtString());
        writef(" - %08X:%08X [", msg.threadID, msg.fiberID);

        foreground = fg;
        background = bg;
        writef("%s", level);
        resetColors();

        write("] - ");
	}

	override void put(scope const(char)[] text) {
		write(text);
	}

	override void endLine() {
		writeln();
	}
}