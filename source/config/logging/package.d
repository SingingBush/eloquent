module eloquent.config.logging;

private import eloquent.config.properties;
private import eloquent.config.logging.colorstdlogger : StdColourfulMoonLogger;
private import eloquent.config.logging.colorvibelogger : ColourfulMoonLogger;

private import vibe.core.log : FileLogger, logInfo, LogLevel, registerLogger, setLogLevel, setLogFormat, setLogFile;
private alias VibeLogLevel = LogLevel;

static if (__traits(compiles, (){ import std.logger; } )) {
	private import std.logger.core : sharedLog;
	private alias StdLogLevel = std.logger.core.LogLevel;
	pragma(msg, "eloquent will redirect anything logged via 'std.logger.core : sharedLog' to StdColourfulMoonLogger.");
} else static if(__traits(compiles, (){ import std.experimental.logger; } )) {
    private import std.experimental.logger : sharedLog;
	private alias StdLogLevel = std.experimental.logger.LogLevel;
	pragma(msg, "eloquent will redirect anything logged via 'std.experimental.logger : sharedLog' to StdColourfulMoonLogger.");
} else {
	static assert(false, "neither std.logger or std.experimental.logger found");
}

static if(__VERSION__ < 2085) {
    private import std.regex : toUpper;
} else {
	private import std.string : toUpper; // previously had:		import std.uni : toUpper;
}

private import std.stdio;
private import std.conv : to;

void configureLogging(Properties properties) {
	immutable auto logFile = properties.as!(string)("log.file", "eloquent-server.log");
	immutable auto logLevel = properties.as!(string)("log.level", "info");

	setLogFormat(FileLogger.Format.threadTime, FileLogger.Format.threadTime); // plain, thread, or threadTime

	VibeLogLevel level;

	switch(logLevel.toUpper) {
		case "VERBOSE":
			level = VibeLogLevel.debugV;
			break;
		case "DEBUG":
			level = VibeLogLevel.debug_;
			break;
		case "TRACE":
			level = VibeLogLevel.trace;
			break;
		case "ERROR":
			level = VibeLogLevel.error;
			break;
		case "WARN":
			level = VibeLogLevel.warn;
			break;
		case "INFO":
		default:
			level = VibeLogLevel.info;
			break;
	}

	setLogFile(logFile, level);

	// std logging
	static if (__traits(compiles, (){ import std.logger; } )) {
		switch(logLevel.toUpper) {
			case "VERBOSE":
			case "DEBUG":
			case "TRACE":
				sharedLog = (() @trusted => cast(shared)new StdColourfulMoonLogger(StdLogLevel.trace))();
				break;
			case "ERROR":
				sharedLog = (() @trusted => cast(shared)new StdColourfulMoonLogger(StdLogLevel.error))();
				break;
			case "WARN":
				sharedLog = (() @trusted => cast(shared)new StdColourfulMoonLogger(StdLogLevel.warning))();
				break;
			case "INFO":
			default:
				sharedLog = (() @trusted => cast(shared)new StdColourfulMoonLogger(StdLogLevel.info))();
				break;
		}
	} else static if(__traits(compiles, (){ import std.experimental.logger; } )) {
		switch(logLevel.toUpper) {
			case "VERBOSE":
			case "DEBUG":
			case "TRACE":
				sharedLog = new StdColourfulMoonLogger(StdLogLevel.trace);
				break;
			case "ERROR":
				sharedLog = new StdColourfulMoonLogger(StdLogLevel.error);
				break;
			case "WARN":
				sharedLog = new StdColourfulMoonLogger(StdLogLevel.warning);
				break;
			case "INFO":
			default:
				sharedLog = new StdColourfulMoonLogger(StdLogLevel.info);
				break;
		}
	}

	setLogLevel(VibeLogLevel.none); // this effectively deactivates vibe.d's stdout logger

	// now register a custom Logger that's nicer than the one provided by vibe.d (and outputs correct time)
	auto console = cast(shared)new ColourfulMoonLogger(level);
	registerLogger(console);

	logInfo("PoodinisContext -> Logging Configured [%s] will be output to: %s", logLevel, logFile);

	// todo: consider options for HTML Logger and SyslogLogger, see: https://github.com/rejectedsoftware/vibe.d/blob/master/source/vibe/core/log.d
//        auto logger = cast(shared)new HTMLLogger("log.html");
//        registerLogger(logger);
}

