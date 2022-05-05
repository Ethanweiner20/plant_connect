class User
  attr_reader :id, :username
  
  def initialize(user_id, username)
    @id = user_id
    @username = username
  end
end