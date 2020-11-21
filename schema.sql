CREATE TABLE users(
  id serial PRIMARY KEY,
  username text UNIQUE NOT NULL,
  userPassword text NOT NULL
);

CREATE TABLE images(
  id serial PRIMARY KEY,
  encodedImage text NOT NULL,
  userid int NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  votes int NOT NULL DEFAULT 0;
  name varchar(50) NOT NULL
);

CREATE TABLE ingredients(
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE user_ingredients(
  id serial PRIMARY KEY,
  userid int NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  ingredientid int NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
  random boolean DEFAULT FALSE,
);

CREATE TABLE user_likes(
  id serial PRIMARY KEY,
  userid int NOT NULL REFERENCES users(id),
  imageid int NOT NULL REFERENCES images(id),
  CONSTRAINT uniq_user_img_like UNIQUE(userid, imageid)
);