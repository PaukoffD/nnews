# == Schema Information
#
# Table name: tagexcepts
#
#  id         :integer          not null, primary key
#  tag_id     :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TagexceptsController < ApplicationController
  before_action :set_tagexcept, only: [:show, :edit, :update, :destroy]

  # GET /tagexcepts
  # GET /tagexcepts.json
  def index
    @tagexcepts = Tagexcept.all
  end

  # GET /tagexcepts/1
  # GET /tagexcepts/1.json
  def show
  end

  # GET /tagexcepts/new
  def new
    @tagexcept = Tagexcept.new
  end

  # GET /tagexcepts/1/edit
  def edit
  end

  # POST /tagexcepts
  # POST /tagexcepts.json
  def create
    @tagexcept = Tagexcept.new(tagexcept_params)

    respond_to do |format|
      if @tagexcept.save
        format.html { redirect_to @tagexcept, notice: 'Tagexcept was successfully created.' }
        format.json { render :show, status: :created, location: @tagexcept }
      else
        format.html { render :new }
        format.json { render json: @tagexcept.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tagexcepts/1
  # PATCH/PUT /tagexcepts/1.json
  def update
    respond_to do |format|
      if @tagexcept.update(tagexcept_params)
        format.html { redirect_to @tagexcept, notice: 'Tagexcept was successfully updated.' }
        format.json { render :show, status: :ok, location: @tagexcept }
      else
        format.html { render :edit }
        format.json { render json: @tagexcept.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tagexcepts/1
  # DELETE /tagexcepts/1.json
  def destroy
    @tagexcept.destroy
    respond_to do |format|
      format.html { redirect_to tagexcepts_url, notice: 'Tagexcept was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tagexcept
    @tagexcept = Tagexcept.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tagexcept_params
    params.require(:tagexcept).permit(:tag_id, :name)
  end
end
