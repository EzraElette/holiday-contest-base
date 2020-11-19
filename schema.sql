CREATE TABLE users(
  id serial PRIMARY KEY,
  username text UNIQUE NOT NULL,
  userPassword text NOT NULL
);

CREATE TABLE images(
  id serial PRIMARY KEY,
  encodedImage text NOT NULL UNIQUE,
  userid int NOT NULL REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE ingredients(
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE user_ingredients(
  id serial PRIMARY KEY,
  userid int NOT NULL REFERENCES user(id) ON DELETE CASCADE,
  ingredientid int NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
);