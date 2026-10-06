FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 21 21100

ENTRYPOINT ["/init.sh"]
