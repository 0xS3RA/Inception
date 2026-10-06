#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

service mariadb start

for i in $(seq 1 30); do
	if mysqladmin -u root ping 2>/dev/null || mysqladmin -u root -p"${DB_ROOT_PASSWORD}" ping 2>/dev/null; then
		break
	fi
	sleep 1
done

mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';" 2>/dev/null || true

mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
sleep 3

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

exec mysqld --user=mysql
