# dart-docker

This is the Git repo of the [Docker "Official Images"] for the
[Dart programming language].

See the [Docker Hub page] for a full description on how to use these Docker
images as well as for information regarding contributing and issues.

The [Docker Hub page] is generated/maintained over in the
[docker-library/docs repository], specifically in [the `dart` directory].

## Using this image

We recommend creating small runtime images by leveraging Dart's support for
ahead-of-time (AOT) [compilation to executables]. This enables creating small
runtime images (~10 MB).

The following `Dockerfile` performs two steps:

1. Using the Dart SDK in the `dart:stable` image, compiles your server
(`bin/server.dart`) to an executable (`server`).

1. Assembles the runtime image by combining the compiled server with the Dart VM
runtime and it's needed dependencies located in `/runtime/`.

```
# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* .
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
```

If you have [Docker Desktop] installed, you can build and run with the
`docker` command:

```
$ docker build . -t dart-server
$ docker run -it -p 8080:8080 dart-server
```

Maintained with ❤️ by the [Dart] team.


<!-- Reference links -->

[Dart]:
https://dart.dev

[dart programming language]:
https://dart.dev

[Docker Desktop]:
(https://www.docker.com/get-started)

[docker hub page]:
https://hub.docker.com/_/dart/

[docker-library/docs repository]:
https://github.com/docker-library/docs

[docker "official images"]:
https://github.com/docker-library/official-images#what-are-official-images

[the `dart` directory]:
https://github.com/docker-library/docs/tree/master/dart

[compilation to executables]:
https://dart.dev/tools/dart-compile#exe
