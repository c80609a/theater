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

`$ rspec`
