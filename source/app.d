
import poodinis;
import vibe.d;

import eloquent.config.context;
import eloquent.controllers;

shared static this() {
	auto container = DependencyContainer.getInstance();
	container.registerContext!PoodinisContext; // Create application context before doing anything else

	//container.register!WebappController;
	//auto webapp = container.resolve!WebappController;

	//WebappController webapp = new WebappController();
	//container.register!(WebappController).existingInstance(webapp);

	auto router = new URLRouter;
	//router.get("*", (req, res) {req.params["version"] = "1.0-SNAPSHOT";}); //todo: find out why this breaks things like @errorDisplay
	router.get("*", serveStaticFiles("public/"));
	router.registerWebInterface(new WebappController);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
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
    bool authenticated = false; // kludge for getting template to render when serving error page
    req.params["version"] = "1.0-SNAPSHOT";
    render!("error.dt", req, error, authenticated)(res);
}
