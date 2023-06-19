import yaml
from datetime import date
import json
from flask import Flask, request, make_response
from operator import attrgetter

app = Flask(__name__)

class Permissions:
    def __init__(self, create=False, read=False, update=False, delete=False):
        self._create = create
        self._read = read
        self._update = update
        self._delete = delete

    @property
    def create(self):
        return self._create

    @create.setter
    def create(self, create):
        self._create = create

    @property
    def read(self):
        return self._read

    @read.setter
    def read(self, read):
        self._read = read

    @property
    def update(self):
        return self._update

    @update.setter
    def update(self, update):
        self._update = update

    @property
    def delete(self):
        return self._delete

    @delete.setter
    def delete(self, delete):
        self._delete = delete

    @property
    def to_dict(self):
        return {
                "create" : self._create,
                "read" : self._read,
                "update" : self._update,
                "delete" : self._delete,
                }

class Role:
    def __init__(self, name, dict_with_permission):
        self._name = name
        self._role = {}
        for key, value in dict_with_permission.items():
            self._role[key] = Permissions(**value)

    @property
    def name(self):
        return self._name

    def __getitem__(self, key):
        if key in self._role.keys():
            return self._role[key]
        else:
            return False
    
    @property
    def to_dict(self):
        permissions = {}
        for key, value in self._role.items():
            permissions[key] = value.to_dict
        return {
                "name" : self._name,
                "permissions" : permissions,
                }


class Client:
    def __init__(self, client_id: int, role):
        self._client_id = client_id
        self._role = role

    @property
    def client_id(self):
        return self._client_id

    @property
    def role(self):
        return self._role

    @role.setter
    def role(self, role):
        self._role = role


class User(Client):
    def __init__(self, client_id: int, role, first_name, last_name, fathers_name, date_of_birth: int):
        super().__init__(client_id, role)
        self._first_name = first_name
        self._last_name = last_name
        self._fathers_name = fathers_name
        self._date_of_birth = date_of_birth

    @property
    def first_name(self):
        return self._first_name

    @property
    def last_name(self):
        return self._last_name

    @property
    def fathers_name(self):
        return self._fathers_name

    @property
    def date_of_birth(self):
        return self._date_of_birth

    @property
    def age(self):
        return date.today().year - self._date_of_birth

    @property
    def to_dict(self):
        return {
                "client_id" : self._client_id,
                "first_name" : self._first_name,
                "last_name" : self._last_name,
                "fathers_name" : self._fathers_name,
                "date_of_birth" : self._date_of_birth,
                "role" : self._role.to_dict,
                }


class Organisation(Client):
    def __init__(self, client_id: int, role, creation_date, unp, name):
        super().__init__(client_id, role)
        self._creation_date = creation_date
        self._unp = unp
        self._name = name

    @property
    def creation_date(self):
        return self._creation_date

    @property
    def unp(self):
        return self._unp

    @property
    def name(self):
        return self._name
    
    @property
    def to_dict(self):
        return {
                "client_id" : self._client_id,
                "creation_date" : self._creation_date,
                "unp" : self._unp,
                "name" : self._name,
                "role" : self._role.to_dict,
                }


class App(Client):
    def __init__(self, client_id: int, role, name):
        super().__init__(client_id, role)
        self._name = name

    @property
    def name(self):
        return self._name


# функция добавления пользователя
def create_user(role, first_name, last_name, fathers_name, date_of_birth):
    client_id = array_users[-1].client_id + 1
    new_user = User(
        client_id, array_roles[role], first_name, last_name, fathers_name, date_of_birth
    )
    array_users.append(new_user)

def main():
    # создаем пустые массивы
    global array_users
    global array_roles
    array_users = []
    array_apps = []
    array_roles = {}

    # получаем список roles
    with open("roles.yaml", "r") as f:
        roles_yaml = yaml.safe_load(f)
    for key in roles_yaml.keys():
        array_roles[key] = Role(key, roles_yaml[key])

    # получаем список app
    with open("app.yaml", "r") as f:
        app_yaml = yaml.safe_load(f)

    for app in app_yaml["Apps"]:
        array_apps.append(App(app["client_id"], app["role"], app["name"]))

    # получаем список пользователей и организаций
    with open("users.json", "r") as f:
        users_json = json.load(f)

    for usr in users_json["Users"]:
        array_users.append(
            User(
                usr["client_id"],
                array_roles[usr["role"]],
                usr["first_name"],
                usr["last_name"],
                usr["fathers_name"],
                usr["date_of_birth"],
            )
        )

    for org in users_json["Organisations"]:
        array_users.append(
            Organisation(
                org["client_id"],
                array_roles[org["role"]],
                org["creation_date"],
                org["unp"],
                org["name"],
            )
        )
    
    # сортируем клиентов по client_id
    array_users = sorted(array_users, key=attrgetter('client_id'))

    # создаём тестового пользователя
    create_user("authn", "Иванов", "Иван", "Иванович", 1999)

#выполним основной код для создания объектов
main()

# get all clients (users or organisations) in json
def all_clients(user_type):
    array = []
    for client in array_users:
        if user_type == "user" and isinstance(client, User):
            array.append(client.to_dict)
        elif user_type == "organisation" and isinstance(client, Organisation):
            array.append(client.to_dict)
    return [json.dumps(array, ensure_ascii=False),'client_id']

#получаем client_id из заголовка token, проверяем его, получаем данные по required_id
def find_id(header, required_id, role_name):
    if role_name == "users":
        user_type = "user"
        class_user = User
    elif role_name == "organisations":
        user_type = "organisation"
        class_user = Organisation
    if header:
        token = json.loads(header)
        #check client_id and permissions client_id
        if token.get('client_id') or token.get('client_id') == 0:
            client_id = token.get('client_id') - 1
            if client_id in range(len(array_users)): #на всякий случай проверим запрашиваюшего информацию
                if isinstance(array_users[client_id].role[role_name], Permissions):
                    if array_users[client_id].role[role_name].read:
                        #check required_id and return data
                        if required_id == "all":
                            return all_clients(user_type)
                        elif required_id == "put":
                            pass # заготовка для метода put
                            #return 
                        elif required_id - 1 in range(len(array_users)) and isinstance(array_users[required_id -1], class_user):
                            return [json.dumps(array_users[required_id - 1].to_dict, ensure_ascii=False), 'client_id']
                        else:
                            return [{"status": "error", "message": f"No {user_type} with id = {required_id}"}, 400]
                    else:
                        return [{"status": "error", "message": f"Access is denied for user with id = {client_id + 1}"}, 403]
                else:
                    return [{"status": "error", "message": f"Access is denied for user with id = {client_id + 1}"}, 403]
            else:
                return [{"status": "error", "message": f"No user with id = {client_id + 1}"}, 400]
        else:
            return [{"status": "error", "message": "Client_id in token header not found"}, 400]
    else:
        return [{"status": "error", "message": "Token header not found"}, 400]

#получаем данные о пользователе
@app.route("/api/v1/<client>/<int:client_id>", methods=["GET"])
def client_data(client, client_id):
    if client not in ("users", "organisations"):
        response = make_response({"status": "error", "message": f"{client} not found"})
        response.status = 400
        return response
    result = find_id(request.headers.get('token'), client_id, client)
    # check flag'client_id', if true - give result, else - error
    if result[1] == 'client_id':
        return result[0]
    else:
        response = make_response(result[0])
        response.status = result[1]
        return response

#получаем данные о всех пользователях
@app.route("/api/v1/<client>", methods=["GET"])
def all_clients_data(client):
    if client not in ("users", "organisations"):
        response = make_response({"status": "error", "message": f"{client} not found"})
        response.status = 400
        return response
    result = find_id(request.headers.get('token'), "all", client)
    # check flag'client_id', if true - give result, else - error
    if result[1] == 'client_id':
        return result[0]
    else:
        response = make_response(result[0])
        response.status = result[1]
        return response

#создаем нового клиента
@app.route("/api/v1/<client>", methods=["PUT"])
def new_client(client):
    if client not in ("users", "organisations"):
        response = make_response({"status": "error", "message": f"{client} not found"})
        response.status = 400
        return response
    result = find_id(request.headers.get('token'), "put", client)
    # check flag'client_id', if true - give result, else - error
    if result[1] == 'client_id':
        return result[0]
    else:
        response = make_response(result[0])
        response.status = result[1]
        return response


#обработка для функции провреки прав
def get_permis(header, role_name, action):
    if header:
        token = json.loads(header)
        #check client_id and permissions client_id
        if token.get('client_id') or token.get('client_id') == 0:
            client_id = token.get('client_id') - 1 
            if client_id in range(len(array_users)): #на всякий случай проверим запрашиваюшего информацию
                #check permissions
                if isinstance(array_users[client_id].role[role_name], Permissions):
                    if ((action == "create" and array_users[client_id].role[role_name].create) or
                            (action == "read" and array_users[client_id].role[role_name].read) or
                            (action == "update" and array_users[client_id].role[role_name].update) or
                            (action == "delete" and array_users[client_id].role[role_name].delete)):
                        return [{"status": "success", "message": "authorized"}, 200]    
                    else:
                        return [{"status": "error", "message": "not authorized"}, 403]
                else:
                    return [{"status": "error", "message": "not authorized"}, 403]
            else:
                return [{"status": "error", "message": f"No user with id = {client_id + 1}"}, 400]
        else:
            return [{"status": "error", "message": "Client_id in token header not found"}, 400]
    else:
        return [{"status": "error", "message": "Token header not found"}, 400]

#проверяем права
@app.route("/api/v1/<role_name>/authz/<action>", methods=["GET"])
def check_permissions(role_name, action):
    if role_name not in ("credits", "deposits", "debitaccounts", "creditaccounts", "users", "organisations", "identities") or action not in ("create", "read", "update", "delete"):
        response = make_response({"status": "error", "message": f"{role_name} or {action} not found"})
        response.status = 400
        return response
    else:
        result = get_permis(request.headers.get('token'), role_name, action)
        response = make_response(result[0])
        response.status = result[1]
        return response
