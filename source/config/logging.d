module eloquent.config.logging;

import eloquent.config.properties;
import vibe.core.log; // only the logger is needed
import std.regex : toUpper, replaceFirst, regex;
import std.stdio;
import consoled : Color, writec, Fg, foreground, background, resetColors; // for the ConsoledLogger

void configureLogging(Properties properties) {
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
        import std.datetime : Clock;
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
