module eloquent.config.logging;

private import eloquent.config.properties;
private import vibe.core.log : Logger, FileLogger, setLogFormat, setLogFile, setLogLevel, registerLogger, logInfo, LogLevel;
private alias VibeLogger = Logger;
private alias VibeLogLevel = LogLevel;
private import std.regex : matchFirst, replaceFirst, regex;

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

	static if(__traits(compiles, (){ import std.experimental.logger; } )) {
		import std.experimental.logger : sharedLog, LogLevel;
		pragma(msg, "eloquent will redirect anything logged via 'std.experimental.logger : sharedLog' to StdColourfulMoonLogger.");
		switch(logLevel.toUpper) {
			case "VERBOSE":
			case "DEBUG":
			case "TRACE":
				sharedLog = new StdColourfulMoonLogger(LogLevel.trace);
				break;
			case "ERROR":
				sharedLog = new StdColourfulMoonLogger(LogLevel.error);
				break;
			case "WARN":
				sharedLog = new StdColourfulMoonLogger(LogLevel.warning);
				break;
			case "INFO":
			default:
				sharedLog = new StdColourfulMoonLogger(LogLevel.info);
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


// ------- requires ColourfulMoon
import ColourfulMoon;

// colours used are from Twitter Bootstrap
auto Debug = Colour(92, 184, 92);
auto Info = Colour(51, 122, 183);
auto Warn = Colour(240, 173, 78);
auto Error = Colour(217, 83, 79);

/**
 * An implementation of vibe.core.log.Logger that provides multi-color output in supported terminals by using ColourfulMoon.
 *
 * Besides the usual option for setting a minimum LogLevel, there is also an option to set the level that applies
 * to logging that is being done from within vibe-d. This makes it possible to set the minimum to LogLevel.debugV
 * without lots of debug messages comming from vibe-d. The LogLevel for vibe-d is set to LogLevel.info by default.
 *
 * The file paths that get output in log lines are cleaned up making log output much more readable.
 *
 * Authors: Sam Bate
 * Date: June 25, 2017
 * See_Also:
 *    https://github.com/azbukagh/ColourfulMoon
 */
final class ColourfulMoonLogger : VibeLogger {

	import vibe.core.log : LogLevel, LogLine;

	bool ignoreVibe = false;
	bool skip = false;

    this(LogLevel min = LogLevel.info, LogLevel vibeLevel = LogLevel.info) {
		minLevel = min;
		ignoreVibe = vibeLevel == LogLevel.none || vibeLevel > minLevel;
	}

	override void beginLine(ref LogLine msg) @trusted {
		if(ignoreVibe && matchFirst(msg.file, regex(r"(\\|\/)vibe-d(\\|\/)source(\\|\/)"))) {
			skip = true;
			return;
		}

		string level;
		auto fg = Colour();

		final switch (msg.level) {
			case LogLevel.trace:
			    level = "TRACE";
			    fg = Debug;
			    break;
			case LogLevel.debugV:
			    level = "VERBOSE";
			    fg = Debug;
			    break;
			case LogLevel.debug_:
                level = "DEBUG";
                fg = Debug;
                break;
			case LogLevel.diagnostic:
			    level = "DIAGNOSTIC";
			    fg = Info;
			    break;
			case LogLevel.info:
			    level = "INFO";
			    fg = Info;
			    break;
			case LogLevel.warn:
			    level = "WARN";
			    fg = Warn;
			    break;
			case LogLevel.error:
                level = "ERROR";
                fg = Error;
                break;
			case LogLevel.critical:
			    level = "CRITICAL";
			    fg = Error;
			    break;
			case LogLevel.fatal:
			    level = "FATAL";
			    fg = Error;
			    break;
			case LogLevel.none: assert(false);
		}

		// note that I don't use 'write(msg.time)' here because it doesn't output correct time (I'm currently in BST)
		import std.datetime : Clock;
		write(Clock.currTime()); // could also use: write(Clock.currTime().toISOExtString());

		writef(" - %08X", msg.threadID);

		if(msg.threadName !is null) {
			writef(":'%s'", msg.threadName);
		} else {
			writef(":%08X", msg.fiberID);
		}

        write(" [");
		level.Foreground(fg).Reset.write;
		write("] ");

		string file = replaceFirst(msg.file, regex(r".*\.?dub(\\|\/)packages(\\|\/)"), ""); // don't show path to local dub repo

		auto cyan = Colour(80, 238, 238);
		file.Foreground(cyan).Reset.write;
		write("(");

		(to!string(msg.line)).Foreground(cyan).Reset.write;
		write("): ");
	}

	override void put(scope const(char)[] text) {
		if(!skip) {
			write(replaceFirst(text, regex(r".*\.?dub(\\|\/)packages(\\|\/)"), ""));
		}
	}

	override void endLine() {
		if(!skip) {
			writeln();
		}
		skip = false;
	}
}

static if(__traits(compiles, (){ import std.experimental.logger; } )) {
	private import std.concurrency : Tid;
	private import std.datetime.systime : SysTime;
    private import std.experimental.logger;
	private alias StdLogLevel = std.experimental.logger.core.LogLevel;

	class StdColourfulMoonLogger : std.experimental.logger.core.Logger {

		this(const StdLogLevel lv = StdLogLevel.all) @safe {
			super(lv);
		}

		override protected void beginLogMsg(string file, int line, string funcName,
										string prettyFuncName, string moduleName, StdLogLevel logLevel,
										Tid threadId, SysTime timestamp, std.experimental.logger.core.Logger logger) @trusted {
            string level = "UNKNOWN";
			auto fg = Colour();

			switch (logLevel) {
				case StdLogLevel.trace:
					level = "TRACE";
					fg = Debug;
					break;
				case StdLogLevel.info:
					level = "INFO";
					fg = Info;
					break;
				case StdLogLevel.warning:
					level = "WARN";
					fg = Warn;
					break;
				case StdLogLevel.error:
					level = "ERROR";
					fg = Error;
					break;
				case StdLogLevel.critical:
					level = "CRITICAL";
					fg = Error;
					break;
				case StdLogLevel.fatal:
					level = "FATAL";
					fg = Error;
					break;
				default:
					level = logLevel.to!string;
					break;
			}

			// note that I don't use 'write(msg.time)' here because it doesn't output correct time (I'm currently in BST)
			//import std.datetime : Clock;
			//write(Clock.currTime()); // could also use: write(Clock.currTime().toISOExtString());
			write(timestamp);

			writef(" - %s", threadId);

			write(" [");
			level.Foreground(fg).Reset.write;
			write("] ");

			file = replaceFirst(file, regex(r".*\.?dub(\\|\/)packages(\\|\/)"), ""); // don't show path to local dub repo

			auto cyan = Colour(80, 238, 238);
			file.Foreground(cyan).Reset.write;
			write("(");

			(to!string(line)).Foreground(cyan).Reset.write;
			write("): ");

			// alternative::
    		// auto ltw = stdout.lockingTextWriter();
			// import std.format : formattedWrite;
			// formattedWrite(ltw, "%s - %s [%s] %s(%u): ", timestamp, threadId, level, file, line);
        }

        override protected void logMsgPart(scope const(char)[] msg) @trusted {
			write(replaceFirst(msg, regex(r".*\.?dub(\\|\/)packages(\\|\/)"), ""));

			// auto ltw = stdout.lockingTextWriter();
			// import std.format : formattedWrite;
            // formattedWrite(ltw, replaceFirst(msg, regex(r".*\.?dub(\\|\/)packages(\\|\/)"), ""));
        }

        override protected void finishLogMsg() @trusted {
            writeln();
        }

		override protected void writeLogMsg(ref LogEntry payload) {
			this.beginLogMsg(payload.file, payload.line, payload.funcName,
                payload.prettyFuncName, payload.moduleName, payload.logLevel,
                payload.threadId, payload.timestamp, payload.logger);

            this.logMsgPart(payload.msg);
            
			this.finishLogMsg();
		}

	}
}