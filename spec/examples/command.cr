record(User, name : String, age : Int32, height : Int32?, nickname : String?)

USERS = [] of User

class Create < Kommando::Command(Nil)
  option(:height, Int32, validate: ->(v : Int32) { (100..250).includes?(v) })
  option(:nickname, String, format: /\A[a-zA-Z]+\z/)

  option(:dead, Bool, "Wether the person is dead", default: false)

  def call(name : String, age : Int32)
    USERS << User.new(name, age, @height, @nickname)
  end
end

test "create user with options" do
  user = User.new("Christian", 55, 175, "Chris")

  Create.run(nil, [
    "-height", user.height.to_s,
    "-nickname", user.nickname.to_s,
    user.name, user.age.to_s,
  ])

  assert USERS == [user]
end
