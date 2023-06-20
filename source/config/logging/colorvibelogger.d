module eloquent.config.logging.colorvibelogger;

private import vibe.core.log : Logger, FileLogger, setLogFormat, setLogFile, setLogLevel, registerLogger, logInfo, LogLevel;
private alias VibeLogger = Logger;
private alias VibeLogLevel = LogLevel;

private import std.regex : matchFirst, replaceFirst, regex;
private import std.stdio : write, writef, writeln;
private import std.conv : to;

private import ColourfulMoon;

// colours used are from Twitter Bootstrap
private auto Debug = Colour(92, 184, 92);
private auto Info = Colour(51, 122, 183);
private auto Warn = Colour(240, 173, 78);
private auto Error = Colour(217, 83, 79);

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