This is the [Docker "Official Image"] for the [Dart programming language].

# Quick reference

* **Where to get help**:  
	[the Docker Community Forums](https://forums.docker.com/),
    [the Docker Community Slack](https://dockr.ly/slack), or
    [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

## Using this image

We recommend creating small runtime images by leveraging Dart's support for
ahead-of-time (AOT) [compilation to executables]. This enables creating small
runtime images (~10 MB).

The following `Dockerfile` performs two steps:

1. Using the Dart SDK in the `dart:stable` image, compiles your server
   (`bin/server.dart`) to an executable (`server`).

1. Assembles the runtime image by combining the compiled server with the Dart VM
   runtime and it's needed dependencies located in `/runtime/`.

```Dockerfile
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* .
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
RUN dart compile exe bin/server.dart -o /server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /bin/

# Start server.
EXPOSE 8080
CMD ["/bin/server"]
```

If you have [Docker Desktop] installed, you can build and run on your machine
with the `docker` command:

```shell
$ docker build -t dart-server .
$ docker run -it --rm -p 8080:8080 --name myserver dart-server
```

When finished, you can stop the container using the name you provided:

```shell
$ docker kill myserver
```


Maintained with ❤️ by the [Dart] team.

<!-- Reference links -->

[dart]:
https://dart.dev

[docker "official image"]:
https://github.com/docker-library/official-images#what-are-official-images

[docker desktop]:
https://www.docker.com/get-started

[compilation to executables]:
https://dart.dev/tools/dart-compile#exe
