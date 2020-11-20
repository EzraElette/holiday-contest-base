require 'pg'
require 'pry'
class DatabasePersistence

  def initialize
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: 'thanksgiving');
    end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def get_user_pass(username)
    sql = <<~SQL
      SELECT * FROM users WHERE username = $1;
    SQL
    query(sql, username).map{ |tuple| tuple['userpassword']}[0]
  end

  def get_ingredients(username)
    sql = <<~SQL
      SELECT DISTINCT ingredients.name FROM ingredients JOIN user_ingredients
      ON user_ingredients.ingredientid = ingredients.id JOIN users
      ON users.id = user_ingredients.userid
      WHERE users.username = $1
    ;
    SQL
    res = query(sql, username)
    arr = []
    res.each { |i| arr.push(i) }
    arr
  end

  def get_user_id(user)
    sql = <<~SQL
      SELECT id FROM users WHERE username = $1;
    SQL

    query(sql, user)[0]['id'];
  end

  def get_ingredient_id(ingredient)
    sql = <<~SQL
      SELECT id FROM ingredients WHERE name = $1;
    SQL

    p query(sql, ingredient)[0]["id"].to_i
  end

  def add_ingredient_to_user(user_id, ingredient_id)
    sql = <<~SQL
      INSERT INTO user_ingredients (userid, ingredientid) VALUES ($1, $2);
    SQL

    query(sql, user_id, ingredient_id)
  end

  def ingredient_exists?(ingredient)
    sql = <<~SQL
      SELECT name FROM ingredients WHERE name = $1;
    SQL

    query(sql, ingredient.upcase).count > 0
  end

  def add_ingredient(ingredient, userid)
    ingredient.upcase!

    sql = <<~SQL
      INSERT INTO ingredients (name) VALUES ($1);
    SQL

    unless ingredient_exists?(ingredient)
      query(sql, ingredient)
    end

    ingredient_id = get_ingredient_id(ingredient)

    add_ingredient_to_user(userid, ingredient_id);
  end

  def get_random_ingredients(username)
    sql = <<~SQL
      SELECT ingredients.name FROM ingredients WHERE ingredients.id NOT IN (
        SELECT ingredients.id FROM ingredients JOIN user_ingredients
        ON user_ingredients.ingredientid = ingredients.id JOIN users
        ON users.id = user_ingredients.userid
        WHERE users.username = $1
      ) ORDER BY RANDOM() LIMIT 5;
    SQL

    p random_ingredients = query(sql, username)
    user_id = get_user_id(username).to_i
    random_ingredients.each do |ingredient|
      ingredient_id = get_ingredient_id(ingredient["name"])

      add_ingredient_to_user(user_id, ingredient_id)
    end
  end

  def username_available?(username)
    sql = <<~SQL
      SELECT (username) FROM users WHERE username = $1
    SQL

    query(sql, username).ntuples == 0
  end

  def add_user(username, password)
    sql = <<~SQL
      INSERT INTO users (username, userPassword) VALUES ($1, $2);
    SQL

    query(sql, username, password)
  end
end