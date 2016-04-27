module eloquent.controllers.admin;

import poodinis;
import vibe.core.core;
import vibe.core.log;
import vibe.crypto.passwordhash;
import vibe.http.router;
import vibe.web.web;

import eloquent.config.properties;
import eloquent.services.UserService, eloquent.services.BlogService;

class AdminController {

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

    @method(HTTPMethod.GET) @path("/admin")
    void index() {
        logInfo("GET: /admin");

        bool authenticated = false; // kludge for getting template to render when serving error page
        render!("admin/manageusers.dt", authenticated);
    }

    @method(HTTPMethod.GET) @path("/admin/comments")
    void manageComments() {
        logInfo("GET: /admin/comments");

        bool authenticated = false; // kludge for getting template to render when serving error page
        render!("admin/managecomments.dt", authenticated);
    }

    @method(HTTPMethod.GET) @path("/admin/users")
    void manageUsers() {
        logInfo("GET: /admin/users");

        bool authenticated = false; // kludge for getting template to render when serving error page
        render!("admin/manageusers.dt", authenticated);
    }

}