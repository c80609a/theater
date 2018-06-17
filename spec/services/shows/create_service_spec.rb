RSpec.describe ::Services::Shows::CreateService do
  describe '#perform:' do

    context 'В базе ещё пока нет спектаклей:' do

      context 'если параметры корректны:' do

        let(:valid_params) do
          { title: 'Ревизор', start_at: '2010-10-20', stop_at: '2010-11-20' }
        end

        before do
          @result = subject.perform valid_params
        end

        it 'метод вернёт true' do
          expect(@result).to be true
        end

        it 'у сервиса станет определён атрибут @show' do
          show = subject.show
          expect(show.title).to        eq 'Ревизор'
          expect(show.start_at).to     eq Date.parse '2010-10-20'
          expect(show.stop_at).to      eq Date.parse '2010-11-20'
        end

        it 'атрибут @errors должен быть пуст' do
          expect(subject.errors.data.size).to eq 0
        end

      end#context

      context 'если параметры некорректны:' do

        let(:invalid_params) do
          { title: 'Ревизор' }
        end

        before do
          @result = subject.perform invalid_params
        end

        it 'метод вернёт false' do
          expect(@result).to be false
        end

        it 'атрибут @errors должен быть не пуст' do
          expect(subject.errors.data.size).not_to eq 0
        end

        it 'атрибут @show должен быть nil' do
          expect(subject.show).to eq nil
        end

      end#context

    end

  end
end