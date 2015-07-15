module eloquent.services.UserService;

import std.string;
import std.algorithm : filter, startsWith;
import std.array : array;

import eloquent.model.User;

interface UserService {
	User getUser(string username);
	User[] findAll();
}


class UserServiceImpl : UserService {

	User getUser(string username) {
		auto user = new User; // todo: Should be getting a user from a database
		user.id = 1;
		user.username = username;
		user.firstname = "Bob";
		user.lastname = "Hope";
		return user;
	}

	User[] findAll() {
		return null; // todo
	}
}