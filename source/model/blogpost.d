module eloquent.model.BlogPost;

import eloquent.model.User;

import hibernated.core;

import std.datetime, std.string;

enum PostType {
	page,
	post,
	revision,
	attachment,
	nav_menu_item
}

@Entity
@Table("wp_posts")
public class BlogPost {

public:
	@Id
	@Generated
	Uint id; // bigint (20) NOT NULL auto inc

	@OneToOne @NotNull @JoinColumn("post_author")
	User author;

	@Column("post_date") @NotNull
	DateTime created;

	@Column("post_modified") @NotNull
	DateTime modified;

	@Column("post_content") @NotNull
	string content; // LONGTEXT

	@Column("post_title") @NotNull
	string title; // TEXT

	@Column("post_excerpt") @NotNull
	string excerpt; // TEXT

	@Column("post_type",20) @NotNull
	string postType;

	@OneToMany
	LazyCollection!BlogPostData data;

	override string toString() {
		return format("{id:%s, %s, %s, author:%s, created:%s}", id, postType, title, author.username, created);
	}
}

@Table("wp_postmeta")
public class BlogPostData {

public:
	@Column("meta_id", 20) // bigint(20)
	@Id
	@Generated
	Uint id;

	@ManyToOne
	@JoinColumn("post_id")
	BlogPost user;

	@Column("meta_key", 255)
	@Null
	string key; // VARCHAR(255)

	@Column("meta_value")
	@Null
	string value; // LONGTEXT

}