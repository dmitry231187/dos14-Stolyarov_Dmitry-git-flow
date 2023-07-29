FROM nginx:1.25.1-alpine-slim
MAINTAINER leshiy74@yandex.ru
COPY ./nginx.conf /etc/nginx
COPY ./authz.conf /etc/nginx/conf.d
VOLUME ./logs /var/log/nginx/
EXPOSE 80
