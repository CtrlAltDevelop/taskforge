# The Flutter web bundle served by Caddy. Build from the repository root:
#   docker build -f deploy/web/Dockerfile --build-arg VERSION=$(cat VERSION) -t taskforge-web .
# The bundle is same-origin (SAME_ORIGIN=true): it reaches the API at whatever domain serves it,
# so one image works for every deployment.
# Flutter is cloned at an exact tag (the prebuilt images lag behind the SDK range in
# app/pubspec.yaml); keep FLUTTER_VERSION in step with it.
FROM debian:bookworm-slim AS build
ARG FLUTTER_VERSION=3.50.0
RUN apt-get update && apt-get install -y --no-install-recommends git curl ca-certificates unzip xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /flutter
ENV PATH=/flutter/bin:$PATH CI=true
RUN git config --global --add safe.directory /flutter && flutter config --no-analytics --enable-web \
 && flutter precache --web
WORKDIR /src/app
COPY app/pubspec.yaml app/pubspec.lock ./
RUN flutter pub get
COPY app ./
ARG VERSION=0.0.0-dev
RUN flutter build web --release \
    --dart-define=SAME_ORIGIN=true --dart-define=APP_VERSION=${VERSION}

FROM caddy:2-alpine
COPY deploy/web/Caddyfile /etc/caddy/Caddyfile
COPY --from=build /src/app/build/web /srv/web
