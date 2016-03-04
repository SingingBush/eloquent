module eloquent.controllers;

import poodinis;
import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.web.web;


import eloquent.model.User, eloquent.model.BlogPost;
import eloquent.services.UserService, eloquent.services.BlogService;

// This is essentially like using Springs @Controller for handling routes in Spring MVC
class WebappController {

	//@Autowire!UserServiceImpl
	public UserService _userService;
	
	//@Autowire!BlogServiceImpl
	public BlogService _blogService;

	public this() {
		auto container = DependencyContainer.getInstance();
 		_userService = container.resolve!UserService;
 		_blogService = container.resolve!BlogService;
 	}

	private {
		// stored in the session store
		SessionVar!(bool, "authenticated") ms_authenticated;
		SessionVar!(string, "username") ms_username;
	}

	// GET /
	void index() {
		bool authenticated = ms_authenticated;
		string username = ms_username;
		auto blogPosts = _blogService.allBlogPosts();
		render!("index.dt", authenticated, username, blogPosts);
	}

	// @method(HTTPMethod.GET) @path("login")
	void getLogin() {
		bool authenticated = ms_authenticated;
		string username = ms_username;
		render!("login.dt", authenticated, username);
	}

	// POST /login (username and password are automatically read as form fields)
	void postLogin(string username, string password) {
		logInfo("User attempting to login: %s", username);
		// todo: create some real authentication
		auto user = _userService.findUser(username);

		logInfo("User retrieved from db: %s", user);

		enforceHTTP(username == user.username && password == "password", HTTPStatus.forbidden, "Invalid user name or password.");
		ms_authenticated = true;
		ms_username = username;

		redirect("/profile");
	}

	// POST /logout
	@method(HTTPMethod.GET) @path("logout")
	void getLogout() {
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
		auto user = _userService.findUser(username);

		auto blogPosts = _blogService.findAllByUser(user);

		render!("profile.dt", authenticated, username, user, blogPosts);
	}
}