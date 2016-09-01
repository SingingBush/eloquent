-- sqlite> .read schema.sql
-- or we could create a sqlite db file using dub preBuildCommands: "sqlite3 testdb.sqlite < schema.sql"

DROP TABLE IF EXISTS wp_commentmeta;
DROP TABLE IF EXISTS wp_comments;
DROP TABLE IF EXISTS wp_options;
DROP TABLE IF EXISTS wp_postmeta;
DROP TABLE IF EXISTS wp_posts;
DROP TABLE IF EXISTS wp_usermeta;
DROP TABLE IF EXISTS wp_users;

CREATE TABLE wp_commentmeta(
  meta_id INTEGER PRIMARY KEY AUTOINCREMENT,
  comment_id INTEGER NOT NULL DEFAULT 0,
  meta_key varchar(255),
  meta_value longtext
);

CREATE TABLE wp_comments(
  comment_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  comment_post_ID INTEGER DEFAULT 0,
  comment_author tinytext,
  comment_author_email varchar(100),
  comment_author_url varchar(200),
  comment_author_IP varchar(100),
  comment_date datetime DEFAULT '0000-00-00 00:00:00',
  comment_date_gmt datetime DEFAULT '0000-00-00 00:00:00',
  comment_content text,
  comment_karma int(11) DEFAULT 0,
  comment_approved varchar(20) DEFAULT 1,
  comment_agent varchar(255),
  comment_type varchar(20),
  comment_parent INTEGER DEFAULT 0,
  user_id	INTEGER DEFAULT 0
);

CREATE TABLE wp_options(
  option_id INTEGER PRIMARY KEY AUTOINCREMENT,
  option_name varchar(64),
  option_value longtext,
  autoload varchar(20) DEFAULT 'YES'
);


CREATE TABLE wp_postmeta(
  meta_id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER DEFAULT 0,
  meta_key varchar(255),
  meta_value longtext
);

CREATE TABLE wp_posts(
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  post_author INTEGER DEFAULT 0,
  post_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  post_modified datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  post_content longtext NOT NULL,
  post_title text NOT NULL,
  post_excerpt text NOT NULL,
  post_type varchar(20) NOT NULL,
  post_status varchar(20) DEFAULT 'publish',
  comment_status varchar(20) DEFAULT 'open',
  ping_status varchar(20) DEFAULT 'open'
);

CREATE TABLE wp_usermeta(
  umeta_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER DEFAULT 0,
  meta_key varchar(255),
  meta_value longtext
);

CREATE TABLE wp_users(
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  user_login varchar(60),
  user_pass varchar(64),
  user_nicename varchar(50),
  user_email varchar(100),
  user_url varchar(100),
  user_registered datetime DEFAULT '0000-00-00 00:00:00',
  user_activation_key varchar(60),
  user_status int(11) DEFAULT 0,
  display_name varchar(250) NULL
);

INSERT INTO wp_users(user_login, user_pass, user_nicename, user_email, user_url, user_registered)
VALUES
  ('admin', 'password', 'Nice Name', 'user@domain.com', NULL, CURRENT_TIMESTAMP),
  ('user', 'password', 'Administrator', 'admin@domain.com', NULL, CURRENT_TIMESTAMP);

INSERT INTO wp_usermeta(user_id, meta_key, meta_value)
VALUES
(2, 'capabilities', 'a:1:{s:13:"administrator";s:1:"1";}'),
(2, 'user_level', 10);