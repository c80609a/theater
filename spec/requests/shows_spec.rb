RSpec.describe 'Shows API', :type => :request do

  describe 'GET /shows' do

    before(:context) do
      Show.create!({ title: 'Сон в летнюю ночь', start_at: '2010-10-20', stop_at: '2010-11-20' })
      Show.create!({ title: 'Конёк-Горбунок',    start_at: '2010-12-20', stop_at: '2011-01-20' })
    end

    before { get shows_path }

    after(:context) { Show.delete_all }

    it 'должен вернуть код 200' do
      expect(response).to have_http_status 200
    end

    it 'должен вернуть список всех спектаклей' do
      expect(JSON.parse(response.body).size).to eq 2
    end

    it 'в списке должны быть JSON каждого спектакля' do
      show = JSON.parse(response.body).first
      expect(show['title']).to eq    'Сон в летнюю ночь'
      expect(show['start_at']).to eq '20.10.2010'
      expect(show['stop_at']).to eq  '20.11.2010'
    end

  end#describe GET

  describe 'POST /admin/shows' do

    let(:valid_attributes) do
      { title: 'Ревизор', start_at: '2010-10-20', stop_at: '2010-11-20' }
    end

    context 'если параметры валидные:' do

      before { post '/admin/shows', params: valid_attributes }

      after(:context) { Show.delete_all }

      it 'должен вернуть код 201' do
        expect(response).to have_http_status(201)
      end

      it 'должен вернуть JSON созданного спектакля' do
        show = JSON.parse response.body
        expect(show['title']).to eq    'Ревизор'
        expect(show['start_at']).to eq '20.10.2010'
        expect(show['stop_at']).to eq  '20.11.2010'
      end

    end

  end#describe POST

  describe 'DELETE /admin/show/:id' do

    context 'Если параметры валидные:' do

      before(:context) do
        @show = Show.create!({ title: 'Конёк-Горбунок', start_at: '2010-12-20', stop_at: '2011-01-20' })
      end

      before { delete admin_show_path @show.id }

      after(:context) { Show.delete_all }

      it 'вернёт статус 204' do
        expect(response).to have_http_status(204)
      end

    end

    context 'Если параметры невалидные:' do

      context 'Если нет такого спектакля:' do

        it 'должна вылететь ошибка ActiveRecord::RecordNotFound' do
          expect { delete admin_show_path 444777 }.to raise_exception ActiveRecord::RecordNotFound
        end

      end

    end

  end#describe

end
