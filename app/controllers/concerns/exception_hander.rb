module ExceptionHandler
  extend ActiveSupport::Concern

  included do

    rescue_from ActiveRecord::RecordInvalid, with: :_422
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({message: I18n.t('system.errors.record_not_found')}, :not_found)
    end

  end

  private

  def _422(e)
    json_response({message: I18n.t('system.errors.record_invalid')}, :unprocessable_entity)
  end

end
