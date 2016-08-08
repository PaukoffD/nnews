# == Schema Information
#
# Table name: sources
#
#  id                  :integer          not null, primary key
#  name                :string
#  ref                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  avatar_file_name    :string
#  avatar_content_type :string
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#

class SourcesController < ApplicationController
  before_action :set_source, only: [:show, :edit, :update, :destroy]


def sourceexport
    @sources = Source.all
    f=File.new('sources.txt', 'w+') 

     @sources.each do |tt|
      f << tt.name + ";"+ tt.ref+ ";"+tt.created_at.to_s+ ";"+tt.updated_at.to_s+ ";"+tt.avatar_file_name+ ";"+tt.avatar_content_type+ ";"+ tt.avatar_file_size.to_s+ ";"+ tt.avatar_updated_at.to_s+";"
     end
  end




def sourceimport
    #@tags = Tagecxept.new
   #csv_text = File.read('tags1.txt')
   csv = CSV.foreach('sources.txt', :headers => false)
   csv.each do |row|
   a=row.to_s.split(";")
   a.each do |b|
    tag = Tagexcept.new
    if b.match("\\[")
       tag.name=b[2,b.length-2]
     elsif  !b.match('\\]')
       tag.name=b
     end
    tag.save
   end
   end
  end

  def index
    @sources = Source.all
  end

  def show
  end

  def new
    @source = Source.new
  end

  def edit
  end

  def create
    @source = Source.new(source_params)

    respond_to do |format|
      if @source.save
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render :show, status: :created, location: @source }
      else
        format.html { render :new }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
        format.json { render :show, status: :ok, location: @source }
      else
        format.html { render :edit }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @source.destroy
    respond_to do |format|
      format.html { redirect_to sources_url, notice: 'Source was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_source
    @source = Source.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def source_params
    params.require(:source).permit!
  end
end
