module eloquent.controllers.admin;

import poodinis;
import vibe.core.core;
import vibe.crypto.passwordhash;
import vibe.http.router;
import vibe.web.web;

import eloquent.config.properties;
import eloquent.services.userservice, eloquent.services.blogservice;
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
    void manageUsers(Json _user) {
        logInfo("GET: /admin/users");

        CurrentUser user = currentUser;

        render!("admin_users.dt", user);
    }

}
