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
            "create": self._create,
            "read": self._read,
            "update": self._update,
            "delete": self._delete,
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
            "name": self._name,
            "permissions": permissions,
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
    def __init__(
        self,
        client_id: int,
        role,
        first_name,
        last_name,
        fathers_name,
        date_of_birth: int,
    ):
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
            "client_id": self._client_id,
            "first_name": self._first_name,
            "last_name": self._last_name,
            "fathers_name": self._fathers_name,
            "date_of_birth": self._date_of_birth,
            "role": self._role.to_dict,
        }


class Organisation(Client):
    def __init__(self, client_id: int, role, creation_date: int, unp: int, name):
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
            "client_id": self._client_id,
            "creation_date": self._creation_date,
            "unp": self._unp,
            "name": self._name,
            "role": self._role.to_dict,
        }


class App(Client):
    def __init__(self, client_id: int, role, name):
        super().__init__(client_id, role)
        self._name = name

    @property
    def name(self):
        return self._name


# add new user
def create_user(data):
    client_id = clients[-1].client_id + 1
    new_user = User(
        client_id,
        roles[data["role"]],
        data["first_name"],
        data["last_name"],
        data["fathers_name"],
        int(data["date_of_birth"]),
    )
    clients.append(new_user)


# add new organisation
def create_organisation(data):
    client_id = clients[-1].client_id + 1
    new_user = Organisation(
        client_id,
        roles[data["role"]],
        int(data["creation_date"]),
        int(data["unp"]),
        data["name"],
    )
    clients.append(new_user)


# write to json
def write_json():
    write_clients = {"Users": [], "Organisations": []}
    for client in clients:
        if isinstance(client, User):
            write_clients["Users"].append(client.to_dict)
        else:
            write_clients["Organisations"].append(client.to_dict)
    with open("users.json", "w") as f:
        json.dump(write_clients, f, ensure_ascii=False)


def main():
    # создаем пустые массивы
    global clients
    global roles
    clients = []
    apps = []
    roles = {}

    # получаем список roles
    with open("roles.yaml", "r") as f:
        roles_yaml = yaml.safe_load(f)
    for key in roles_yaml.keys():
        roles[key] = Role(key, roles_yaml[key])

    # получаем список apps
    with open("app.yaml", "r") as f:
        app_yaml = yaml.safe_load(f)

    for app in app_yaml["Apps"]:
        apps.append(App(app["client_id"], app["role"], app["name"]))

    # получаем список пользователей и организаций
    with open("users.json", "r") as f:
        users_json = json.load(f)

    for usr in users_json["Users"]:
        clients.append(
            User(
                usr["client_id"],
                roles[usr["role"]],
                usr["first_name"],
                usr["last_name"],
                usr["fathers_name"],
                usr["date_of_birth"],
            )
        )

    for org in users_json["Organisations"]:
        clients.append(
            Organisation(
                org["client_id"],
                roles[org["role"]],
                org["creation_date"],
                org["unp"],
                org["name"],
            )
        )

    # сортируем клиентов по client_id
    clients = sorted(clients, key=attrgetter("client_id"))

    # создаём тестового пользователя
    create_user(
        {
            "first_name": "Иван",
            "role": "authn",
            "last_name": "Иванов",
            "fathers_name": "Иванович",
            "date_of_birth": "1999",
        }
    )


# выполним основной код для создания объектов
main()


# get and return all clients (users or organisations) to json str
def all_clients(user_type):
    array = []
    for client in clients:
        if user_type == "user" and isinstance(client, User):
            array.append(client.to_dict)
        elif user_type == "organisation" and isinstance(client, Organisation):
            array.append(client.to_dict)
    return [json.dumps(array, ensure_ascii=False), "client_id"]


# check input data in methods PUT
def check_put_data(input_data, role_name):
    if role_name == "users":
        client_data = [
            "role",
            "first_name",
            "last_name",
            "fathers_name",
            "date_of_birth",
        ]
    elif role_name == "organisations":
        client_data = [
            "role",
            "creation_date",
            "unp",
            "name",
        ]
    else:
        return False
    if not isinstance(input_data, dict):
        return False
    for data in client_data:
        if data not in input_data.keys():
            return False
    return True


# получаем client_id из заголовка token, проверяем его, получаем данные по required_id
def find_id(header, required_id, role_name, data):
    if role_name == "users":
        client_type = "user"
        client_class = User
    elif role_name == "organisations":
        client_type = "organisation"
        client_class = Organisation
    if header:
        token = json.loads(header)
        # check client_id and permissions client_id
        if token.get("client_id") or token.get("client_id") == 0:
            client_id = token.get("client_id") - 1
            # на всякий случай проверим запрашиваюшего
            if client_id in range(len(clients)):
                if isinstance(clients[client_id].role[role_name], Permissions):
                    # check methods - put?
                    if required_id == "put":
                        if clients[client_id].role[role_name].create:
                            # check input data in methods PUT
                            if not check_put_data(data, role_name):
                                return [
                                    {
                                        "status": "error",
                                        "message": f"Incorrect client data entered to create {client_type}: {data}",
                                    },
                                    400,
                                ]
                            # create user or organisation and write to file
                            if role_name == "users":
                                create_user(data)
                                write_json()
                            elif role_name == "organisations":
                                create_organisation(data)
                                write_json()
                            return [{"status": "success", "message": "create"}, 200]
                        else:
                            return [
                                {
                                    "status": "error",
                                    "message": f"Access is denied for client with id = {client_id + 1}",
                                },
                                403,
                            ]
                    # check permissions for read
                    if clients[client_id].role[role_name].read:
                        # check required_id and return json clients data
                        if required_id == "all":
                            return all_clients(client_type)
                        elif required_id - 1 in range(len(clients)) and isinstance(
                            clients[required_id - 1], client_class
                        ):
                            return [
                                json.dumps(
                                    clients[required_id - 1].to_dict,
                                    ensure_ascii=False,
                                ),
                                "client_id",
                            ]
                        else:
                            return [
                                {
                                    "status": "error",
                                    "message": f"No {client_type} with id = {required_id}",
                                },
                                400,
                            ]
                    else:
                        return [
                            {
                                "status": "error",
                                "message": f"Access is denied for client with id = {client_id + 1}",
                            },
                            403,
                        ]
                else:
                    return [
                        {
                            "status": "error",
                            "message": f"Access is denied for client with id = {client_id + 1}",
                        },
                        403,
                    ]
            else:
                return [
                    {
                        "status": "error",
                        "message": f"No client with id = {client_id + 1}",
                    },
                    400,
                ]
        else:
            return [
                {"status": "error", "message": "Client_id in token header not found"},
                400,
            ]
    else:
        return [{"status": "error", "message": "Token header not found"}, 400]


# получаем данные о пользователе
@app.route("/api/v1/<client>/<int:client_id>", methods=["GET"])
def client_data(client, client_id):
    if client not in ("users", "organisations"):
        response = make_response({"status": "error", "message": f"{client} not found"})
        response.status = 400
        return response
    result = find_id(request.headers.get("token"), client_id, client, False)
    # check flag'client_id', if true - give result, else - error
    if result[1] == "client_id":
        return result[0]
    else:
        response = make_response(result[0])
        response.status = result[1]
        return response


# получаем данные о всех пользователях
@app.route("/api/v1/<client>", methods=["GET"])
def all_clients_data(client):
    if client not in ("users", "organisations"):
        response = make_response({"status": "error", "message": f"{client} not found"})
        response.status = 400
        return response
    result = find_id(request.headers.get("token"), "all", client, False)
    # check flag'client_id', if true - give result, else - error
    if result[1] == "client_id":
        return result[0]
    else:
        response = make_response(result[0])
        response.status = result[1]
        return response


# создаем нового клиента
@app.route("/api/v1/<client>", methods=["PUT"])
def new_client(client):
    if client not in ("users", "organisations"):
        response = make_response({"status": "error", "message": f"{client} not found"})
        response.status = 400
        return response
    result = find_id(request.headers.get("token"), "put", client, request.get_json())
    response = make_response(result[0])
    response.status = result[1]
    return response


# обработка для функции провреки прав
def get_permis(header, role_name, action):
    if header:
        token = json.loads(header)
        # check client_id and permissions client_id
        if token.get("client_id") or token.get("client_id") == 0:
            client_id = token.get("client_id") - 1
            # на всякий случай проверим запрашиваюшего
            if client_id in range(len(clients)):
                # check permissions
                if isinstance(clients[client_id].role[role_name], Permissions):
                    if (
                        (
                            action == "create"
                            and clients[client_id].role[role_name].create
                        )
                        or (
                            action == "read" and clients[client_id].role[role_name].read
                        )
                        or (
                            action == "update"
                            and clients[client_id].role[role_name].update
                        )
                        or (
                            action == "delete"
                            and clients[client_id].role[role_name].delete
                        )
                    ):
                        return [{"status": "success", "message": "authorized"}, 200]
                    else:
                        return [{"status": "error", "message": "not authorized"}, 403]
                else:
                    return [{"status": "error", "message": "not authorized"}, 403]
            else:
                return [
                    {
                        "status": "error",
                        "message": f"No client with id = {client_id + 1}",
                    },
                    400,
                ]
        else:
            return [
                {"status": "error", "message": "Client_id in token header not found"},
                400,
            ]
    else:
        return [{"status": "error", "message": "Token header not found"}, 400]


# проверяем права
@app.route("/api/v1/<role_name>/authz/<action>", methods=["GET"])
def check_permissions(role_name, action):
    if role_name not in (
        "credits",
        "deposits",
        "debitaccounts",
        "creditaccounts",
        "users",
        "organisations",
        "identities",
    ) or action not in ("create", "read", "update", "delete"):
        response = make_response(
            {"status": "error", "message": f"{role_name} or {action} not found"}
        )
        response.status = 400
        return response
    else:
        result = get_permis(request.headers.get("token"), role_name, action)
        response = make_response(result[0])
        response.status = result[1]
        return response
