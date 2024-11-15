DOCKER_COMPOSE = docker compose

.PHONY: run build test clean

build:
	@$(DOCKER_COMPOSE) build

run:
	@$(DOCKER_COMPOSE) up -d

test:
	@$(DOCKER_COMPOSE) run --rm app pytest --cov=app --cov-report=term-missing

clean:
	@$(DOCKER_COMPOSE) down --volumes --remove-orphans
