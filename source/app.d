import vibe.d;

import eloquent.controllers;

shared static this()
{
	auto router = new URLRouter;
	router.registerWebInterface(new WebappController);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.sessionStore = new MemorySessionStore;
	listenHTTP(settings, router);

	logInfo("Eloquent server started on http://127.0.0.1:8080/");
}

