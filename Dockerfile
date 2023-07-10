FROM python:3.11-buster
MAINTAINER leshiy74@yandex.ru
RUN pip install poetry && useradd -d /home/authz -U -m -u 1111 authz
USER authz
COPY app.yaml main.py poetry.lock pyproject.toml roles.yaml users.json /home/authz/app/
WORKDIR /home/authz/app
RUN poetry install
EXPOSE 5000
ENTRYPOINT poetry run python main.py
