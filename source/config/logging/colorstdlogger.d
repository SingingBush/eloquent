module eloquent.config.logging.colorstdlogger;

static if (__traits(compiles, (){ import std.logger; } )) {
    private import std.logger.core : Logger, LogLevel;
    private alias StdLogLevel = LogLevel;
} else {
    private import std.experimental.logger : Logger, LogLevel;
    private alias StdLogLevel = LogLevel;
}
private import std.regex : matchFirst, replaceFirst, regex;
private import std.stdio : write, writef, writeln;
private import std.conv : to;


// ------- requires ColourfulMoon
private import ColourfulMoon;

// colours used are from Twitter Bootstrap
private auto Debug = Colour(92, 184, 92);
private auto Info = Colour(51, 122, 183);
private auto Warn = Colour(240, 173, 78);
private auto Error = Colour(217, 83, 79);

private import std.concurrency : Tid;
private import std.datetime.systime : SysTime;

class StdColourfulMoonLogger : Logger {

    this(const StdLogLevel lv = StdLogLevel.all) @safe {
        super(lv);
    }

    override protected void beginLogMsg(string file, int line, string funcName,
                                    string prettyFuncName, string moduleName, StdLogLevel logLevel,
                                    Tid threadId, SysTime timestamp, Logger logger) @trusted {
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

    override void writeLogMsg(ref LogEntry payload) @safe {
        this.beginLogMsg(payload.file, payload.line, payload.funcName,
            payload.prettyFuncName, payload.moduleName, payload.logLevel,
            payload.threadId, payload.timestamp, payload.logger);

        this.logMsgPart(payload.msg);
        
        this.finishLogMsg();
    }

}
