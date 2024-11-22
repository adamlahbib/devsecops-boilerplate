DOCKER_COMPOSE = docker compose

.PHONY: run build test clean lint

build:
	@$(DOCKER_COMPOSE) build

run:
	@$(DOCKER_COMPOSE) up -d

test:
	@$(DOCKER_COMPOSE) run --rm app pytest --cov=app --cov-report=term-missing

lint:
	@echo "Running flake8 for syntax errors and undefined names..."
	@$(DOCKER_COMPOSE) run --rm app flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	@echo "Running flake8 with relaxed rules (warnings only)..."
	@$(DOCKER_COMPOSE) run --rm app flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

clean:
	@$(DOCKER_COMPOSE) down --volumes --remove-orphans
