module eloquent.services.userservice;

import std.string;
import std.algorithm : filter, startsWith;
import std.array : array;

import eloquent.model.user;

import hibernated.core;
import hibernated.session;
import poodinis;
import vibe.core.log; // only the logger is needed

import std.conv;

interface UserService {
	User findUser(string username);
	User[] findUsers();
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
}