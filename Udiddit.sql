/* 	Udiddit, A Social News Aggregator
	Udacity SQL Nanodegree Program
	Khaleahcia Ford 
*/

/*	DDL statements
*/

CREATE DATABASE udiddit;

USE udiddit;

CREATE TABLE users (
    id SERIAL,
    username VARCHAR(25) UNIQUE NOT NULL,
    last_logon DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (id)
);

CREATE INDEX ind_username_lastlogon ON users (username);

CREATE TABLE topics (
    id SERIAL,
    topic_name VARCHAR(30) UNIQUE NOT NULL,
    topic_description VARCHAR(500),
    user_id BIGINT UNSIGNED,
    CONSTRAINT pk_topics PRIMARY KEY (id),
    CONSTRAINT fk_topics_user_id FOREIGN KEY (user_id)
        REFERENCES users (id)
);

CREATE TABLE posts (
    id SERIAL,
    post_title VARCHAR(100) NOT NULL,
    url TEXT,
    post_content TEXT,
    topic_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    created_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_posts PRIMARY KEY (id),
    CONSTRAINT fk_posts_topic_id FOREIGN KEY (topic_id)
        REFERENCES topics (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE SET NULL,
    CONSTRAINT url_xor_post_content CHECK ((url IS NOT NULL AND post_content IS NULL)
        OR (post_content IS NOT NULL AND url IS NULL))
);

CREATE TABLE comments (
    id SERIAL,
    comment_content TEXT NOT NULL,
    parent_id BIGINT UNSIGNED,
    post_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED,
    created_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_comments PRIMARY KEY (id),
    CONSTRAINT fk_comments_parent_id FOREIGN KEY (parent_id)
        REFERENCES comments (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_comments_post_id FOREIGN KEY (post_id)
        REFERENCES posts (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_comments_user_id FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE SET NULL
);

CREATE TABLE votes (
    id SERIAL,
    up_vote INT,
    down_vote INT,
    user_id BIGINT UNSIGNED,
    post_id BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_votes PRIMARY KEY (id),
    CONSTRAINT fk_votes_user_id FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE SET NULL,
    CONSTRAINT fk_votes_post_id FOREIGN KEY (post_id)
        REFERENCES posts (id)
        ON DELETE CASCADE,
    CONSTRAINT vote_value CHECK ((up_vote = 1 AND down_vote IS NULL)
        OR (down_vote = - 1 AND up_vote IS NULL)),
    CONSTRAINT unique_votes UNIQUE (user_id , post_id)
);

/*	DML Statements
*/

INSERT INTO udiddit.users (username) 
	SELECT bp.username
		FROM bad_udiddit.bad_posts AS bp
	UNION
	SELECT bc.username
		FROM bad_udiddit.bad_comments AS bc;
        
INSERT INTO udiddit.topics (topic_name, user_id)
	SELECT bp.topic, u.id
		FROM bad_udiddit.bad_posts AS bp
    JOIN udiddit.users AS u
		ON u.username = bp.username
    GROUP BY 1;
    
INSERT INTO udiddit.posts (post_title, url, post_content, topic_id, user_id)
	SELECT LEFT(bp.title, 100), bp.url, bp.text_content, t.id, u.id
		FROM bad_udiddit.bad_posts AS bp
	JOIN udiddit.topics AS t
		ON bp.topic = t.topic_name
	JOIN udiddit.users AS u
		ON bp.username = u.username;
        
INSERT INTO udiddit.comments(comment_content, post_id, user_id)
	SELECT bc.text_content, p.id, u.id
		FROM bad_udiddit.bad_comments AS bc
	JOIN bad_udiddit.bad_posts AS bp 
		ON bc.post_id = bp.id
	JOIN udiddit.posts AS p 
		ON p.post_title = bp.title
	JOIN udiddit.users AS u 
		ON bc.username = u.username;