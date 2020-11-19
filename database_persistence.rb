require 'pg'

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

  def get_user_info(username)
    sql = <<~SQL
      SELECT ingredients.name FROM ingredients JOIN user_ingredients
      ON user_ingredients.ingredientid = ingredients.id JOIN users
      ON users.id = user_ingredients.userid
      WHERE users.username = '#{username}'
    ;
    SQL
  end

  def get_user_id(user)
    sql = <<~SQL
      SELECT id FROM users WHERE username = $1;
    SQL

    query(sql)[0];
  end

  def add_ingredient(ingredient, id)
    ingredient.upcase!
    # @db.exec()
    sql = <<~SQL
      INSERT INTO ingredients (name) VALUES ($1);

      INSERT INTO user_ingredients (userid, ingredientid)
              VALUES (id, );
    SQL
  end
end