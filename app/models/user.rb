# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_active              :boolean          default(TRUE)
#  first_name             :string
#  last_name              :string
#  admin                  :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable, :recoverable, :registerable,
          :rememberable, :trackable, :validatable

  has_many :user_zones
  has_many :zones, through: :user_zones

  scope :active, -> { where(is_active: true)}
  scope :inactive, -> { where(is_active: false)}
  scope :ordered, -> { order(:first_name)}

  # Verify is_active before loggin user in
  def active_for_authentication?
		super && is_active
	end

  def zone?(zone)
    user.zone_ids.include?(zone.id)
  end

  concerning :Name do
    def name_and_email
      "#{full_name} (#{email})"
    end

    def display_name
      full_name.present? ? full_name : email
    end

    def full_name
      first_name.to_s + ' ' + last_name.to_s
    end

    # This is a temporary solution. To be replaced with User#nickname.
    # "JS" for "John Smith"
    def nickname
      if first_name || last_name
        "#{first_name.to_s[0]}#{last_name.to_s[0]}"
      else
        email[0].capitalize
      end
    end
  end
end
