module Users
  class UpdateUser
    
    def call(user, user_params)
      return StoreResult.new(entity: user, success: false, errors: ['User is nil']) unless user

      if user.update user_params
        return StoreResult.new entity: user, success: true, errors: nil
      else
        return StoreResult.new entity: user, success: false, errors: user.errors
      end
    end
  end
end
