SHELL := /bin/bash
.PHONY: setup dev down run serve grpc migrate purge tick web proto proto-lint check test

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

# Zero-infra dev: no Docker. Env vars beat backend/.env, so SQLite + in-memory
# challenge store/broker are used even if .env points at Postgres/Redis.
# The Redis broker (from `make dev`) is what carries live-sync events from the gRPC
# process, where changes are made, to the REST/WebSocket process, where sockets are held:
# a per-process MemoryBroker would deliver nothing. Run `make dev` first.
REDIS_BROKER := DJANGO_NOTIFICATIONS_BROKER=apps.notifications.broadcast.RedisBroker
LITE_ENV := DJANGO_SETTINGS_MODULE=config.settings.development \
	DJANGO_DB_ENGINE=django.db.backends.sqlite3 DJANGO_DB_NAME=db.sqlite3 \
	DJANGO_AUTH_CHALLENGE_STORE=infrastructure.auth.core.challenges.LocMemChallengeStore \
	$(REDIS_BROKER)

# Migrate, then REST (:8010) and gRPC (:50051) together; Ctrl-C stops both.
# gRPC-Web from Flutter web still needs Envoy (`make dev`); native clients don't.
run:
	cd backend && $(LITE_ENV) ../$(VENV)/python manage.py migrate
	cd backend && $(LITE_ENV) ../$(VENV)/python manage.py reindex
	cd backend && trap 'kill 0' INT TERM EXIT; \
	$(LITE_ENV) ../$(VENV)/python -m uvicorn config.asgi:application --reload --app-dir src --port 8010 & \
	$(LITE_ENV) ../$(VENV)/python manage.py grpcrunaioserver & \
	wait

serve:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development $(REDIS_BROKER) ../$(VENV)/python -m uvicorn config.asgi:application --reload --app-dir src --port 8010

web:
	cd app && flutter run -d chrome --web-port 5173

# Apply pending migrations to the dev database (run after pulling or finishing a phase).
migrate:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python manage.py migrate
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python manage.py reindex

# The two clean-ups no scheduler runs yet (there is no Celery): expired uploads, old change-log
# entries. Put it in cron or a scheduled job, daily.
purge:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python manage.py purge_uploads
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development ../$(VENV)/python manage.py trim_changelog

# The notifications' clock (no Celery yet): snoozes ending, tasks due soon, pushes and emails held for
# quiet hours or digests, retries; the burndown snapshots of active sprints (back-filling missed
# days); the due-date automations and the pruning of their run history. Run it every minute from cron.
tick:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development $(REDIS_BROKER) ../$(VENV)/python manage.py inbox_tick
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development $(REDIS_BROKER) ../$(VENV)/python manage.py sprint_snapshots
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development $(REDIS_BROKER) ../$(VENV)/python manage.py automations_tick

grpc:
	cd backend && DJANGO_SETTINGS_MODULE=config.settings.development $(REDIS_BROKER) ../$(VENV)/python manage.py grpcrunaioserver

# Regenerate Python stubs (backend) and Dart stubs (app) from the .proto files.
# Add each new .proto to DART_PROTOS as phases introduce them.
DART_PROTOS := infrastructure/common/grpc/common.proto \
	infrastructure/accounts/grpc/accounts.proto \
	infrastructure/workspaces/grpc/workspaces.proto \
	infrastructure/projects/grpc/projects.proto \
	infrastructure/tasks/grpc/tasks.proto \
	infrastructure/workflows/grpc/workflows.proto \
	infrastructure/customfields/grpc/customfields.proto \
	infrastructure/savedviews/grpc/savedviews.proto \
	infrastructure/filters/grpc/filters.proto \
	infrastructure/sync/grpc/sync.proto \
	infrastructure/comments/grpc/comments.proto \
	infrastructure/attachments/grpc/attachments.proto \
	infrastructure/inbox/grpc/inbox.proto \
	infrastructure/search/grpc/search.proto \
	infrastructure/timetracking/grpc/timetracking.proto \
	infrastructure/docs/grpc/wikidocs.proto \
	infrastructure/automations/grpc/automations.proto \
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
