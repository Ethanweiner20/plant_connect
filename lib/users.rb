require 'securerandom'
require_relative 'helpers'
require 'yaml'
require 'bcrypt'
require_relative 'dbconnection'

class InvalidLoginCredentialsError < StandardError
  def initialize(msg="Invalid username or password.")
    super(msg)
  end
end

class InsecurePasswordError < StandardError
  def initialize(msg="Password must contain at least 8 characters, "\
                     "a number, and uppercase letter.")
    super(msg)
  end
end

class NonUniqueUsernameError < StandardError
  def initialize(username)
    msg = "Username '#{username}' is already taken."
    super(msg)
  end
end

class Users < DBConnection
  # Retrieve user associated with the given `user_id`, if none -> return `nil`
  def find_by_id(user_id)
    return unless user_id
    sql = 'SELECT * FROM users WHERE id = $1 LIMIT 1;'
    result = query(sql, [user_id])

    return if result.ntuples == 0
    result[0]
  end

  # Authentication: Returns a user id if the user can be found
  def authenticate(username, password)
    candidate_user = find_by_username(username)
    raise InvalidLoginCredentialsError unless candidate_user

    # Verify password hashes match in order to return the found user
    if BCrypt::Password.new(candidate_user["password_hash"]) == password
      candidate_user["id"]
    else
      raise InvalidLoginCredentialsError
    end
  end

  def create(username, password)
    raise InsecurePasswordError.new unless strong_password?(password)
    raise NonUniqueUsernameError.new(username) if find_by_username(username)

    uuid = SecureRandom.uuid
    password_hash = BCrypt::Password.create(password)

    sql = 'INSERT INTO users (id, username, password_hash) VALUES ($1, $2, $3)'
    query(sql, [uuid, username, password_hash])

    uuid
  end

  private

  def strong_password?(password)
    password =~ /.{8,}/ && password =~ /[A-Z]/ && password =~ /[0-9]/
  end

  def find_by_username(username)
    return unless username
    sql = 'SELECT * FROM users WHERE username = $1 LIMIT 1;'
    result = query(sql, [username])

    return if result.ntuples == 0
    result[0]
  end
end