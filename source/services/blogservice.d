module eloquent.services.BlogService;

import std.datetime, std.string;
import std.algorithm : filter, startsWith;
import std.array : array;

import eloquent.model.User;
import eloquent.model.BlogPost;

interface BlogService {
	BlogPost getBlogPost(int id);
	BlogPost[] findRecentPosts(int amount);
	BlogPost[] findAllByUser(User user);
}


class BlogServiceImpl : BlogService {

	BlogPost getBlogPost(int id) {
		BlogPost blogpost = new BlogPost; // todo: Should be getting a user from a database
		blogpost.id = 1;
		blogpost.title = format("Lorem ipsum %s", blogpost.id);
		blogpost.content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus leo quis mi bibendum, eu semper felis convallis. Cras ligula neque, eleifend sit amet placerat sit amet, dignissim ac mauris. Etiam sagittis non dui euismod porta. Nam odio nisl, interdum vitae odio ultrices, suscipit vehicula sem. Proin nec turpis in metus efficitur suscipit sed pellentesque odio. Integer condimentum auctor fermentum. Donec imperdiet tellus condimentum, laoreet ante vitae, sodales est. Sed enim dolor, tempus eu consequat et, posuere id sapien. Pellentesque nec tellus ut sapien congue interdum ac sed turpis. Nullam ut diam vitae risus volutpat iaculis. Vestibulum efficitur magna libero, in feugiat urna faucibus ac.";
		blogpost.created = Clock.currTime();
		return blogpost;
	}

	// get the most recent posts with limit defined by method caller
	BlogPost[] findRecentPosts(int amount) {
		BlogPost[] posts;
		posts.length = amount;

		for(int i = 0; i < posts.length; i++) {
			auto post = new BlogPost;
			post = getBlogPost(i);
			posts[i] = post;
		}
		return posts;
	}

	BlogPost[] findAllByUser(User user) {
		return null; // todo
	}
}