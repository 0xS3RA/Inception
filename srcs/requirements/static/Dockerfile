FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

COPY site/ /var/www/static/
COPY conf/static.conf /etc/nginx/nginx.conf

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
