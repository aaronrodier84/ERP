require 'test_helper'

class MaterialsControllerTest < ActionController::TestCase

  before { quick_login_user }
  let(:material) { create :material }
  let(:zone) { create :zone }

  describe 'GET #index' do
    it 'renders index' do
      get :index
      assert_template :index
    end

    it 'is successful' do
      get :index
      assert_response 200 
    end
  end

  describe 'GET #new'  do
    it 'renders new' do
      get :new
      assert_template :new
    end

    it 'is successful' do
      get :new
      assert_response 200
    end
  end

  describe 'GET #edit' do
    it 'renders edit' do
      get :edit, id: material.id
      assert_template :edit
    end

    it 'is successful' do
      get :edit, id: material.id
      assert_response 200
    end
  end

  describe 'POST #create' do
    describe 'when successful' do
      let(:params) {{ material: { zone_id: zone.id, name: "Oil", unit: "kg", unit_price: 2.99} }}
      
      it 'redirects to index' do
        post :create, params
        assert_redirected_to materials_path
      end

      it 'creates a material from params' do 
        post :create, params
        new_material = Material.reorder(:id).last
        assert_equal zone,  new_material.zone
        assert_equal "Oil", new_material.name
        assert_equal "kg",  new_material.unit
        assert_equal 2.99,  new_material.unit_price
      end
    end

    describe 'when failed' do
      let(:params) {{ material: {zone_id: ''} }}

      it 'renders new again' do
        post :create, params
        assert_template :new
      end
    end
  end

  describe 'PUT #update' do
    describe 'when successful' do
      let(:params) {{ id: material.id, material: { zone_id: zone.id, name: "Oil", unit: "kg", unit_price: 2.99} }}
      
      it 'redirects to index' do
        put :update, params
        assert_redirected_to materials_path
      end

      it 'updates the material from params' do 
        put :update, params
        material.reload
        assert_equal zone,  material.zone
        assert_equal "Oil", material.name
        assert_equal "kg",  material.unit
        assert_equal 2.99,  material.unit_price
      end
    end

    describe 'when failed' do
      let(:params) {{ id: material.id, material: {zone_id: ''} }}

      it 'renders edit again' do
        put :update, params
        assert_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to index' do
      delete :destroy, id: material.id
      assert_redirected_to materials_path
    end

    it 'destroys the material' do 
      material = create :material
      assert_difference ->{Material.count}, -1 do
        delete :destroy, id: material.id
      end
    end
  end
end
