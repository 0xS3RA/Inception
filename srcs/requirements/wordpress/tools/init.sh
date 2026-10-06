#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

for i in $(seq 1 30); do
	if mysqladmin -h mariadb -u ${MYSQL_USER} -p${DB_PASSWORD} ping 2>/dev/null; then
		break
	fi
	sleep 1
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
	wp config create \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${DB_PASSWORD} \
		--dbhost=mariadb \
		--allow-root

	wp core install \
		--url=https://${DOMAIN_NAME} \
		--title="${WP_TITLE}" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--allow-root

	wp user create ${WP_USER} ${WP_USER_EMAIL} \
		--user_pass=${WP_USER_PASSWORD} \
		--allow-root

	if [ ! -f wp-content/object-cache.php ]; then
		wp config set WP_REDIS_HOST redis --allow-root
		wp config set WP_REDIS_PORT 6379 --allow-root
		wp plugin install redis-cache --activate --allow-root
		wp redis enable --allow-root
	fi

	chown -R www-data:www-data /var/www/html
fi

exec /usr/sbin/php-fpm8.2 -F
