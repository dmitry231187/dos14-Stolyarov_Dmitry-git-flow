# исходные данные
array_first_name = [
    "2_Комарова",
    "5_Леонова",
    "10_Фадеева",
    "6_Соколова",
    "4_Назаров",
    "7_Дроздова",
    "8_Гордеева",
    "3_Смирнов",
    "9_Николаев",
    "1_Калашников",
]
array_last_name = [
    "2_Варвара",
    "6_Алина",
    "9_Владислав",
    "4_Владислав",
    "5_Анастасия",
    "3_Антон",
    "1_Марк",
    "8_Амелия",
    "7_Василиса",
    "10_София",
]
array_patronymic = [
    "2_Олеговна",
    "1_Анатольевич",
    "3_Эдуардович",
    "5_Валерьевна",
    "7_Игоревна",
    "6_Васильевна",
    "9_Иосифович",
    "8_Александровна",
    "10_Игоревна",
    "4_Владимирович",
]
array_date_of_birth = [
    "1_1985",
    "3_1978",
    "4_2001",
    "10_1982",
    "5_1970",
    "6_1990",
    "8_1963",
    "7_2004",
    "2_1996",
    "9_1966",
]

# определяем количество людей и создаем массив нужной длины
array_users = []
for i in range(len(array_first_name)):
    array_users.append(
        {
            "id": None,
            "first_name": None,
            "last_name": None,
            "patronymic": None,
            "date_of_birth": None,
        }
    )

# обрабатываем массивы и записываем данные в нужные места
for element in array_first_name:
    array_temp = element.split("_")
    array_users[int(array_temp[0]) - 1]["first_name"] = array_temp[1]
    array_users[int(array_temp[0]) - 1]["id"] = int(array_temp[0])
for element in array_last_name:
    array_temp = element.split("_")
    array_users[int(array_temp[0]) - 1]["last_name"] = array_temp[1]
for element in array_patronymic:
    array_temp = element.split("_")
    array_users[int(array_temp[0]) - 1]["patronymic"] = array_temp[1]
for element in array_date_of_birth:
    array_temp = element.split("_")
    array_users[int(array_temp[0]) - 1]["date_of_birth"] = array_temp[1]
# печатаем итоговый массив в столбик
for element in array_users:
    print(element)
