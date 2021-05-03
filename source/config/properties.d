module eloquent.config.properties;

private import properd : readProperties, as;
private import vibe.core.log;
private import vibe.core.args;
private import vibe.http.server : HTTPServerRequest;

class Properties {

    private string[string] _properties;

    public this(string filePath = "./app.properties") {
    	version(DEVELOPMENT) {
    		logInfo("Properties -> configuring test properties");
    		_properties["http.port"] = "8080";
    		_properties["db.dialect"] = "SQLite";
    		_properties["db.file"] = "testdb.sqlite";
    		_properties["db.createSchema"] = "true";
    		_properties["db.createTestData"] = "true";
    		_properties["log.level"] = "debug";
    	} else {
			readOption("p|properties", &filePath, "path to properites file. Defaults to './app.properties'");

			logInfo("Properties -> loading properties file: '%s'", filePath);
			_properties = readProperties(filePath);
    	}
    }

    T as(T)(string name, T alternative=T.init) {
        return _properties.as!(T)(name, alternative);
    }
}

struct TranslationContext {
	private import std.typetuple : TypeTuple;
	alias languages = TypeTuple!("en_GB", "de_DE");

	private import vibe.web.web : translationModule, extractDeclStrings;
	mixin translationModule!"text";

	static string determineLanguage(scope HTTPServerRequest req) {
		import std.string : split, replace;
		auto acc_lang = "Accept-Language" in req.headers;
		if(acc_lang) {
			return replace(split(*acc_lang, ",")[0], "-", "_");
		}
		return null;
	}
}
