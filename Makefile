build:
	docker compose build

buildf:
	docker compose build --no-cache

up:
	docker compose up -d

down:
	docker compose down

ps:
	docker compose ps

ssh:
	docker compose exec nix bash -l
