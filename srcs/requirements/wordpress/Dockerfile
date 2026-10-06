FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	php-curl \
	php-gd \
	php-mbstring \
	php-xml \
	php-zip \
	php-redis \
	curl \
	mariadb-client \
	msmtp \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/html \
	&& curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-6.8.2.tar.gz \
	&& tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 \
	&& rm /tmp/wordpress.tar.gz \
	&& chown -R www-data:www-data /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY conf/mail.ini /etc/php/8.2/fpm/conf.d/mail.ini
COPY conf/msmtprc /etc/msmtprc
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 9000

ENTRYPOINT ["/init.sh"]
