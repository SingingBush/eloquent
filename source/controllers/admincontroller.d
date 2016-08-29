module eloquent.controllers.admin;

import poodinis;
import vibe.core.core;
import vibe.core.log;
import vibe.crypto.passwordhash;
import vibe.http.router;
import vibe.web.web;

import eloquent.config.properties;
import eloquent.services.userservice, eloquent.services.blogservice;

class AdminController {

    @Autowire
    private Properties _properties;

    @Autowire
    private UserService _userService;

    @Autowire
    private BlogService _blogService;

    @method(HTTPMethod.GET) @path("/admin")
    void index() {
        logInfo("GET: /admin");

        bool authenticated = false; // kludge for getting template to render when serving error page
        render!("admin/manageusers.dt", authenticated);
    }

    @method(HTTPMethod.GET) @path("/admin/comments")
    void manageComments() {
        logInfo("GET: /admin/comments");

        auto comments = _blogService.getComments();

        bool authenticated = false; // kludge for getting template to render when serving error page
        render!("admin/managecomments.dt", authenticated, comments);
    }

    @method(HTTPMethod.GET) @path("/admin/users")
    void manageUsers() {
        logInfo("GET: /admin/users");

        bool authenticated = false; // kludge for getting template to render when serving error page
        render!("admin/manageusers.dt", authenticated);
    }

}
