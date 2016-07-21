module DeviseHelper

  # Hack to get around Devise using flash messages for login failures:
  # This forces the validation and is called from within the form.
  # https://github.com/plataformatec/devise/issues/259
  def validate_hack!
    resource.validate if request.post?
    ''
  end

end
