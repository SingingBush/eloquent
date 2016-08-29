module eloquent.controllers;

public import eloquent.controllers.web, eloquent.controllers.admin;
import vibe.web.web;

abstract class BaseController {

	protected {
		// stored in the session store
		SessionVar!(bool, "authenticated") ms_authenticated;
		SessionVar!(string, "username") ms_username;
	}

}
