#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
repeat_request.py

Скрипт выполняет POST запрос к серверу для создания нотификации к мобильному приложению.
Параметры:
    1. Количество запросов (по умолчанию – 1)
        python script_name.py 5

    2. Путь до файла сертификата (PEM). Если не указан, будет использован
       verify=False и выдаст предупреждение о небезопасном соединении.
        python script_name.py 5 /some_path/to/ssl.pem

При работе с самоподписанным сертификатом hostname‑проверка отключается,
чтобы избежать ошибки «hostname … doesn't match».
"""

import sys
import time
import json
import ssl
from urllib3.util.ssl_ import create_urllib3_context
import requests
from requests.adapters import HTTPAdapter

# Replace with the ones you need
URL = "https://server_ip:port/.../triggers"
HEADERS = {
    "Accept-Language": "en_US",
    "Authorization": (
        "Bearer ......"
    ),
    "Content-Type": "application/json",
}
PAYLOAD = {
    "triggerId": "{triggerId}",
    "deviceId": "{deviceId}",
    "state": "instant",
}

# ---------- Create session ----------
def create_session(cert_path: str | None = None) -> requests.Session:
    """
    Возвращает готовую `requests.Session`, в которой:

      * если указан cert_path – подключается к серверу через TLS,
        используя указанный сертификат и отключая проверку имени хоста.
      * иначе - используется verify=False (небезопасно, но без предупреждения).
    """
    session = requests.Session()

    if cert_path:
        # Создаём SSL‑контекст: используем ваш сертификат как trusted CA,
        # но выключаем проверку hostname
        ctx = ssl.create_default_context(cafile=cert_path)
        ctx.check_hostname = False   # отключаем проверку имени хоста

        adapter = HTTPAdapter(ssl_context=ctx)
        session.mount("https://", adapter)

    else:
        # Без сертификата – просто отключаем проверку (будет предупреждение)
        session.verify = False

    return session


# ---------- Main logic ----------
def send_one(session: requests.Session, count: int) -> None:
    """Отправляем один запрос и выводим статус."""
    print(f"\nЗапрос #{count}")
    try:
        resp = session.post(URL, json=PAYLOAD, headers=HEADERS, timeout=10)
        print(f"Статус: {resp.status_code} – {resp.reason}")
        # Если нужен ответ в виде текста/JSON, раскомментировать ниже
        # print(resp.text)
    except requests.exceptions.RequestException as exc:
        print(f"Ошибка при выполнении запроса: {exc}")


def main() -> None:
    if len(sys.argv) < 2:
        print("Использование: python repeat_request.py [кол-во_запросов] [путь_к_cert.pem]")
        sys.exit(1)

    try:
        count = int(sys.argv[1])
        if count <= 0:
            raise ValueError
    except ValueError:
        print("Первый аргумент должен быть положительным целым числом – количество запросов.")
        sys.exit(1)

    cert_path = sys.argv[2] if len(sys.argv) > 2 else None

    session = create_session(cert_path)

    for i in range(1, count + 1):
        send_one(session, i)
        # Пауза между запросами (по желанию можно убрать)
        if i != count:
            time.sleep(0.5)


if __name__ == "__main__":
    main()