require 'test_helper'

class BatchesControllerTest < ActionController::TestCase

  before { quick_login_user }

  let(:success_result) { mock(success?: true)}

  def stub_controller_action(action_name, action)
    @controller.stubs(:actions).returns({ action_name => action})
  end

  describe 'GET #index' do
    it 'renders index' do
      get :index
      assert_template :index
    end

    it 'is successful when no batches' do
      get :index
      assert_response 200 
    end

    it 'is successful when there are batches' do
      create :batch, :with_product, :with_zone
      create :batch, :with_product, :with_zone, completed_on: Date.today, notes: "abc"
      get :index
      assert_response 200 
    end
  end

  describe 'GET #new'  do
    it 'is successful' do
      get :new
      assert_response 200
    end

    it 'renders "new"' do
      get :new
      assert_template :new
    end
  end

  describe 'GET #show' do
    let(:batch) { create :batch, :with_product, :with_zone }

    it 'is successful' do
      get :show, id: batch.id
      assert_response 200
    end

    it 'renders show' do
      get :show, id: batch.id
      assert_template :show
    end
  end

  describe 'GET #edit' do
    let(:batch) { create :batch }

    it 'renders "new" with proper batch' do
      get :edit, id: batch.id
      assert_template :edit
    end

    it 'is successful' do
      get :edit, id: batch.id
      assert_response 200
    end
  end

  describe 'POST #create' do
    let(:params) {{ batch: { quantity: 10, user_ids: [@user.id]}}}
    let(:action) { stub(call: success_result) }

    it 'redirects to batches path when successful' do
      stub_controller_action :create_batch, action
      post :create, params
      assert_redirected_to batches_path
    end

    it 'instantiates batch creation action with passed params' do
      action.expects(:call).once.returns(success_result)
      stub_controller_action :create_batch, action
      post :create, params
    end

    describe 'when creation is successful' do
      it 'redirects to all batches page' do 
        stub_controller_action :create_batch, action
        post :create, params
        assert_redirected_to batches_path
      end
    end

    describe 'when creation failed' do
      let(:batch) { Batch.new }
      let(:failed_to_create) { mock(success?: false, entity: batch, error_message: '') }

      it 'renders "new" page again' do
        action = mock(call: failed_to_create) 
        stub_controller_action :create_batch, action
        post :create, params
        assert_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:batch) { create :batch }
    let(:params) { { id: batch.id, batch: { quantity: 10}} }
    let(:action) { stub(call: success_result) }

    it 'redirects to all batches if successful' do
      stub_controller_action :change_batch, action
      put :update, params

      assert_redirected_to batches_path 
    end

    it 'calls appropriate action to update batch' do
      action.expects(:call).once.returns(success_result)
      stub_controller_action :change_batch, action
      put :update, params
    end

    describe 'when update failed' do
      let(:failed_to_update)  { stub(success?: false, entity: batch, error_message: '')}

      it 'renders "edit" page again' do
        action = stub(call: failed_to_update)
        stub_controller_action :change_batch, action

        put :update, params
        assert_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:batch) { create :batch }
    let(:success_result) { stub(success?: true)}

    it 'invokes batch deletion action with found batch' do
      action = mock(call: success_result)
      stub_controller_action :destroy_batch, action
      @controller.stubs(:actions).returns(destroy_batch: action)
      delete :destroy, id: batch.id
    end

    describe 'when successful' do
      it 'redirects to all batches' do
        action = stub(call: success_result)
        stub_controller_action :destroy_batch, action 
        delete :destroy, id: batch.id
        assert_redirected_to batches_path
      end
    end

    describe 'when not successful' do
      let(:failure_result) { stub(success?: false, error_message: '')}

      it 'redirects to all batches' do
        action = stub(call: failure_result)
        stub_controller_action :destroy_batch, action
        delete :destroy, id: batch.id
        assert_redirected_to batches_path
      end
    end
  end

  describe 'POST #create_with_shipment' do
    let(:fba_warehouse) { create :fba_warehouse, name: 'PHX7' }
    let(:pack_zone) { create :zone, name: 'Pack' }
    let(:product) { create :product, seller_sku: '12345' }
    let(:product_inventory) { create :product_inventory, quantity: 5000, zone: pack_zone, product: product }
    let(:fba_allocation) { create :fba_allocation, product: product, fba_warehouse: fba_warehouse, quantity: 10000}

    let(:expected_success_result) { [{"product_id" => product.id, "quantity" => "100"}] }
    let(:expected_inventory_overflow_error) { {"error" => {"code" => 'err_overflow_inventory'}} }
    let(:expected_invalid_shipment_plans_error) { {"error" => {"code" => 'err_create_shipment_plans'}} }
    let(:expected_invalid_shipment_error) { {"error" => {"code" => 'err_create_shipment'}} }

    let(:success_result) { stub(success?: true)}
    let(:action) { stub(call: success_result) }
    let(:inbound_shipment_processor) { stub(create_shipment_plan: {}) }
    let(:item) { OpenStruct.new(seller_sku: '12345', quantity: 50) }
    let(:inbound_shipment_plans) { [OpenStruct.new(destination_fulfillment_center_id: fba_warehouse.name, items: [item])] }
    let(:shipment_plans_result) { ShipmentPlansResult.new(inbound_shipment_plans, true, []) }
    let(:shipment_plans_result_fail) { ShipmentPlansResult.new([], false, []) }

    before do
      @controller.stubs(:inbound_shipment_processor).returns( inbound_shipment_processor )
      @controller.stubs(:create_batches_from_items)
      inbound_shipment_processor.stubs(:create_shipment_plan).with(anything).returns(anything)
      inbound_shipment_processor.stubs(:create_shipment).with(anything, anything).returns(anything)
    end

    it 'returns results when successful' do
      @controller.stubs(:valid_quantity_to_ship).returns( true )
      inbound_shipment_processor.stubs(:create_shipment_plan).with(anything).returns(shipment_plans_result)
      post :create_with_shipment, {
                                    :format => 'json',
                                    :productsToShip => "[{\"product_id\":#{product.id},\"quantity\":\"100\"}]",
                                    :shipmentName => "2016/6/27 PHX7",
                                    :warehouseId => fba_warehouse.id
                                  }
      assert_equal expected_success_result, JSON.parse(@response.body)
    end

    it 'returns results when inventory overflow' do
      @controller.stubs(:valid_quantity_to_ship).returns( false )
      post :create_with_shipment, {
                                    :format => 'json',
                                    :productsToShip => "[{\"product_id\":#{product.id},\"quantity\":\"100\"}]",
                                    :shipmentName => "2016/6/27 PHX7",
                                    :warehouseId => fba_warehouse.id
                                }
      assert_equal expected_inventory_overflow_error, JSON.parse(@response.body)
    end

    it 'returns results when creating inbound shipment plans fails' do
      @controller.stubs(:valid_quantity_to_ship).returns( true )
      inbound_shipment_processor.stubs(:create_shipment_plan).with(anything).returns(shipment_plans_result_fail)
      post :create_with_shipment, {
                                    :format => 'json',
                                    :productsToShip => "[{\"product_id\":#{product.id},\"quantity\":\"100\"}]",
                                    :shipmentName => "2016/6/27 PHX7",
                                    :warehouseId => fba_warehouse.id
                                }
      assert_equal expected_invalid_shipment_plans_error, JSON.parse(@response.body)
    end

    it 'returns results when creating inbound shipment fails' do
      @controller.stubs(:valid_quantity_to_ship).returns( true )
      inbound_shipment_processor.stubs(:create_shipment_plan).with(anything).returns(shipment_plans_result)
      inbound_shipment_processor.stubs(:create_shipment).with(anything, anything).returns(nil)
      post :create_with_shipment, {
                                    :format => 'json',
                                    :productsToShip => "[{\"product_id\":#{product.id},\"quantity\":\"100\"}]",
                                    :shipmentName => "2016/6/27 PHX7",
                                    :warehouseId => fba_warehouse.id
                                }
      assert_equal expected_invalid_shipment_error, JSON.parse(@response.body)
    end

  end
end
