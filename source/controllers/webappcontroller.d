module eloquent.controllers;

import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.web.web;


import eloquent.model.User, eloquent.model.BlogPost;
import eloquent.services.UserService, eloquent.services.BlogService;

// This is essentially like using Springs @Controller for handling routes in Spring MVC
class WebappController {
	private UserService _userService;
	private BlogService _blogService;

	public this() {
 		_userService = new UserServiceImpl;
 		_blogService = new BlogServiceImpl;
 	}

	private {
		// stored in the session store
		SessionVar!(bool, "authenticated") ms_authenticated;
		SessionVar!(string, "username") ms_username;
	}

	// GET /
	void index()
	{
		bool authenticated = ms_authenticated;
		string username = ms_username;
		auto blogPosts = _blogService.findRecentPosts(10);
		render!("index.dt", authenticated, username, blogPosts);
	}

	// @method(HTTPMethod.GET) @path("login")
	void getLogin() {
		bool authenticated = ms_authenticated;
		string username = ms_username;
		render!("login.dt", authenticated, username);
	}

	// POST /login (username and password are automatically read as form fields)
	void postLogin(string username, string password)
	{
		logInfo("User attempting to login: %s", username);
		// todo: create some real authentication
		enforceHTTP(username == "user" && password == "secret", HTTPStatus.forbidden, "Invalid user name or password.");
		ms_authenticated = true;
		ms_username = username;

		redirect("/profile");
	}

	// POST /logout
	@method(HTTPMethod.POST) @path("logout")
	void postLogout()
	{
		ms_username = null;
		ms_authenticated = false;
		terminateSession();
		redirect("/");
	}

	// @method(HTTPMethod.GET) @path("profile")
	void getProfile() {
		bool authenticated = ms_authenticated;
		string username = ms_username;

		// todo: put some service layer in place to return a user object for the given username
		auto user = _userService.getUser(username);

		render!("profile.dt", authenticated, username, user);
	}
}