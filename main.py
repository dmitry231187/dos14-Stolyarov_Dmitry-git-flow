import yaml
import csv
from datetime import date
import json


# ф-ция проверки на наличие нужного id, если не находим - добавляем словари до нужного id
def find_id(id_user):
    no_id = True
    for user in array_users:
        if user["id"] == id_user:
            no_id = False
    if no_id:
        for i in range(id_user - len(array_users)):
            next_id = len(array_users) + 1
            array_users.append(
                {
                    "id": next_id,
                    "first_name": None,
                    "last_name": None,
                    "fathers_name": None,
                    "date_of_birth": None,
                }
            )


# ф-ция записи данных пользователя в наш список пользователей
def write_user_data(user):
    for element in user.keys():
        if element == "date_of_birth":
            array_users[int(user["id"]) - 1][element] = int(user[element])
        elif element != "id":
            array_users[int(user["id"]) - 1][element] = user[element]


# ф-ция расчета возраста пользователя
def age_user(user):
    return date.today().year - user["date_of_birth"]


# ф-ция добавления пользователя
def add_user(first_name, last_name, fathers_name, date_of_birth):
    id_new_user = array_users[-1]["id"] + 1
    array_users.append(
        {
            "id": id_new_user,
            "first_name": first_name,
            "last_name": last_name,
            "fathers_name": fathers_name,
            "date_of_birth": date_of_birth,
        }
    )
    array_users[-1]["age"] = age_user(array_users[-1])


# ф-ция записи в json
def write_json():
    with open("users.json", "w") as f:
        json.dump(array_users, f, ensure_ascii=False)


# создаем пустой массив для списка пользователей с их данными
array_users = [
    {
        "id": 1,
        "first_name": None,
        "last_name": None,
        "fathers_name": None,
        "date_of_birth": None,
    }
]

# получаем данные из yaml файла
with open("users.yaml", "r") as f:
    users_yaml = yaml.safe_load(f)

# обрабатываем массив и записываем данные в список пользователей
for user in users_yaml["users"]:
    find_id(int(user["id"]))
    write_user_data(user)

# получаем данные из csv файла
with open("users.csv", "r") as f:
    users_csv = csv.DictReader(f)
    # обрабатываем массив и записываем данные в список пользователей
    for user in users_csv:
        find_id(int(user["id"]))
        write_user_data(user)

# добавляем каждому пользователю его возраст
for element in array_users:
    element["age"] = age_user(element)

# сохраним данные в файл json
write_json()

# добавляем нового пользователя и записываем в json
add_user("test_name", "test_last_name", "test_fathers_name", 2000)
write_json()

# for row in array_users:
#    print(row)
