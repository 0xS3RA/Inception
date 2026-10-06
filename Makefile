# Simple Makefile for the inception project.
# It builds and runs the 3 containers with docker compose.

COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/vvan-ach/data

all: up

# Create the host folders for the volumes, then start everything
up:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/redis
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

logs:
	$(COMPOSE) logs -f

clean: down
	$(COMPOSE) down --rmi all

# Full cleanup
fclean: clean
	$(COMPOSE) down -v
	sudo rm -rf $(DATA_DIR)/mariadb/*
	sudo rm -rf $(DATA_DIR)/wordpress/*
	sudo rm -rf $(DATA_DIR)/redis/*

re: fclean up

.PHONY: all up down start stop logs clean fclean re
