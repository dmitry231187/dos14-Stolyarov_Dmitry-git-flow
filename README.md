# dos14-Stolyarov Dmitry-git-flow
There are my homeworks

## HW14
1. Создать новый репозиторий dos14- family name-git-flow
2. Создать 2 ветки master develop
3. Cоздать ветку feature-hw-14
4. Добавит информацию о репозитории в README.md
5. Сделать pull request в develop (после апрува @ggramal смерджить) (cмерджить все ветки с предыдущими домашками в develop*)
6. Сделать из develop release-v0.0.1
7. Cмерджить в master и сделать тэг v0.0.1
8. Удалить release-v0.0.1

## HW15
1. Установить python 3.11 через pyenv
2. Создать проект с помощью poetry
3. Добавить группу зависимостей dev, сделать её опциональной и добавить black пакет
4. Создать main.py с кодом - если перменная среды SHELL равна ‘/bin/bash’ напечатать в консоль Greetings bash если другое значение Hello <значение переменной среды>
5. Сделать black ./
5. Закоммитить все файлы (pyptoject.toml, poetry.lock, main.py etc) в feature ветку, слить ее с develop(без апрува)
6. По готовности сделать пулл реквест в master с апрувером @ggramal, отписаться в тг канале

## HW16
1. База данных отдаёт 4 массива cтрок с информацией о пользователях. Все строки имеют вид - "<id>_<атрибут пользователя>". Нужно обработать эти данные и создать массив из словарей:
[
{id: "<some_id>", first_name: "<some_first_name>", last_name: "<some_last_name>", date_of_birth:<some_age>}
{id: "<some_id_2>", first_name: "<some_first_name_2>", last_name: "<some_last_name_2>", date_of_birth:<some_age_2>}
]
и вывести на экран

2. Массивы строк и информацией о пользователях:
["2_Комарова","5_Леонова","10_Фадеева","6_Соколова","4_Назаров","7_Дроздова","8_Гордеева","3_Смирнов","9_Николаев","1_Калашников"]
["2_Варвара","6_Алина","9_Владислав","4_Владислав","5_Анастасия","3_Антон","1_Марк","8_Амелия","7_Василиса","10_София"]
["2_Олеговна","1_Анатольевич","3_Эдуардович","5_Валерьевна","7_Игоревна","6_Васильевна","9_Иосифович","8_Александровна","10_Игоревна","4_Владимирович"]
['1_1985','3_1978','4_2001','10_1982','5_1970','6_1990','8_1963','7_2004','2_1996','9_1966']

## HW17
* Прочитать информацию о пользователях из файлов yaml,csv
* Из полученных данных создать список из словарей с атрибутами пользователей 
  {"id": <id>, "first_name": <first_name>, "last_name": <last_name>, "fathers_name": <fathers_name>, "date_of_birth": <data_of_birth>}
* Создать функцию для расчёта возраста пользователя
* Прогоняем наш список через функцию расчёта возраста и добавляем новый атрибут age каждому словарю
* Записываем полученные данные в users.json файл
* Создать функцию для добавления пользователей 
  * Функия должна принимать все атрибуты пользователя кроме id (first_name, last_name, fathers_name, date_of_birth) 
  * id вычисляется в функции, как наибольшее id пользователя (из списка) +1
  * age вычисляется на основании функции `расчёта возраста пользователя`
  * на основании полученных и вычесленных аттрибутов добавляем новый элемент в наш список словарей
  * записываем полученные данные в users.json файл

##HW18
* Создать класс Permissions
  * cоздать boolean свойства на чтение запись - create,read,update,delete
* Cоздать класс Role
  * создать свойство только на чтение строку name
  * cоздать свойство role которое является словарём где ключ имена наших классов
 выполняющие бизнес логику (Credit,Deposit,DebitAccount,CreditAccount,User,Organisation,Identity)
    
  ** Либо класс Role должен принемать как ключ имена выше указанных классов и выдовать 
     в качестве значений объекты Permissions
     >> a = Role("default",**dict_with_permissions)
     >> a.name
     default
     >> a["Credit].create
     False
     >> a["DebitAccount"].update
     False
* Создать класс Entity
  * Создать свойство только на чтение - entity_id (оно должно быть int)
  * Cоздать свойcтво на чтение/запись - role с типом Role.
* Создать класс User
  * Унаследоваться от Entity
  * добавить свойства только на чтение first_name, last_name, fathers_name, date_of_birth
  * добавить свойство только на чтение age, которое высчитывается из date_of_birth
* Создать класс Organisation
  * Унаследоваться от Entity
  * добавить свойства creation_date, unp, name
* Создать класс App
  * Унаследоваться от Entity
  * добавить свойства name
* Прочитать данные из файлов users.json, apps.yaml, roles.yaml и создать на основании их объекты
* В функции сreate_user из предыдущего задания создаём не словарь а объект

##HW19
* Переименовываем entity_id в client_id во всех классах
* Переименовываем class Entity в Client
* Прочитать данные из файлов users.json, apps.yaml, roles.yaml и создать на основании их объекты 
* Устанавливаем Flask через poetry
* Наш сервис должен иметь следующий http интерфейс
  * GET /api/v1/users/<client_id> - получить данные о пользователе
    * Перед тем как получить данные посмотреть есть ли у пользователя права на чтение users
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
    * Если не нашли пользователя с таким client_id то возвращаем {"status": "error", "message": f"No user with id = {client_id}"}
  * GET /api/v1/organisations/<client_id> - получить данные об организации 
    * Перед тем как получить данные посмотреть есть ли у пользователя права на чтение organisations
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
    * Если не нашли организацию с таким client_id то возвращаем {"status": "error", "message": f"No organisation with id = {client_id}"}
  * GET /api/v1/users - получить данные о всех пользователях
    * Перед тем как получить данные посмотреть есть ли у пользователя права на чтение users
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
  * GET /api/v1/organisations - получить данные о всех организациях
    * Перед тем как получить данные посмотреть есть ли у пользователя права на чтение organisations
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
  * PUT /api/v1/users - создать пользователя используя {"first_name": "...", "role": "...", "last_name": "...", "fathers_name": "...", "date_of_birth": "..."}
    * Перед тем как получить данные посмотреть есть ли у пользователя права на запись users
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
    * Пишем в файл users.json
  * PUT /api/v1/organisations - создать организацию используя {"role": "", "creation_date": "", "unp": "", "name": ""}
    * Перед тем как получить данные посмотреть есть ли у пользователя права на запись organisations
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
    * Пишем в файл users.json
  * GET /api/v1/credits/authz/{create,read,update,delete}
  * GET /api/v1/deposits/authz/{create,read,update,delete}
  * GET /api/v1/debitaccounts/authz/{create,read,update,delete}
  * GET /api/v1/creditaccounts/authz/{create,read,update,delete}
  * GET /api/v1/users/authz/{create,read,update,delete}
  * GET /api/v1/organisations/authz/{create,read,update,delete}
  * GET /api/v1/identities/authz/{create,read,update,delete}
    * Для каждого из этих URI
      * Найти заголовок token
        * Если его нет ошибка 400 {"status": "error", "message": f"Token header not found"}
      * В заголовке должен быть json {"client_id": <client_id>}
      * По id найти объект и проверить есть ли у роли такой доступ
      * Если есть 200 и {"status": "success", "message": "authorized"}
        * Если нет или, что то пошло не так то  403 {"status": "error", "message": "not authorized"}

#домашка #hw20_22
Домашка на 3 занятия. Задеплоить ваше приложение (authn/authz/bank) на Ubuntu 22.04 c помощью ansible
* установить ansible
* mkdir ansible в репозитории 
* Создать пользователя authn/authz/bank
* Установить git, 2.40.1
* Установить python 3.11
* Установить poetry
* Склонить репозиторий 
* poetry install
* poetry run flask —app main.py run (systemd service)
* start systemd service

#домашка #hw25
* Cоздать Dockerfile для нашего приложения (процесс в контейнере должен выполнятся не от root)
* Build/Push образа на dockerhub
* cоздать docker-compose файл который запускает наше приложение
* Переписать ansible role на запуск приложения через docker-compose


