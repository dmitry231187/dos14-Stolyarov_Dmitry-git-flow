import yaml
from datetime import date
import json


class Permissions:
    def __init__(self, create=False, read=False, update=False, delete=False):
        self._create = create
        self._read = read
        self._update = update
        self._delete = delete

    @property
    def create(self):
        return self._create

    @property
    def set_create(self, create=False):
        self._create = create

    @property
    def read(self):
        return self._read

    @property
    def set_read(self, read=False):
        self._read = read

    @property
    def update(self):
        return self._update

    @property
    def set_update(self, update=False):
        self._update = update

    @property
    def delete(self):
        return self._delete

    @property
    def set_delete(self, delete=False):
        self._delete = delete


class Role:
    def __init__(self, name, dict_with_permission):
        self._name = name
        self._role = {}
        for key, value in dict_with_permission.items():
            self._role[key] = Permissions(**value)

    @property
    def name(self):
        return self._name

    def __getitem__(self,key):
        return self._role[key]


class Entity:
    def __init__(self, entity_id:int, role):
        self._entity_id = entity_id
        self._role = role

    @property
    def entity_id(self):
        return self._entity_id

    @property
    def role(self):
        return self._role

    @property
    def set_role(self, role):
        self._role = role


class User(Entity):
    def __init__(self, entity_id:int, role, first_name, last_name, fathers_name, date_of_birth):
        super().__init__(entity_id, role)
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


class Organisation(Entity):
    def __init__(self, entity_id:int, role, creation_date, unp, name):
        super().__init__(entity_id, role)
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

class App(Entity):
    def __init__(self, entity_id:int, role, name):
        super().__init__(entity_id, role)
        self._name = name

    @property
    def name(self):
        return self._name

# функция добавления пользователя
def create_user(role, first_name, last_name, fathers_name, date_of_birth):
    entity_id = array_users[-1].entity_id + 1
    new_user = User(entity_id, role, first_name, last_name, fathers_name, date_of_birth)
    array_users.append(new_user)


def main():
    # создаем пустые массивы 
    global array_users
    array_users = []
    array_apps = []
    array_roles = [] 
    
    # получаем список пользователей и организаций
    with open("users.json", "r") as f:
        users_json = json.load(f)
        
    for usr in users_json["Users"]:
        array_users.append(User(usr['entity_id'], usr['role'], usr['first_name'], usr['last_name'], usr['fathers_name'], usr['date_of_birth']))
    
    for org in users_json["Organisations"]:
        array_users.append(Organisation(org['entity_id'], org['role'], org['creation_date'], org['unp'], org['name']))

    # получаем список app
    with open("app.yaml", "r") as f:
        app_yaml = yaml.safe_load(f)
    
    for app in app_yaml["Apps"]:
        array_apps.append(App(app['entity_id'], app['role'], app['name']))
    
    # получаем список roles
    with open("roles.yaml", "r") as f:
        roles_yaml = yaml.safe_load(f)
    for key in roles_yaml.keys():
        array_roles.append(Role(key, roles_yaml[key]))

main()

