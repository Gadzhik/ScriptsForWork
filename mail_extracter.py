import os
import re


def find_emails_in_directory():
    path_to_directory = input("Введите путь к каталогу для обхода: ")
    output_file = input("Введите имя файла для записи результатов: ")

    all_emails = []

    # Рекурсивный обход каталога
    for root, _, files in os.walk(path_to_directory):
        for file in files:
            if file.lower().endswith('.txt'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        text = f.read()
                        emails = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', text)
                        all_emails.extend(emails)
                except Exception as e:
                    print(f"Ошибка при обработке файла {file_path}: {e}")

    # Сохранение результатов
    with open(output_file, 'w') as out_file:
        for email in all_emails:
            out_file.write(email + '\n')

    print(f"Все электронные адреса сохранены в файл {output_file}")


if __name__ == "__main__":
    find_emails_in_directory()
