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

        DataSource dataSource;
        Dialect dialect;

		immutable string dbType = properties.as!(string)("db.dialect");

		final switch(dbType.toUpper) {
			case "SQLITE":
				dataSource = createSQLiteDataSource();
				dialect = new SQLiteDialect();
				break;
			case "MYSQL":
				dataSource = createMySQLDataSource();
				dialect = new MySQLDialect();
            	break;
		}

    	logDebug("Creating schema meta data from annotations...");
    	EntityMetaData schema = new SchemaInfoImpl!(User, UserData, BlogPost, BlogPostData, Comment, CommentData);

    	logDebug("Creating session factory...");
    	return new SessionFactoryImpl(schema, dialect, dataSource);
    }

    private DataSource createSQLiteDataSource() {
		auto sqliteFile = properties.as!(string)("db.file");
		logInfo("PoodinisContext -> loading SQLite file...  %s", sqliteFile);
		SQLITEDriver driver = new SQLITEDriver();
		return new ConnectionPoolDataSourceImpl(driver, sqliteFile, null);
    }

    private DataSource createMySQLDataSource() {
    	auto dbHost = properties.as!(string)("db.domain", "localhost");
		auto dbPort = properties.as!(ushort)("db.port", 3306);
		auto dbName = properties.as!(string)("db.name");
		auto dbUser = properties.as!(string)("db.user");
		auto dbPass = properties.as!(string)("db.password");

		logInfo("PoodinisContext -> connecting to MySQL...  %s@%s:%s/%s", dbUser, dbHost, dbPort, dbName);

		MySQLDriver driver = new MySQLDriver();
		string url = MySQLDriver.generateUrl(dbHost, dbPort, dbName);
		string[string] params = MySQLDriver.setUserAndPassword(dbUser, dbPass);
		return new ConnectionPoolDataSourceImpl(driver, url, params);
    }

    private void configureLogging() {
        immutable auto logFile = properties.as!(string)("log.file", "eloquent-server.log");
        immutable auto logLevel = properties.as!(string)("log.level", "info");

        setLogFormat(FileLogger.Format.threadTime, FileLogger.Format.threadTime); // plain, thread, or threadTime

        LogLevel level;

        switch(logLevel.toUpper) {
            case "VERBOSE":
                level = LogLevel.debugV;
                setLogFile(logFile, LogLevel.debugV);
                break;
            case "DEBUG":
                level = LogLevel.debug_;
                setLogFile(logFile, LogLevel.debug_);
                break;
            case "TRACE":
                level = LogLevel.trace;
                setLogFile(logFile, LogLevel.trace);
                break;
            case "ERROR":
                level = LogLevel.error;
                setLogFile(logFile, LogLevel.error);
                break;
            case "WARN":
                level = LogLevel.warn;
                setLogFile(logFile, LogLevel.warn);
                break;
            default:
                level = LogLevel.info;
                setLogFile(logFile, LogLevel.info);
                break;
        }

        setLogLevel(LogLevel.none); // this effectively deactivates vibe.d's stdout logger

        // now register a custom Logger that's nicer than the one provided by vibe.d (and outputs correct time)
        auto console = cast(shared)new ConsoledLogger(level);
        registerLogger(console);

        logInfo("PoodinisContext -> Logging Configured [%s] will be output to: %s", logLevel, logFile);

        // todo: consider options for HTML Logger and SyslogLogger, see: https://github.com/rejectedsoftware/vibe.d/blob/master/source/vibe/core/log.d
//        auto logger = cast(shared)new HTMLLogger("log.html");
//        registerLogger(logger);
    }
}


import std.regex : replaceFirst, regex;
import std.stdio;
import consoled : Color, writec, Fg, foreground, background, resetColors;

final class ConsoledLogger : Logger {

//    alias Debug = ColorTheme!(Color.blue, Color.initial);
//    alias Info = ColorTheme!(Color.lightGray, Color.initial);
//    alias Error = ColorTheme!(Color.red, Color.initial);
//    alias ReallyBad = ColorTheme!(Color.white, Color.red);

    this(LogLevel level) {
        minLevel = level;
    }

    // for more info on LogLine see: http://vibed.org/api/vibe.core.log/LogLine
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

        // note that I don't use 'write(msg.time)' here because it doesn't output correct time (I'm currently in BST)
        write(Clock.currTime()); // could also use: write(Clock.currTime().toISOExtString());

        writef(" - %08X", msg.threadID);

        if(msg.threadName !is null) {
            writef(":'%s'", msg.threadName);
        }

        write(" [");
        foreground = fg;
        background = bg;
        writef("%s", level);
        resetColors();
        write("] ");

        string file = replaceFirst(msg.file, regex(r".*\.dub\/packages\/"), ""); // don't show path to local dub repo
        writec(Fg.cyan, file, Fg.initial, "(", Fg.cyan, msg.line, Fg.initial, "): ");
	}

	override void put(scope const(char)[] text) {
		write(replaceFirst(text, regex(r".*\.dub\/packages\/"), ""));
	}

	override void endLine() {
		writeln();
	}
}
