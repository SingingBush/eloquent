module eloquent.controllers.admin;

import poodinis;
import vibe.core.core;
import vibe.core.log;
import vibe.crypto.passwordhash;
import vibe.http.router;
import vibe.web.web;

import eloquent.config.properties;
import eloquent.services.userservice, eloquent.services.blogservice;
import eloquent.controllers;

class AdminController : BaseController {

    @Autowire
    private Properties _properties;

    @Autowire
    private UserService _userService;

    @Autowire
    private BlogService _blogService;

    @method(HTTPMethod.GET) @path("/admin")
    void index() {
        logInfo("GET: /admin");

        bool authenticated = ms_authenticated;
        string username = ms_username;

        render!("admin/manageusers.dt", authenticated, username);
    }

    @method(HTTPMethod.GET) @path("/admin/comments")
    void manageComments() {
        logInfo("GET: /admin/comments");

        auto comments = _blogService.getComments();

		bool authenticated = ms_authenticated;
        string username = ms_username;

        render!("admin/managecomments.dt", authenticated, username, comments);
    }

    @method(HTTPMethod.GET) @path("/admin/users")
    void manageUsers() {
        logInfo("GET: /admin/users");

		bool authenticated = ms_authenticated;
        string username = ms_username;

        render!("admin/manageusers.dt", authenticated, username);
    }

}
