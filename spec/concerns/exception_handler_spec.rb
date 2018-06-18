RSpec.describe ApplicationController, type: :controller do

  describe 'rescue_from ActiveRecord::RecordNotFound' do

    # пытаемся найти в базе заведомо несуществующую запись
    controller do
      include ExceptionHandler
      def index
        Show.find 200
      end
    end

    before { get :index }

    it 'придёт сообщение "Записи не существует"' do
      message = JSON.parse(response.body)
      # noinspection RubyStringKeysInHashInspection
      expect(message).to eq ({ 'message' => 'Записи не существует.'})
    end

  end

  describe 'rescue_from ActiveRecord::RecordInvalid' do

    # пытаемся положить в базу заведомо неверные данные
    controller do
      include ExceptionHandler
      def index
        Show.create!({title:'A'})
      end
    end

    before { get :index }

    it 'придёт сообщение "Неверные данные!"' do
      message = JSON.parse(response.body)
      # noinspection RubyStringKeysInHashInspection
      expect(message).to eq ({ 'message' => 'Неверные данные!'})
    end

  end

end
