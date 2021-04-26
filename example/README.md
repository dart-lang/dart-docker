This example handles HTTP GET requests by responding with:

```
Request for "<request>" granted.
```

# Running the example

## Running with the Dart SDK (Docker not required)

If you have the [Dart SDK](https://dart.dev/get-dart) installed, you can run the
example like this:

```
$ dart run bin/server.dart

Serving at http://0.0.0.0:8080
```

And then from a second terminal:
```
$ curl http://localhost:8080/foo/bar

Request for "foo/bar" granted.
```

## Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker` command:

```
$ docker build . -t hello
$ docker run -it -p 8080:8080 hello

Serving at http://0.0.0.0:8080
```

And then from a second terminal:
```
$ curl http://localhost:8080/foo/bar

Request for "foo/bar" granted.
```
