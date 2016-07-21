if Rails.env.development? || Rails.env.test?
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end
