# USER_DOC - how to use the project

## What services are provided

- Website: `https://vvan-ach.42.fr` (WordPress, served by NGINX on port 443).
- Admin panel: `https://vvan-ach.42.fr/wp-admin`.
- Database: MariaDB, only reachable from inside the containers (no public port).
- Bonus services:
  - Static showcase site: `http://vvan-ach.42.fr:8080` (plain HTML/CSS).
  - Adminer (database admin): `http://vvan-ach.42.fr:8081`
    (server `mariadb`, user `wpuser`, password in
    `secrets/db_password.txt`, database `wordpress`).
  - Mailpit (mailbox): `http://vvan-ach.42.fr:8025`, catches every
    email WordPress sends (try a password reset on the login page).
  - FTP: host `vvan-ach.42.fr`, port 21, user `ftpuser`, password in
    `secrets/ftp_password.txt`. You land in the WordPress files.

Users in the database:

- Admin user: `superman` (email `superman@vvan-ach.42.fr`).
- Normal user: `batman` (email `batman@vvan-ach.42.fr`).
- The admin name does not contain "admin", as required by the subject.

## Start and stop

From the root of the repo:

- Start everything (creates `/home/vvan-ach/data`, builds, runs):
  `make` or `make up`
- Stop without removing: `make stop`
- Start again: `make start`
- Remove containers: `make down`
- Remove containers + images: `make clean`
- Full reset (containers + images + volumes + data): `make fclean`
- Full rebuild: `make re`
- Follow logs: `make logs`

## Access the website

1. Make sure `vvan-ach.42.fr` points to your machine:
   add `127.0.0.1 vvan-ach.42.fr` to `/etc/hosts`.
2. Run `make`.
3. Open `https://vvan-ach.42.fr` in a browser.
   The certificate is self-signed, so accept the security warning.
4. Admin login: `https://vvan-ach.42.fr/wp-admin`
   with user `superman` and the password in `secrets/wp_admin_password.txt`.

## Credentials

- Non-secret settings: `srcs/.env` (domain, database name, user names).
- Passwords (one per file, one line):
  - `secrets/db_password.txt` (mysql user `wpuser`)
  - `secrets/db_root_password.txt` (mysql root)
  - `secrets/wp_admin_password.txt` (wordpress admin `superman`)
  - `secrets/wp_user_password.txt` (wordpress user `batman`)
  - `secrets/ftp_password.txt` (ftp user `ftpuser`)
- These `secrets/` files are ignored by git, never commit them.

## Check that services run correctly

```
docker ps
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
```

You should see 8 containers:
`nginx`, `wordpress`, `mariadb`, `redis`, `ftp`,
`static`, `adminer`, `mailpit`, all "Up".

Test manually:

- `curl -k https://vvan-ach.42.fr` should return HTML (option `-k`
  ignores the self-signed certificate).
- `https://vvan-ach.42.fr/wp-admin` should show the login page.
- Files persist in `/home/vvan-ach/data/mariadb` and
  `/home/vvan-ach/data/wordpress` even after `make down`.
  Redis cache persists in `/home/vvan-ach/data/redis`.
