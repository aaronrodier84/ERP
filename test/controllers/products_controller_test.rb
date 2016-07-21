require 'test_helper'

class ProductsControllerTest < ActionController::TestCase

  before { quick_login_user }

  let(:product) { create :product }

  describe 'PATCH #update' do
    before { create :zone, name: 'Make' }

    let(:params) { {product: { is_active: false}}}

    it "successfully executes" do
      patch :update, params.merge(id: product.id)
      assert_redirected_to product_path 
    end

    it 'calls a product change action with passed params' do
      action = mock
      action.expects(:call).with(product, {'is_active' => false})
      @controller.stubs(:actions).returns(update_product: action)
      patch :update, id: product.id, product: { is_active: false }
    end

    it 'requires product param to be present' do
      assert_raise ActionController::ParameterMissing do
        patch :update, id: product.id, something_else: {}
      end
    end
  end

  describe 'GET #index' do
    it 'is successful without params' do
      get :index
      assert_response :success
    end

    it 'is successful with :archived param' do
      product = create :product, :inactive
      assert Product.inactive.any?
      get :index, archived: true
      assert_response :success
    end
  end

  describe 'GET #products_at_zone' do
    it 'renders make tab content' do
      zone = create :zone, :make
      get :products_at_zone, zone_id: zone.id
      assert_template partial: '_products_as_tiles'
    end

    it 'renders pack tab content' do
      zone = create :zone, :pack
      get :products_at_zone, zone_id: zone.id
      assert_template partial: '_products_as_tiles'
    end

    it 'renders ship tab content' do
      zone = create :zone, :ship
      get :products_at_zone, zone_id: zone.id
      assert_template partial: '_products_as_ship_table'
    end
  end

  describe 'GET #show' do
    it 'should show the product' do
      get :show, id: product.id
      assert_response :success
    end

    it 'throws no error against ingredients' do
      create :ingredient, product: product
      assert product.ingredients.any?
      
      get :show, id: product.id
      assert_response :success
    end
  end
end
