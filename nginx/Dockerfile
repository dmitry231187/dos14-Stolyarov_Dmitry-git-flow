FROM nginx:1.25.1-alpine-slim
MAINTAINER leshiy74@yandex.ru
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./authz.conf /etc/nginx/conf.d/authz.conf
EXPOSE 80
#ENTRYPOINT ["nginx", "-g", "daemon off;"]
