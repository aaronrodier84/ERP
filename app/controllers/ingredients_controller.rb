class IngredientsController < ApplicationController
  def edit
    @product = Product.includes(:ingredients => :material).find(params[:id])
  end

  def update
    product = Product.find(params[:id])

    respond_to do |format|
      format.json do 
        # Parameters: {
        #   "ingredients"=>{
        #      "0"=>{"material_id"=>"1", "quantity"=>"5"}, 
        #      "1"=>{"material_id"=>"2", "quantity"=>"2"}
        #   }
        # }
        ingredients_hash = params[:ingredients]&.values || {}
        if product.replace_ingredients(ingredients_hash)
          flash[:notice] = "Ingredients were successfully saved."
          render json: { redirect_to: product_url(product) }, status: :ok
        else
          render json: { error_message: product.errors.full_messages.first }, status: :unprocessable_entity
        end
      end
    end
  end
end
