module eloquent.services.BlogService;

import std.datetime, std.string;
import std.algorithm : filter, startsWith;
import std.array : array;

import eloquent.model.User;
import eloquent.model.BlogPost;

import hibernated.core;
import hibernated.session;
import poodinis;
import vibe.core.log; // only the logger is needed

import std.conv;

interface BlogService {
	BlogPost[] allBlogPosts();
	BlogPost getBlogPost(Uint id);
	BlogPost[] findRecentPosts(int amount);
	BlogPost[] findAllByUser(User user);
}


class BlogServiceImpl : BlogService {

	@Autowire
	public SessionFactory sessionFactory;


	public this() {
		logDebug("Creating DatabaseService");
	}

	public ~this() {
		logInfo("closing SessionFactory: %s", sessionFactory);
		sessionFactory.close();
	}

	public BlogPost[] allBlogPosts() {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		Query q = session.createQuery("FROM BlogPost WHERE postType='post' ORDER BY created DESC");
		auto posts = q.list!BlogPost();
		//logInfo("posts %s", q.listRows()); // shows all params
		return posts;
	}

	BlogPost getBlogPost(Uint id) {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		Query q = session.createQuery("FROM BlogPost WHERE postType='post' AND id=:Id ORDER BY created DESC")
					.setParameter("Id", id);

		return q.uniqueResult!BlogPost; // todo: Should be getting a user from a database
		//blogpost.id = 1;
		//blogpost.title = format("Lorem ipsum %s", blogpost.id);
		//blogpost.content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus leo quis mi bibendum, eu semper felis convallis. Cras ligula neque, eleifend sit amet placerat sit amet, dignissim ac mauris. Etiam sagittis non dui euismod porta. Nam odio nisl, interdum vitae odio ultrices, suscipit vehicula sem. Proin nec turpis in metus efficitur suscipit sed pellentesque odio. Integer condimentum auctor fermentum. Donec imperdiet tellus condimentum, laoreet ante vitae, sodales est. Sed enim dolor, tempus eu consequat et, posuere id sapien. Pellentesque nec tellus ut sapien congue interdum ac sed turpis. Nullam ut diam vitae risus volutpat iaculis. Vestibulum efficitur magna libero, in feugiat urna faucibus ac.";
		//blogpost.created = DateTime.init; // Clock.currTime();
		//return blogpost;
	}

	// get the most recent posts with limit defined by method caller
	BlogPost[] findRecentPosts(int amount) {
		return null; // todo
	}

	BlogPost[] findAllByUser(User user) {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		Query q = session.createQuery("FROM BlogPost WHERE postType='post' AND author=:Author ORDER BY created DESC")
					.setParameter("Author", user);
		auto posts = q.list!BlogPost();
		//logInfo("posts %s", q.listRows()); // shows all params
		return posts;
	}
}