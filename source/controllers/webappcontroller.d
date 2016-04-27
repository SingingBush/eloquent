module eloquent.controllers;

import poodinis;
import vibe.core.core;
import vibe.core.log;
import vibe.crypto.passwordhash;
import vibe.http.router;
import vibe.web.web;

import eloquent.config.properties;
import eloquent.model.User, eloquent.model.BlogPost;
import eloquent.services.UserService, eloquent.services.BlogService;

// This is essentially like using Springs @Controller for handling routes in Spring MVC
class WebappController {

    //@Autowire
    public Properties _properties;

	//@Autowire!UserServiceImpl
	public UserService _userService;
	
	//@Autowire!BlogServiceImpl
	public BlogService _blogService;

	public this() {
		auto container = DependencyContainer.getInstance();
		_properties = container.resolve!Properties;
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
	void getLogin(string _error = null) {
		bool authenticated = ms_authenticated;
		string username = ms_username;
		render!("login.dt", authenticated, username, _error);
	}

	// POST /login (username and password are automatically read as form fields)
	@errorDisplay!getLogin
	void postLogin(string username, string password) { // todo: look at ValidUsername and ValidPassword structs in http://vibed.org/api/vibe.web.validation/
		logInfo("User attempting to login: %s", username);

		enforceHTTP(username !is null && !username.empty, HTTPStatus.badRequest, "Username is a required field.");
		enforceHTTP(password !is null && !password.empty, HTTPStatus.badRequest, "Password is a required field.");

//        import vibe.utils.validation;
//        validateUserName(username)
//        validatePassword(password)

		// todo: create some real authentication
		auto user = _userService.findUser(username);

		logInfo("User retrieved from db: %s", user);

        string salt = _properties.as!(string)("auth.salt");
        string hash = generateSimplePasswordHash(password, salt); // todo: store password Hash in db a retrieve via user.pwHash
        auto authed = testSimplePasswordHash(hash, password, salt);

		enforceHTTP(user !is null && authed, HTTPStatus.forbidden, "Invalid user name or password.");
		ms_authenticated = true;
		ms_username = username;

		//auto session = startSession();
		//session.set("user", user);
		//logInfo("form: %s", form["password"]);

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

		auto blogPosts = _blogService.findAllByUser(user); // todo: fix this "mysqlddbc.d(541): Unsupported parameter type"

		render!("profile.dt", authenticated, username, user, blogPosts);
	}
}