module eloquent.services.userservice;

import eloquent.services;

interface UserService {
	User findUser(string username);
	User[] findUsers();
	User createUser(string username, string passwdHash, string email);
}


class UserServiceImpl : UserService {

	@Autowire
	private SessionFactory sessionFactory;


	public this() {
		logDebug("Creating DatabaseService");
	}

	public ~this() {
		logInfo("closing SessionFactory: %s", sessionFactory);
		sessionFactory.close();
	}

	public User[] findUsers() {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		logInfo("querying user table");
		Query q = session.createQuery("FROM User ORDER BY nicename");
		User[] results = q.list!User();
		logInfo("results size is " ~ to!string(results.length));

		return results;
	}

	public User findUser(string username) {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		Query q = session
					.createQuery("FROM User WHERE username=:Username ORDER BY nicename")
					.setParameter("Username", username);
		return q.uniqueResult!User();
	}

	public User createUser(string username, string passwdHash, string email) {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		User user = new User;
		user.username = username;
		user.pass = passwdHash;
		user.nicename = "";
		user.displayname = username;
		user.email = email;
		user.url = "";
		import std.datetime;
		SysTime now = Clock.currTime(UTC());
		user.registered = cast(DateTime) now;
		user.status = UserStatus.DEFAULT;
		session.save(user);
		logInfo("new user created: %s", user);
		return user;
	}
}
