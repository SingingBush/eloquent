
import poodinis;
import vibe.d;

import eloquent.config.properties;
import eloquent.config.context;
import eloquent.controllers.web, eloquent.controllers.admin;

shared static this() {
	auto container = new shared DependencyContainer();
	container.registerContext!PoodinisContext; // Create application context before doing anything else

	Properties properties = container.resolve!Properties;

	auto router = new URLRouter;
	//router.get("*", (req, res) {req.params["version"] = "1.0-SNAPSHOT";}); //todo: find out why this breaks things like @errorDisplay
	router.get("*", serveStaticFiles("public/"));
	router.registerWebInterface(container.resolve!WebappController);
	auto adminSettings = new WebInterfaceSettings;
	adminSettings.urlPrefix = "/admin";
	router.registerWebInterface(container.resolve!AdminController, adminSettings);

	auto settings = new HTTPServerSettings;
	settings.port = properties.as!(ushort)("http.port", 80);
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.sessionStore = new MemorySessionStore;
	settings.errorPageHandler = toDelegate(&errorPage);
	listenHTTP(settings, router);

	logInfo("Eloquent server ready...");
}

shared static ~this() {
	logInfo("Clearing all Registered dependencies...");
	DependencyContainer.getInstance().clearAllRegistrations();
	logInfo("Application shutting down - goodbye!"); // see also logError and logDiagnostic
}

void errorPage(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
    CurrentUser user; // kludge for getting template to render when serving error page
    req.params["version"] = "1.0-SNAPSHOT";
    render!("error.dt", req, error, user)(res);
}

struct CurrentUser {
	string username = null;
	bool authenticated = false;
	bool administrator = false;
}
