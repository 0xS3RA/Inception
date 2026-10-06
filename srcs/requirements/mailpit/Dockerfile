FROM debian:bookworm

RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/mailpit.tar.gz https://github.com/axllent/mailpit/releases/download/v1.31.2/mailpit-linux-amd64.tar.gz \
	&& tar -xzf /tmp/mailpit.tar.gz -C /usr/local/bin mailpit \
	&& rm /tmp/mailpit.tar.gz \
	&& chmod +x /usr/local/bin/mailpit

EXPOSE 1025 8025

ENTRYPOINT ["/usr/local/bin/mailpit"]
