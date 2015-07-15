module eloquent.model.BlogPost;

import std.datetime, std.string;

import eloquent.model.User;

public class BlogPost {

public:
	int id;
	User author;
	string title;
	string content;
	SysTime created; // see: http://dlang.org/intro-to-datetime.html
	SysTime edited;

}