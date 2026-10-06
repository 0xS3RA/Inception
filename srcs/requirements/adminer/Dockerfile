FROM debian:bookworm

RUN apt-get update && apt-get install -y php-cli php-mysql curl ca-certificates && rm -rf /var/lib/apt/lists/*

# Download adminer 5.3.0 (fixed version, single file).
# -fSL: fail the build if the download fails, follow redirects.
RUN mkdir -p /var/www/adminer \
	&& curl -fSL -o /var/www/adminer/index.php https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php

EXPOSE 8080

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
