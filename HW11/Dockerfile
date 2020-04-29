FROM alpine:3.11
RUN apk add nginx && apk add apk-tools && apk update && apk upgrade
COPY nginx/index.html /usr/share/nginx/html/index.html
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
