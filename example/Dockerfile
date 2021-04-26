# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.yaml .
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
RUN dart compile exe bin/server.dart -o /server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in `/runtime/`.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /bin/

# Start server.
EXPOSE 8080
CMD ["/bin/server"]
