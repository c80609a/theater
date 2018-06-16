class ShowsController < ApplicationController

  before_action :set_show, :only => [:destroy]

  def index
    json_response Show.all
  end

  def create
    show = Show.create show_params
    json_response show, :created
  end

  def destroy
    @show.destroy
    head :no_content
  end

  private

  def set_show
    @show = Show.find params[:id]
  end

  def show_params
    params.permit :title, :start_at, :stop_at
  end
end
