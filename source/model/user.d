module eloquent.model.User;

import std.string;

public class User {

public:
	int id;
	string username;
	string firstname;
	string lastname;
	string jobtitle;
	string email;

public:
	string fullname() {
		return format("%s %s", firstname, lastname);
	}

	override string toString() {
		return format("User %s %s %s", id, firstname, lastname);
	}
}