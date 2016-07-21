module Users
  class DestroyUser
    
    def call(user)
      return StoreResult.new(entity: user, success: false, errors: 'User is nil') unless user

      if user.destroy
        return StoreResult.new(entity: nil, success: true, errors: nil)
      else
        return StoreResult.new(entity: user, success: false, errors: user.errors )
      end
    end
  end
end
