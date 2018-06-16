RSpec.describe 'Shows API', :type => :request do

  # let(:show_id) { shows.first.id }
  let(:show_id) { 1 }

  describe 'GET /shows' do
    before { get shows_path }

    it 'должен вернуть код 200' do
      expect(response).to have_http_status 200
    end

    it 'должен вернуть список всех спектаклей' do
      expect(JSON.parse(response.body).size).to eq 3
    end
  end#describe GET

  describe 'POST /shows' do
    let(:valid_attributes) do
      { title: 'Ревизор', start_at: '2010-10-20', stop_at: '2010-11-20' }
    end

    context 'если параметры валидные:' do

      before do
        post '/shows', params: valid_attributes
      end

      it 'должен вернуть код 201' do
        expect(response).to have_http_status(201)
      end

    end
  end#describe POST

  describe 'DELETE /show/:id' do
    before { delete show_path(show_id) }

    it 'вернёт статус 204' do
      expect(response).to have_http_status(204)
    end

  end#describe

end
