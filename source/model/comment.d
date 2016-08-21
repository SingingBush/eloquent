module eloquent.model.comment;

import eloquent.model.blogpost;
import eloquent.model.user;

import hibernated.core;

import std.datetime, std.string;

//enum CommentType {
//}

@Entity
@Table("wp_comments")
public class Comment {

public:
	@Id
	@Generated
	@Column("comment_ID")
	uint id; // bigint (20) NOT NULL auto inc

    @ManyToOne
    @JoinColumn("comment_post_ID")
	BlogPost blogPost;

	@Column("comment_author")
	string author; // tinytext

	@Column("comment_author_email") // varchar(100)
    string authorEmail;

    @Column("comment_author_url") // varchar(200)
    string authorUrl;

    @Column("comment_author_IP") // varchar(100)
    string authorIP;

	@Column("comment_date")
	DateTime created;

	@Column("comment_content")
	string content; // LONGTEXT

	@Column("comment_approved") // varchar(20)
	string approved;

	@Column("comment_agent") // varchar(255)
	string agent;

    @Column("comment_type") // varchar(20)
    string type;

//    @ManyToOne // hibernated doesnt like this
//    @JoinColumn("comment_parent")
//    Comment parent;

//    @ManyToOne // hibernated doesnt like this
//    @JoinColumn("user_id")
//    User user;

    @OneToMany
    LazyCollection!CommentData metadata;

	override string toString() {
		return format("{id:%s, %s, author:%s, created:%s, metadata:%s}", id, type, author, created, metadata);
	}
}

@Table("wp_commentmeta")
public class CommentData {

public:
	@Column("meta_id", 20) // bigint(20)
	@Id
	@Generated
	uint id;

	@ManyToOne
	@JoinColumn("comment_id")
	Comment user;

	@Column("meta_key", 255)
	@Null
	string key; // VARCHAR(255)

	@Column("meta_value")
	@Null
	string value; // LONGTEXT

    override string toString() {
        return format("{id:%s, key:%s, value:%s}", id, key, value);
    }
}
