module eloquent.controllers.admin;

import poodinis;
import vibe.core.core;
import vibe.http.router;
import vibe.web.web;

import eloquent.config.properties;
import eloquent.services;
import eloquent.controllers;

// handles everything under '/admin'
class AdminController : BaseController {

    @Autowire
    private Properties _properties;

    @Autowire
    private UserService _userService;

    @Autowire
    private BlogService _blogService;

	@admin
    @method(HTTPMethod.GET)
    void index(Json _user) {
        logInfo("GET: /admin");

        CurrentUser user = currentUser;

        render!("admin_users.dt", user);
    }

    @admin
    @method(HTTPMethod.GET) @path("/blogposts")
    void manageBlogposts(Json _user) {
        logInfo("GET: /admin/blogposts");

        auto blogposts = _blogService.allBlogPosts();

        CurrentUser user = currentUser;

        render!("admin_blogposts.dt", blogposts, user);
    }

	@admin
    @method(HTTPMethod.GET) @path("/comments")
    void manageComments(Json _user) {
        logInfo("GET: /admin/comments");

        auto comments = _blogService.getComments();

        CurrentUser user = currentUser;

        render!("admin_comments.dt", comments, user);
    }

	@auth
	@admin
    @method(HTTPMethod.GET) @path("/users")
    void getUsers(Json _user) {
        logInfo("GET: /admin/users");

        CurrentUser user = currentUser;

        render!("admin_users.dt", user);
    }

    @auth
	@admin
	@method(HTTPMethod.POST) @path("/user/create")
	void postUsers(Json _user, string username, string password, string email) {
		// string salt = _properties.as!(string)("auth.salt"); // todo: use salt again?

        // SHA 3:
        import sha3d.sha3 : sha3_256Of;
        import std.digest : toHexString;
        string hash = toHexString(sha3_256Of(password));

		logInfo("POST: /admin/user/create: %s %s", username, email, hash);

		_userService.createUser(username, hash, email);

		redirect("/profile/%s".format(username));
	}

}
