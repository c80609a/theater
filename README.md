# Тестовое Задание

Мы создаем сайт для небольшого театра.
В театре один зал. Театр показывает один спектакль в день, начало показа 18:00.
Нужно реализовать интерфейс администратора и зрителя, который позволяет составлять афишу.
Авторизации нет, админский аккаунт один, хотя админов может быть несколько.
Доступ к админке через HTTP Authentication на уровне Nginx.

Спектакль характеризуется названием датой начала и датой окончания показа:
- 'Конек горбунок', 08 Aug 2017 => Fri, 18 Aug 2017
- 'Сон в летнюю ночь' 20 Aug 2017 => Tue, 25 Aug 2017
- 'Ревизор', 26 Aug 2017 => Tue, 08 Oct 2017

[X] Необходимо сделать проверку, того чтобы не было 'наслаивания дат'.

Use cases:
- [X] Я как администратор могу добавить новый спектакль;
- [X] Я как администратор могу удалить спектакль;
- [X] Я как зритель могу посмотреть список спектаклей;

Реализовать все на уровне API. REST - json.
Написать тесты которые проверяют наслаивание.
Код выложить на github/gitlab, с осмысленными коммитами.

Будет плюсом:

- [ ] html интерфейс для работы с api (например на react)
- [X] полное тестовое покрытие

Нагрузка на проект не самая большая код предпочтительно читаемый, чем быстрый.
Язык разработки - ruby, можно использовать [X] Rails, можно [ ] sinatra. БД строго postgres.
Можно использовать нестандартные типы хранения данных.

# Пояснения

- проверка "наслаивания" происходит на этапе попытки записи в базу
- выбрал Rails, т.к. всё знакомо и хотелось испытать генератор `rails new` с ключом `--api`
- не фокусировался на фронте - всё время отвёл под backend и тесты. Тестами покрыто всё, кроме `lib/validators`. 
- обкатал навыки тестирования, динамического программирования (`lib/validators`)
- не решал стандартно: вся обвязка (валидатор, сервис, сериалайзер, lib support) -- энтерпрайзная, проверенная на боевом текущем проекте.
- потратил не 5-6 часов, а 2 дня по 8 часов с перерывами (+утро понедельника).

# Preparing

```
$ ruby -v  # ruby 2.3.3p222
$ rails -v # Rails 5.2.0
$ rails new theater -T -d postgresql --api
$ cd theater
$ echo ruby-2.3.3 > .ruby-version
$ echo "/.idea" >> .gitignore

$ git add -A
$ git commit -m "initial commit"
$ git remote add origin git@github.com:c80609a/theater.git
$ git push -u origin master

$ sudo -u postgres psql
> CREATE DATABASE theater;

> CREATE ROLE theater_user;
> ALTER USER theater_user WITH PASSWORD '12345678';
> ALTER ROLE theater_user WITH LOGIN;
> ALTER ROLE theater_user WITH CREATEDB;
> GRANT ALL ON DATABASE theater TO theater_user;

> CREATE DATABASE theater_test;
> GRANT ALL PRIVILEGES ON DATABASE theater_test TO theater_user;
> ALTER DATABASE theater_test OWNER TO theater_user;
> \q

# sudo htpasswd /etc/nginx/.htpasswd admin
```

# Endpoints

```
admin_shows GET    /admin/shows(.:format)     admin/shows#index
            POST   /admin/shows(.:format)     admin/shows#create
 admin_show DELETE /admin/shows/:id(.:format) admin/shows#destroy
      shows GET    /shows(.:format)           shows#index
```

# FLOW

See git log.

# Тесты

```
rspec

Randomized with seed 31854

ApplicationController
  rescue_from ActiveRecord::RecordInvalid
    придёт сообщение "Неверные данные!"
  rescue_from ActiveRecord::RecordNotFound
    придёт сообщение "Записи не существует"

Show
  should validate that :stop_at cannot be empty/falsy
  should validate that :title cannot be empty/falsy
  should validate that :start_at cannot be empty/falsy

Services::Shows::CreateService
  #perform:
    В базе ещё пока нет спектаклей:
      если параметры некорректны:
        атрибут @show должен быть nil
        метод вернёт false
        атрибут @errors должен быть не пуст
      если параметры корректны:
        метод вернёт true
        у сервиса станет определён атрибут @show
        атрибут @errors должен быть пуст

Shows API
  GET /shows
    в списке должны быть JSON каждого спектакля
    должен вернуть список всех спектаклей
    должен вернуть код 200
  POST /admin/shows
    если параметры валидные:
      должен вернуть JSON созданного спектакля
      должен вернуть код 201
  DELETE /admin/show/:id
    Если параметры валидные:
      вернёт статус 204
    Если параметры невалидные:
      Если нет такого спектакля:
        придёт сообщение "Записи не существует."

Validators::Shows::CreateForm
  В базе уже есть Спектакли:
    если параметры невалидные:
      если Спектакль наслаивается на несколько дней:
        причина ошибки должна быть указана строка 'period_overlap'
        атрибут errors должен содержать ошибку с ключом :time
        результат валидации должен быть false
        атрибут errors должен содержать 1 элемент
      если такой title уже есть в базе:
        результат валидации должен быть false
        атрибут errors должен содержать 1 элемент
        атрибут errors должен содержать ошибку с ключом :title
        причина ошибки должна быть указана строка 'not_uniq'
      если Спектакль соприкасается хотя бы одним днём:
        причина ошибки должна быть указана строка 'period_overlap'
        результат валидации должен быть false
        атрибут errors должен содержать ошибку с ключом :time
        атрибут errors должен содержать 1 элемент
  В базе пока еще нет Спектаклей:
    если параметры невалидные:
      если неправильный title:
        слишком длинный:
          результат валидации должен быть false
          причина ошибки должна быть строка 'too_short'
          атрибут errors должен содержать 1 элемент
          атрибут errors должен содержать ошибку с ключом :title
        слишком короткий:
          результат валидации должен быть false
          причина ошибки должна быть строка 'too_short'
          атрибут errors должен содержать 1 элемент
          атрибут errors должен содержать ошибку с ключом :title
    если параметры валидные:
      атрибут errors должен быть пуст
      результат валидации должен быть true

Finished in 1.04 seconds (files took 1.69 seconds to load)
40 examples, 0 failures
```
