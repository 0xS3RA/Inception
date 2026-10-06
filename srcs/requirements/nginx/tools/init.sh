#!/bin/bash

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/cert.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/cert.key \
		-out /etc/nginx/ssl/cert.crt \
		-subj "/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
