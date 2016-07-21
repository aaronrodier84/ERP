class PasswordGenerator

  def generate(symbols = 8)
    Devise.friendly_token.first(symbols)
  end
end
