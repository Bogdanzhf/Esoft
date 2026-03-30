import csv  # библиотека для работы с csv-файлами


# Функция для создания пустого csv-файла
def create_file(filename):
    # создаём файл с заголовками столбцов
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Пункт назначения", "Номер рейса", "Тип самолёта"])
    print("Файл успешно создан.")


# Функция для добавления данных о рейсе в файл
def add_record(filename):
    # ввод данных от пользователя
    destination = input("Введите пункт назначения: ")
    flight_number = input("Введите номер рейса: ")
    plane_type = input("Введите тип самолёта: ")

    # открытие файла в режиме добавления 'a'
    with open(filename, 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow([destination, flight_number, plane_type])

    print("Данные успешно записаны.")


# Функция вывода всего содержимого файла
def show_file(filename):
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            reader = csv.reader(file)
            print("\nСодержимое файла:")

            for row in reader:
                print(row)

    except FileNotFoundError:
        print("Файл не найден. Создайте файл сначала.")


# Функция поиска рейса по номеру
def search_flight(filename):
    number = input("Введите номер рейса для поиска: ")

    try:
        with open(filename, 'r', encoding='utf-8') as file:
            reader = csv.reader(file)

            # пропускаем заголовок
            next(reader)

            found = False  # флаг, найден ли рейс

            for row in reader:
                # row = [пункт назначения, номер рейса, тип самолета]
                if row[1] == number:
                    print("\nРейс найден!")
                    print("Пункт назначения:", row[0])
                    print("Номер рейса:", row[1])
                    print("Тип самолёта:", row[2])
                    found = True
                    break

            if not found:
                print("Рейс с таким номером не найден.")

    except FileNotFoundError:
        print("Файл не найден. Создайте файл сначала.")


# Главная функция с меню
def main():
    filename = "flights.csv"  # имя файла, с которым работает программа

    while True:
        print("\nМеню:")
        print("1 - Создать файл")
        print("2 - Добавить данные о рейсе")
        print("3 - Вывести данные из файла")
        print("4 - Поиск рейса по номеру")
        print("0 - Выход")

        choice = input("Ваш выбор: ")

        if choice == "1":
            create_file(filename)

        elif choice == "2":
            add_record(filename)

        elif choice == "3":
            show_file(filename)

        elif choice == "4":
            search_flight(filename)

        elif choice == "0":
            print("Программа завершена.")
            break

        else:
            print("Неверный пункт меню.")


# Запуск программы
main()
