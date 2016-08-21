module eloquent.model.user;

import eloquent.model.blogpost;

import hibernated.core;

import std.datetime;
import std.string;

// supposedly the user_status field is a dead column in the wp_users table but it's still there
enum UserStatus {
	DEFAULT,
	ONE,TWO,THREE,FOUR,FIVE // no idea what the status values are yet, need to investigate
}

@Entity
@Table("wp_users")
public class User {

public:

	@Id
	@Generated
	uint id; // bigint (20) NOT NULL auto inc

	@Column("user_login",60)
	@NotNull
	string username; // user_login varchar(60) NOT NULL

	@Column("user_pass",64)
	@NotNull
	string password; // user_pass varchar(64) NOT NULL

	@Column("user_nicename",50)
	@NotNull
	string nicename; // user_nicename varchar(50) NOT NULL

	@Column("display_name",250)
	@NotNull
	string displayname; // display_name varchar(250) NOT NULL

	@Column("user_status",11)
	@NotNull
	UserStatus status; //

	@Column("user_email",100)
	@NotNull
	string email; // user_email varchar(100) NOT NULL

	@Column("user_url",100)
	@NotNull
	string url; // user_url varchar(100) NOT NULL

	@Column("user_registered")
	@NotNull
	DateTime registered; // user_registered datetime NOT NULL

	@OneToMany
	LazyCollection!UserData data;

public:
	@Transient
	string getFormattedData() {
		return format("%s bits of meta data", data.length);
	}

	override string toString() {
		return format("{id:%s, username:%s, displayname:%s, status:%s}", id, username, displayname, status);
	}
}

@Table("wp_usermeta") // user meta data is essentially a key value store for user info
public class UserData {

public:
	@Column("umeta_id", 20) // bigint(20)
	@Id
	@Generated
	uint id;

	@ManyToOne
	@JoinColumn("user_id")
	User user;

	@Column("meta_key", 255)
	@Null
	string key; // VARCHAR(255)

	@Column("meta_value")
	@Null
	string value; // LONGTEXT
}
