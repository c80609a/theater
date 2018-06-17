RSpec.describe ::Validators::Shows::CreateForm do

  before { @is_valid = subject.valid? }

  context 'В базе пока еще нет Спектаклей:' do

    context 'если параметры валидные:' do

      let(:valid_params) do
        { title: 'Конёк-горбунок', start_at: '2010-10-20', stop_at: '2010-11-20' }
      end

      subject { ::Validators::Shows::CreateForm.new valid_params }

      it 'результат валидации должен быть true' do
        expect(@is_valid).to be true
      end

      it 'атрибут errors должен быть пуст' do
        expect(subject.errors.data.size).to eq 0
      end

    end

    context 'если параметры невалидные:' do

      context 'если неправильный title:' do

        context 'слишком короткий:' do

          subject { ::Validators::Shows::CreateForm.new invalid_params }

          let(:invalid_params) do
            { title: 'Ко', start_at: '2010-10-20', stop_at: '2010-11-20' }
          end

          it 'результат валидации должен быть false' do
            expect(@is_valid).to be false
          end

          it 'атрибут errors должен содержать 1 элемент' do
            expect(subject.errors.data.count).to eq 1
          end

          it 'атрибут errors должен содержать ошибку с ключом :title' do
            expect(subject.errors.data[:title].size).to eq 1
          end

          it 'причина ошибки должна быть строка \'too_short\'' do
            expect(subject.errors.data[:title].first[:reason]).to eq ::Validators::Rules::MinLength::REASON
          end

        end

        context 'слишком длинный:' do

          subject { ::Validators::Shows::CreateForm.new invalid_params }

          let(:invalid_params) do
            { title: 'Конёк-Горбунок' * 20, start_at: '2010-10-20', stop_at: '2010-11-20' }
          end

          it 'результат валидации должен быть false' do
            expect(@is_valid).to be false
          end

          it 'атрибут errors должен содержать 1 элемент' do
            expect(subject.errors.data.count).to eq 1
          end

          it 'атрибут errors должен содержать ошибку с ключом :title' do
            expect(subject.errors.data[:title].size).to eq 1
          end

          it 'причина ошибки должна быть строка \'too_short\'' do
            expect(subject.errors.data[:title].first[:reason]).to eq ::Validators::Rules::MaxLength::REASON
          end

        end

      end

      # todo:: реализовать тесты
      context 'если неправильный stop_at:'
      context 'если неправильный start_at:'

    end

  end

  ##

  context 'В базе уже есть Спектакли:' do

    context 'если параметры валидные:' do

    end

    context 'если параметры невалидные:' do

      context 'если такой title уже есть в базе:' do

        subject { ::Validators::Shows::CreateForm.new invalid_params }

        # предварительно положим в базу спектакль с таким же названием
        before(:each) do
          Show.create!({title: 'Конёк-Горбунок', start_at: '2222-10-22', stop_at: '2222-11-22'})
        end

        let(:invalid_params) do
          {title: 'Конёк-Горбунок', start_at: '2010-10-20', stop_at: '2010-11-20'}
        end

        it 'результат валидации должен быть false' do
          byebug
          expect(@is_valid).to be false
        end

        it 'атрибут errors должен содержать 1 элемент' do
          expect(subject.errors.data.count).to eq 1
        end

        it 'атрибут errors должен содержать ошибку с ключом :title' do
          expect(subject.errors.data[:title].size).to eq 1
        end

        it 'причина ошибки должна быть указана строка \'not_uniq\'' do
          expect(subject.errors.data[:title].first[:reason]).to eq ::Validators::Rule::NOT_UNIQ
        end

      end

      context 'если Спектакль наслаивается на несколько дней:' do

        subject { ::Validators::Shows::CreateForm.new invalid_params }

        # предварительно положим в базу Спектакль, который заведомо точно наслаивается
        before(:context) do
          Show.create!({ title: 'Сон в летнюю ночь', start_at: '2010-10-20', stop_at: '2010-11-20' })
        end

        let(:invalid_params) do
          { title: 'Конёк-Горбунок', start_at: '2010-11-01', stop_at: '2010-12-01' }
        end

        it 'результат валидации должен быть false' do
          expect(@is_valid).to be false
        end

        it 'атрибут errors должен содержать 1 элемент' do
          expect(subject.errors.data.count).to eq 1
        end

        it 'атрибут errors должен содержать ошибку с ключом :time' do
          expect(subject.errors.data[:time].size).to eq 1
        end

        it 'причина ошибки должна быть указана строка \'period_overlap\'' do
          expect(subject.errors.data[:time].first[:reason]).to eq ::Validators::Shows::CreateForm::REASON_OVERLAP
        end

      end

      context 'если Спектакль соприкасается хотя бы одним днём:' do

        subject { ::Validators::Shows::CreateForm.new invalid_params }

        # предварительно положим в базу Спектакль, который заведомо точно соприкасается
        before(:each) do
          Show.create!({ title: 'Ревизор', start_at: '2010-10-20', stop_at: '2010-11-20' })
        end

        let(:invalid_params) do
          { title: 'Конёк-Горбунок', start_at: '2010-11-20', stop_at: '2010-12-20' }
        end

        it 'результат валидации должен быть false' do
          expect(@is_valid).to be false
        end

        it 'атрибут errors должен содержать 1 элемент' do
          expect(subject.errors.data.count).to eq 1
        end

        it 'атрибут errors должен содержать ошибку с ключом :time' do
          expect(subject.errors.data[:time].size).to eq 1
        end

        it 'причина ошибки должна быть указана строка \'period_overlap\'' do
          expect(subject.errors.data[:time].first[:reason]).to eq ::Validators::Shows::CreateForm::REASON_OVERLAP
        end
      end

    end

  end

end
