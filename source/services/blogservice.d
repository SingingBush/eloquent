module eloquent.services.blogservice;

import eloquent.model;
import poodinis.autowire : Autowire;
import vibe.core.log;

interface BlogService {
	BlogPost[] allBlogPosts();
	BlogPost getBlogPost(Uint id);
	Comment[] getComments();
	BlogPost[] findRecentPosts(int amount);
	BlogPost[] findAllByUser(User user);
}


class BlogServiceImpl : BlogService {

	@Autowire
	private SessionFactory sessionFactory;


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

		Query q = session.createQuery("FROM BlogPost WHERE type='post' ORDER BY created DESC");
		auto blogPosts = q.list!BlogPost();
		//logInfo("posts %s", q.listRows()); // shows all params
		logDebug("BlogService - > found %s BlogPosts: %s", blogPosts.length, blogPosts);
		return blogPosts;
	}

	BlogPost getBlogPost(Uint id) {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		auto blogPost = session.createQuery("FROM BlogPost WHERE type='post' AND id=:Id ORDER BY created DESC")
					.setParameter("Id", id)
					.uniqueResult!BlogPost;

		return blogPost;
	}

	Comment[] getComments() {
	    Session session = sessionFactory.openSession();
        scope(exit) session.close();

        Query q = session.createQuery("FROM Comment ORDER BY created DESC");
        auto comments = q.list!Comment();

//        logInfo("comments %s", q.listRows()); // shows all params
        logDebug("BlogService - > found %s comments: %s", comments.length, comments);
        return comments;
	}

	// get the most recent posts with limit defined by method caller
	BlogPost[] findRecentPosts(int amount) {
		return null; // todo
	}

	BlogPost[] findAllByUser(User user) {
		Session session = sessionFactory.openSession();
		scope(exit) session.close();

		Query q = session.createQuery("FROM BlogPost WHERE type='post' AND author=:user_id ORDER BY created DESC")
					.setParameter("user_id", user.id);
		auto blogPosts = q.list!BlogPost();
		//logInfo("posts %s", q.listRows()); // shows all params
		logDebug("BlogService - > found %s BlogPosts: %s", blogPosts.length, blogPosts);
		return blogPosts;
	}
}
