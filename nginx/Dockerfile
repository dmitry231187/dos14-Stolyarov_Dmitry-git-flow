FROM nginx:1.25.1-alpine-slim
MAINTAINER leshiy74@yandex.ru
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
