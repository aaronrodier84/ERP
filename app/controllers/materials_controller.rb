class MaterialsController < ApplicationController
  
  def index
    @materials = Material.ordered_by_id.includes(:zone)
  end

  def new
    @material = Material.new
  end

  def edit
    @material = Material.find(params[:id])
  end

  def create
    @material = Material.new(material_params)

    if @material.save
      redirect_to materials_path, notice: 'Material was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @material = Material.find(params[:id])

    respond_to do |format|
      if @material.update(material_params)
        format.html { redirect_to materials_path, notice: 'Material was successfully updated.' }
        format.json { head :no_content, status: :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: {error: @material.errors.full_messages.join('. ')}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @material = Material.find(params[:id])

    if @material.destroy
      flash[:notice] = "Material was deleted."
    else
      flash[:error] = "Cannot delete. #{@material.errors.full_messages.join(' ')}"
    end    
    redirect_to materials_path
  end

  def material_params
    params.require(:material).permit(:zone_id, :name, :unit, :unit_price, :inventory_quantity)
  end
end
