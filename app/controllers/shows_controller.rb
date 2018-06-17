class ShowsController < ApplicationController
  include CanSerializeShow
  before_action :set_show, :only => [:destroy]

  def index
    json_response Show.all
  end

  def create
    service = ::Services::Shows::CreateService.new
    if service.perform(show_params)
      json_response serialize_show(service.show), :created
    else
      json_response({messages: service.errors.translate}, :bad_request)
    end

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
