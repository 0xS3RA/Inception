FROM debian:bookworm

RUN apt-get update && apt-get install -y php-cli php-mysql curl ca-certificates && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer \
	&& curl -o /var/www/adminer/index.php https://www.adminer.org/static/download/4.8.4/adminer-4.8.4.php

EXPOSE 8080

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
