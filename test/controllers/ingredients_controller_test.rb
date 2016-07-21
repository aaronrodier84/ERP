require 'test_helper'

class IngredientsControllerTest < ActionController::TestCase

  before { quick_login_user }
  let(:product)  { create :product }
  let(:material) { create :material }

  describe 'GET #edit' do
    it 'renders "edit"' do
      get :edit, id: product.id
      assert_template :edit
    end

    it 'is successful' do
      get :edit, id: product.id
      assert_response 200
    end
  end

  describe 'POST #update in json' do
    let(:params) {
      { 
        :format => :json,
        :id => product.id,
        "ingredients" => { "0"=> {"material_id" => material.id, "quantity" => "5"} } 
      }
    }
  
    it 'responds :ok if successful' do
      post :update, params
      assert_response 200
    end

    it 'responds :unprocessable_entity if bad params' do
      params["ingredients"]["0"].delete("material_id")
      post :update, params
      assert_response 422
    end
  end
 
end
