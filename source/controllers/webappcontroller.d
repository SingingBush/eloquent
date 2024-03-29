module eloquent.controllers.web;

import poodinis;
import vibe.core.core;

import eloquent.config.properties;
import eloquent.model;
import eloquent.services;
import eloquent.controllers;

// This is essentially like using Springs @Controller for handling routes in Spring MVC
@translationContext!TranslationContext
class WebappController : BaseController {

    @Autowire
    private Properties _properties;

	@Autowire
	private UserService _userService;

	@Autowire
	private BlogService _blogService;

	// GET /
	void index() {
		auto blogPosts = _blogService.allBlogPosts();
		CurrentUser user = currentUser;
		render!("index.dt", blogPosts, user);
	}

	// @method(HTTPMethod.GET) @path("login")
	void getLogin(string _error = null) {
		CurrentUser user = currentUser;
		render!("login.dt", _error, user);
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

		enforceHTTP(user !is null, HTTPStatus.forbidden, "Invalid user name or password.");

        //string salt = _properties.as!(string)("auth.salt"); // todo: use salt again?

		// SHA 3:
        import sha3d.sha3 : sha3_256Of;
		import std.digest : toHexString;

		CurrentUser u;
		u.authenticated = (user.pass == toHexString(sha3_256Of(password)));

		enforceHTTP(u.authenticated, HTTPStatus.forbidden, "Invalid user name or password.");

		u.username = username;
		UserData[] data = user.data.find!(ud => ud.key == "wp_user_level");
		if(data.length > 0) {
			u.administrator = data[0].value == "10";
		}
		currentUser = u;

		//auto session = startSession();
		//session.set("user", user);
		//logInfo("form: %s", form["password"]);

		redirect("/profile/%s".format(username));
	}

	// POST /logout
	@method(HTTPMethod.GET) @path("logout")
	void getLogout() {
		immutable CurrentUser u;
		currentUser = u;
		terminateSession();
		redirect("/");
	}

	@auth
	@method(HTTPMethod.GET) @path("profile/:username")
	void getProfile(HTTPServerRequest req, Json _user, string _error = null, string _username = null) {
		string username = _username !is null? _username : currentUser.username;

		auto person = _userService.findUser(_username);

		if(person is null) {
			throw new HTTPStatusException(404, "Cannot find user: %s".format(username));
		}
		auto blogPosts = _blogService.findAllByUser(person);

		immutable CurrentUser user = currentUser;
		render!("profile.dt", username, blogPosts, user);
	}
}
