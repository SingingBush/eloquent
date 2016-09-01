module eloquent.controllers;

public import std.array, std.algorithm, std.string;
public import eloquent.controllers.web, eloquent.controllers.admin;
public import vibe.core.log, vibe.http.router, vibe.web.web, vibe.data.json;

abstract class BaseController {

	protected {
		SessionVar!(CurrentUser, "user") currentUser; // stored in the session store
	}

	enum auth = before!ensureAuth("_user");
	enum admin = before!ensureAdmin("_user");

	Json ensureAuth(HTTPServerRequest req, HTTPServerResponse res) {
		logInfo("checking user is authenticated");
		if(!currentUser.authenticated) {
			redirect("/login"); // throw new HTTPStatusException(401, "You need to be logged in");
		}
		return serializeToJson(currentUser);
	}

	Json ensureAdmin(HTTPServerRequest req, HTTPServerResponse res) {
		logInfo("checking user is administrator");
		if(!currentUser.authenticated) {
			redirect("/login");
		}
		if(!currentUser.administrator) {
			throw new HTTPStatusException(401, "You do not have permission to access this resource");
		}
		return serializeToJson(currentUser);
	}

}

struct CurrentUser {
	string username = null;
	bool authenticated = false;
	bool administrator = false;
}
