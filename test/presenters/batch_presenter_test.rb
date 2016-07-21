require 'test_helper'

class BatchPresenterTest < ActiveSupport::TestCase

  let(:batch) { OpenStruct.new }

  describe '#product_image_url' do
    it 'gets image url from product' do
      product = stub(small_image_url: 'http://google.com' )
      batch.product = product 
      presenter = described_class.new batch
      assert_equal 'http://google.com', presenter.product_image_url
    end

    it 'is nil if product nil' do
      presenter = described_class.new batch
      assert_equal nil, presenter.product_image_url
    end
  end

  describe '#product_title' do
    it 'gets title from product' do
      product = stub(internal_title: 'I am a title')
      batch.product = product

      presenter = described_class.new batch
      assert_equal 'I am a title', presenter.product_title
    end

    it 'is nil if product nil' do
      presenter = described_class.new batch
      assert_equal nil, presenter.product_title
    end
  end

  describe '#active_users' do
    it 'returns active users' do
      users = build_list :user, 3
      User.stubs(:active).returns(users)
      presenter = described_class.new batch
      assert_equal users, presenter.active_users
    end
  end

  describe '#zone_id' do
    it 'provides batch zone id' do
      batch.zone_id = 100
      presenter = described_class.new batch
      assert_equal 100, presenter.zone_id
    end
  end

  describe '#zone_name' do
    it 'provides zone name' do
      batch.zone = stub(name: 'Some Zone')
      presenter = described_class.new batch
      assert_equal 'Some Zone', presenter.zone_name
    end
  end
end
