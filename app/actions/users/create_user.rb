module Users
  class CreateUser

    def initialize(password_generator = PasswordGenerator.new)
      @password_generator = password_generator
    end

    def call(user_params)
      user = User.new user_params
      user.password = password_generator.generate
      if user.save
        return StoreResult.new(entity: user, success: true, errors: nil )
      else
        return StoreResult.new(entity: user, success: false, errors: user.errors)
      end
    end

    private
    attr_reader :password_generator
  end
end
