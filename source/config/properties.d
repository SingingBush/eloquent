module eloquent.config.properties;

import properd : readProperties, as;
import vibe.core.log;
import vibe.core.args;

class Properties {

    private string[string] _properties;

    public this(string filePath = "./app.properties") {
    	version(DEVELOPMENT) {
    		logInfo("Properties -> configuring test properties");
    		_properties["db.dialect"] = "SQLite";
    		_properties["db.file"] = "schema.sql";
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
