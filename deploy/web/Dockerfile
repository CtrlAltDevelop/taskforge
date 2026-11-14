# The Flutter web bundle served by Caddy. Build from the repository root:
#   docker build -f deploy/web/Dockerfile --build-arg VERSION=$(cat VERSION) -t taskforge-web .
# The bundle is same-origin (SAME_ORIGIN=true): it reaches the API at whatever domain serves it,
# so one image works for every deployment.
FROM ghcr.io/cirruslabs/flutter:stable AS build
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
