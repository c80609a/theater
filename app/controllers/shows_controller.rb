class ShowsController < ApplicationController
  include CanSerializeShow

  def index
    serialized = Show.all.map { |s| serialize_show s }
    json_response serialized
  end

end
