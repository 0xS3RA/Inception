#!/bin/bash

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

mkdir -p /var/run/vsftpd/empty

if ! id ${FTP_USER} 2>/dev/null; then
	useradd -m -d /var/www/html -o -u 33 -g 33 ${FTP_USER}
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
echo "${FTP_USER}" >/etc/vsftpd.userlist

exec /usr/sbin/vsftpd /etc/vsftpd.conf
