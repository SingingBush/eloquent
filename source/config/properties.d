module eloquent.config.properties;

import properd; // for the readProperties() method that loads in app.properties
import vibe.core.log;

class Properties {

    private string[string] _properties;

    public this() {
        logInfo("Properties -> loading app.properties file...");
        _properties = readProperties("./app.properties"); // todo: add error handling
    }

    T as(T)(string name, T alternative=T.init) {
        return _properties.as!(T)(name, alternative);
    }
}