module ExceptionHandler
  extend ActiveSupport::Concern

  included do

    rescue_from ActiveRecord::RecordInvalid, with: :_422
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({message: e.message}, :not_found)
    end

  end

  private

  def _422(e)
    json_response({message: e.message}, :unprocessable_entity)
  end

end