*This project has been created as part of the 42 curriculum by vvan-ach.*

## Description

Inception is a small system administration project. The goal is to set up
a simple web infrastructure with Docker Compose:

- NGINX (TLS only, port 443) as the main entry point.
- WordPress + php-fpm (port 9000, no nginx inside).
- MariaDB (port 3306, database only).
- Bonus: redis object cache, FTP server, static showcase site,
  Adminer and Mailpit (fake SMTP mailbox for WordPress emails).

Each service runs in its own container, built from our own Dockerfile
based on Debian bookworm. Data is kept in two named volumes stored
under `/home/vvan-ach/data`.

## Instructions

Requirements: Docker, Docker Compose plugin, make, sudo.

1. Add the domain to your hosts file (points to your local IP):

   ```
   127.0.0.1 vvan-ach.42.fr
   ```

2. Create the secrets files (they are ignored by git, so recreate them
   after cloning):

   - `secrets/db_password.txt`
   - `secrets/db_root_password.txt`
   - `secrets/wp_admin_password.txt`
   - `secrets/wp_user_password.txt`
   - `secrets/ftp_password.txt`

   Each file contains one password on one line, nothing else.

3. Check `srcs/.env` and change values if needed (login, domain, users).

4. Start everything:

   ```
   make
   ```

   Then open `https://vvan-ach.42.fr` in your browser
   (self-signed certificate, you need to accept the warning).

   Bonus services (the subject allows extra ports for the bonus):
   static site on port 8080, Adminer on port 8081,
   Mailpit web UI on port 8025 and FTP on port 21.

5. Stop or clean:

   ```
   make stop
   make down
   make clean
   make fclean
   ```

More details in `USER_DOC.md` (how to use) and `DEV_DOC.md` (how it works).

## Project description

Sources included:

- `srcs/docker-compose.yml`: defines the 3 services, volumes, network, secrets.
- `srcs/requirements/nginx/`: Dockerfile + `nginx.conf` + `init.sh`.
  Installs nginx and openssl, creates a self-signed cert, runs nginx.
- `srcs/requirements/wordpress/`: Dockerfile + `www.conf` + `init.sh`.
  Installs php-fpm and wordpress 6.8.2, uses wp-cli to create
  `wp-config.php` and the two users on first start.
- `srcs/requirements/mariadb/`: Dockerfile + `50-server.cnf` + `init.sh`.
  Installs mariadb-server, creates database and user on first start.
- `srcs/requirements/redis/`: Dockerfile + `redis.conf`.
  Cache for WordPress (wired with the redis-cache plugin).
- `srcs/requirements/ftp/`: Dockerfile + `vsftpd.conf` + `init.sh`.
  FTP access to the WordPress files.
- `srcs/requirements/static/`: Dockerfile + nginx conf + handmade
  HTML/CSS showcase site (no PHP).
- `srcs/requirements/adminer/`: Dockerfile, single-file database admin
  served by the PHP built-in server.
- `srcs/requirements/mailpit/`: Dockerfile, fake SMTP server with a web
  UI that catches every email WordPress sends. My extra service of
  choice: without a real mailbox, WordPress account emails (password
  reset, new users) are lost. Mailpit keeps them visible, with zero
  setup. Most students pick portainer or monitoring tools; a mailbox
  is more useful for a WordPress stack.
- `srcs/.env`: non-secret variables (domain, database name, users).
- `secrets/`: passwords only, ignored by git.

Main design choices:

- Base image `debian:bookworm` everywhere (penultimate stable Debian,
  simple apt packages, easy to understand).
- No `latest` tag, fixed versions only.
- No password in Dockerfiles or `.env`, passwords only in docker secrets
  (`/run/secrets/...` inside containers).
- NGINX is the entry point of the mandatory part (port 443).
  WordPress and MariaDB only talk inside the `inception` network.
  The bonus services open extra ports (allowed by the subject):
  8080 static, 8081 adminer, 8025 mailpit, 21 ftp.
- Each container ends with `exec ...` so the service is PID 1
  (no `tail -f`, no `while true`, no infinite loop).
- Volumes are named volumes with `driver_opts` pointing to
  `/home/vvan-ach/data/...` so data persists on the host
  (mariadb, wordpress files, plus a redis volume for the bonus).

### Virtual Machines vs Docker

A virtual machine runs a full guest OS with its own kernel on top
of a hypervisor. It is heavy (gigabytes, slow boot) but fully isolated.

Docker shares the host kernel and only isolates processes with
namespaces and cgroups. Images are small layers, containers start
in seconds. For this project Docker is enough: we just need 3
services talking to each other, not 3 full operating systems.

### Secrets vs Environment Variables

Environment variables are simple (`KEY=value` in `.env`), visible
with `docker inspect` and in logs. Good for non-sensitive config
(domain name, user names).

Secrets are files mounted under `/run/secrets/` only inside the
containers that need them. They do not appear in images or git
history (if gitignored). Good for passwords. This project uses both:
`.env` for normal settings, secrets for the 5 passwords.

### Docker Network vs Host Network

Host network means the container shares the host network stack
(no isolation, port conflicts). Forbidden in this subject.

A docker bridge network (`inception` here) gives each container
its own IP and DNS name (`mariadb`, `wordpress`, `nginx`).
Only nginx publishes a port to the outside. The database is
not reachable from outside, only from wordpress. Simple and safe.

### Docker Volumes vs Bind Mounts

A bind mount is `-v /host/path:/container/path`: direct link,
depends on host path, harder to manage.

A named volume is `- volume_name:/container/path`: managed by
Docker, portable in `docker-compose.yml`. Here we use named volumes
(`mariadb_data`, `wordpress_data`) with `driver_opts` so Docker
still stores the files under `/home/vvan-ach/data`. We get both:
clean compose file (no bind syntax) plus known host location
(required by the subject).

## Resources

- Docker docs: https://docs.docker.com/
- Docker Compose docs: https://docs.docker.com/compose/
- NGINX docs: https://nginx.org/en/docs/
- WordPress + wp-cli: https://wordpress.org/documentation/ and https://wp-cli.org/
- MariaDB docs: https://mariadb.com/kb/en/documentation/

AI usage: I used AI to get simple examples of Dockerfiles, nginx
fastcgi config, php-fpm pool config and wp-cli commands, and to
check the wording of this README. I then rewrote everything by hand
to keep it simple, tested each container, and made sure I understand
every line before submitting.
