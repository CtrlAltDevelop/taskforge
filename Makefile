SHELL := /bin/bash
.PHONY: setup dev down serve grpc migrate web proto proto-lint check test

PATH := $(PATH):$(HOME)/.pub-cache/bin
VENV := backend/.venv/bin

# One-time setup on a clean clone: backend venv + deps + .env, Flutter packages.
# Contract tooling (protoc, buf) is installed separately; see AGENTS.md.
setup:
	python3 -m venv backend/.venv
	$(VENV)/pip install -e 'backend[dev]'
	cp -n backend/.env.example backend/.env || true
	cd app && flutter pub get

# Infra containers (Postgres, Redis, Envoy). Then run `make serve` and `make grpc`
# in two terminals, and `cd app && flutter run -d chrome`.
dev:
	docker compose -f deploy/docker-compose.yml up -d

down:
	docker compose -f deploy/docker-compose.yml down

serve:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python -m uvicorn config.asgi:application --reload --app-dir src --port 8010

web:
	cd app && flutter run -d chrome --web-port 5173

# Apply pending migrations to the dev database (run after pulling or finishing a phase).
migrate:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python manage.py migrate

grpc:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python manage.py grpcrunaioserver

# Regenerate Python stubs (backend) and Dart stubs (app) from the .proto files.
# Add each new .proto to DART_PROTOS as phases introduce them.
DART_PROTOS := infrastructure/common/grpc/common.proto \
	infrastructure/accounts/grpc/accounts.proto \
	infrastructure/workspaces/grpc/workspaces.proto \
	infrastructure/projects/grpc/projects.proto \
	infrastructure/tasks/grpc/tasks.proto \
	infrastructure/workflows/grpc/workflows.proto \
	infrastructure/customfields/grpc/customfields.proto \
	infrastructure/oauth/rotation/grpc/oauth_rotation.proto
proto:
	cd backend && ../$(VENV)/python manage.py protos
	rm -rf app/lib/gen && mkdir -p app/lib/gen
	protoc -I backend/src --dart_out=grpc:app/lib/gen $(DART_PROTOS)
	rm -rf app/lib/gen/google

proto-lint:
	buf lint

check:
	PATH="$(CURDIR)/$(VENV):$$PATH" $(MAKE) -C backend check
	cd app && dart format --output=none --set-exit-if-changed lib test
	cd app && flutter analyze --fatal-infos

test:
	cd backend && ../$(VENV)/python -m pytest --cov
	cd app && flutter test --coverage
