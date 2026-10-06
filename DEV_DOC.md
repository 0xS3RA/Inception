# DEV_DOC - how to build and change the project

## Setup from scratch

Prerequisites: Debian/Ubuntu VM, docker engine, docker compose plugin,
make, sudo.

1. Clone the repo.
2. Create host data folders (done automatically by `make`):
   `/home/vvan-ach/data/mariadb` and `/home/vvan-ach/data/wordpress`.
3. Create config files:
   - Copy and edit `srcs/.env` (domain, users, database name).
   - Create the 5 files in `secrets/` (one password per file).
4. Add `127.0.0.1 vvan-ach.42.fr` to `/etc/hosts`.

All paths and names in this repo already use the login `vvan-ach`.
If you fork this for another login, replace `vvan-ach` with your login in:
`srcs/.env` (DOMAIN_NAME, LOGIN), `srcs/docker-compose.yml`
(volume devices `/home/.../data`), `Makefile` (DATA_DIR),
and `srcs/requirements/nginx/conf/nginx.conf` (server_name).

## Build and launch with Makefile and Compose

- `make` = `mkdir -p data dirs` + `docker compose -f srcs/docker-compose.yml up -d --build`
- `make down` = `docker compose ... down`
- `make clean` = `down --rmi all` (also removes built images)
- `make fclean` = clean + `down -v` + empty host data folders

The compose file loads `srcs/.env` automatically (same folder).
Secrets are read from `../secrets/*.txt` (repo root `secrets/` folder).

Useful raw commands (same as Makefile does):

```
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml config
```

## Manage containers and volumes

- List containers: `docker ps`
- Enter a container: `docker exec -it nginx bash`
- Inspect volumes: `docker volume ls`
- Inspect network: `docker network inspect srcs_inception`

## Where data is stored and how it persists

Two named volumes in `docker-compose.yml` for the mandatory part,
plus one for the redis bonus:

- `mariadb_data` -> `/var/lib/mysql` in mariadb container
- `wordpress_data` -> `/var/www/html` in wordpress container
  (shared read-only in nginx for static files,
  shared read-write in ftp for file access)
- `redis_data` -> `/data` in redis container (bonus cache)

Both use:

```
driver_opts:
  type: none
  o: bind
  device: /home/vvan-ach/data/...
```

So Docker manages them as named volumes, but files really live in
`/home/vvan-ach/data/mariadb` and `/home/vvan-ach/data/wordpress`
on the host. They survive `make down` and rebuilds.
Only `make fclean` deletes them.

## How each image works

- nginx: `debian:bookworm` + nginx + openssl. `init.sh` creates
  a self-signed cert for `$DOMAIN_NAME` if missing,
  then `exec nginx -g "daemon off;"`.
- mariadb: `debian:bookworm` + mariadb-server. `init.sh` starts
  a temp server, runs `CREATE DATABASE`, `CREATE USER`, `GRANT`,
  sets root password from secrets, stops temp server,
  then `exec mysqld`.
- wordpress: `debian:bookworm` + php-fpm 8.2 + wordpress 6.8.2 + wp-cli.
  `init.sh` waits max 30s for mariadb, creates `wp-config.php`
  and users with wp-cli only on first run, then enables the
  redis-cache plugin (bonus), then `exec php-fpm8.2 -F`.
  Outgoing emails go through msmtp to the mailpit container.
- redis: `debian:bookworm` + redis-server, config listens on 6379,
  data in `/data`. No published port, wordpress only.
- ftp: `debian:bookworm` + vsftpd. `init.sh` creates the `ftpuser`
  account from secrets, locked in `/var/www/html` (wordpress volume).
- static: `debian:bookworm` + nginx serving handmade HTML/CSS
  on port 8080. No script, nginx runs directly.
- adminer: `debian:bookworm` + php-cli, single adminer 5.3.0 file
  served by `php -S` on port 8080 (published as 8081).
- mailpit: `debian:bookworm` + mailpit 1.31.2 single binary.
  Fake SMTP on 1025, web UI on 8025. No config file needed.
