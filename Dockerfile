# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY org-roam-server/pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY org-roam-server/. .
RUN dart compile exe bin/server.dart -o bin/server


FROM node:14 AS ui
WORKDIR /app 
COPY org-roam-ui/package.json /app 
COPY org-roam-ui/yarn.lock /app
RUN yarn 
COPY org-roam-ui/. /app 
RUN yarn build && yarn export

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM debian:11-slim
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=ui /app/out /public

RUN apt-get update
RUN apt-get install libsqlite3-dev -y

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
