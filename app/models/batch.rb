# == Schema Information
#
# Table name: batches
#
#  id           :integer          not null, primary key
#  product_id   :integer
#  quantity     :integer
#  notes        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_on :date
#  zone_id      :integer
#

class Batch < ActiveRecord::Base

  belongs_to :product
  belongs_to :zone
  has_and_belongs_to_many :users

  scope :fresh_first, -> { order(completed_on: :desc, created_at: :desc)}

  validates_presence_of :quantity
  validates_presence_of :user_ids, :message => " must be selected"

  #enum status: { not_started: 10, filled: 20, packaged: 30 }
  #enum status: { filled: 20, packaged: 30 }

  attr_reader :case_quantity

  delegate :items_per_case, to: :product, prefix: true

  def pack_zone?
    zone&.pack?
  end
end
