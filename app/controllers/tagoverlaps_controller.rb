# == Schema Information
#
# Table name: tagoverlaps
#
#  id           :integer          not null, primary key
#  tag_id       :integer
#  name         :string
#  tagtarget_id :integer
#  nametarget   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class TagoverlapsController < ApplicationController
  before_action :set_tagoverlap, only: [:show, :edit, :update, :destroy]

  # GET /tagoverlaps
  # GET /tagoverlaps.json
  def index
    @tagoverlaps = Tagoverlap.all
  end

  # GET /tagoverlaps/1
  # GET /tagoverlaps/1.json
  def show
  end

  # GET /tagoverlaps/new
  def new
    @tagoverlap = Tagoverlap.new
  end

  # GET /tagoverlaps/1/edit
  def edit
  end

  # POST /tagoverlaps
  # POST /tagoverlaps.json
  def create
    @tagoverlap = Tagoverlap.new(tagoverlap_params)

    respond_to do |format|
      if @tagoverlap.save
        format.html { redirect_to @tagoverlap, notice: 'Tagoverlap was successfully created.' }
        format.json { render :show, status: :created, location: @tagoverlap }
      else
        format.html { render :new }
        format.json { render json: @tagoverlap.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tagoverlaps/1
  # PATCH/PUT /tagoverlaps/1.json
  def update
    respond_to do |format|
      if @tagoverlap.update(tagoverlap_params)
        format.html { redirect_to @tagoverlap, notice: 'Tagoverlap was successfully updated.' }
        format.json { render :show, status: :ok, location: @tagoverlap }
      else
        format.html { render :edit }
        format.json { render json: @tagoverlap.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tagoverlaps/1
  # DELETE /tagoverlaps/1.json
  def destroy
    @tagoverlap.destroy
    respond_to do |format|
      format.html { redirect_to tagoverlaps_url, notice: 'Tagoverlap was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tagoverlap
    @tagoverlap = Tagoverlap.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tagoverlap_params
    params.require(:tagoverlap).permit(:tag_id, :name, :tagtarget_id, :nametarget)
  end
end
