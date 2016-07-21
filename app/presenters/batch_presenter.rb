class BatchPresenter
  attr_reader :batch

  delegate :zone, :zone_id, :pack_zone?, to: :batch

  def initialize(batch)
    @batch = batch
  end

  def product_image_url
    batch.product&.small_image_url
  end

  def product_title
    batch.product&.internal_title
  end

  def active_users
    User.active
  end

  def zone_name
    batch.zone&.name
  end

end
