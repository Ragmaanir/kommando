record(User, name : String, age : Int32, height : Int32?, nickname : String?)

USERS = [] of User

class Create
  include Kommando::Command
  option(:height, Int32, "", validate: ->(v : Int32) { (100..250).includes?(v) })
  option(:nickname, String, "", format: /\A[a-zA-Z]+\z/)

  option(:dead, Bool, "Whether the person is dead", default: false)

  arg(:name, String)
  arg(:age, Int32)

  def call
    USERS << User.new(name, age, @height, @nickname)
  end
end

test "create user with options" do
  user = User.new("Christian", 55, 175, "Chris")

  Create.call([
    "-height=#{user.height}",
    "-nickname=#{user.nickname}",
    user.name, user.age.to_s,
  ])

  assert USERS == [user]
end
