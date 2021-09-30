FROM debian:buster-slim

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dnsutils \
        git \
        openssh-client \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*

# Create a minimal runtime environment for executing AOT-compiled Dart code
# with the smallest possible image size.
# usage: COPY --from=dart:xxx /runtime/ /
# uses hard links here to save space
RUN set -eux; \
    for f in \
        /etc/nsswitch.conf \
        /etc/ssl/certs \
        /lib/x86_64-linux-gnu/libc.so.6 \
        /lib/x86_64-linux-gnu/libdl.so.2 \
        /lib/x86_64-linux-gnu/libm.so.6 \
        /lib/x86_64-linux-gnu/libnss_dns.so.2 \
        /lib/x86_64-linux-gnu/libpthread.so.0 \
        /lib/x86_64-linux-gnu/libresolv.so.2 \
        /lib/x86_64-linux-gnu/librt.so.1 \
        /lib64/ld-linux-x86-64.so.2 \
        /usr/share/ca-certificates \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/runtime$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/runtime$f"; \
    done

ENV DART_SDK /usr/lib/dart
ENV PATH $DART_SDK/bin:$PATH

WORKDIR /root
RUN set -eux; \
    ARCH=$(case "$(dpkg --print-architecture)" in amd64) echo "x64";; esac;); \
    SDK="dartsdk-linux-$ARCH-release.zip"; \
    BASEURL="https://storage.googleapis.com/dart-archive/channels"; \
    URL="$BASEURL/stable/release/2.14.3/sdk/$SDK"; \
    echo "SDK: $URL" >> dart_setup.log ; \
    curl -fLO "$URL"; \
    echo "cad36ec238af96c8048bbcec4cff7e69fcb1b895620010ca1762674ca4ade171 *$SDK" \
    | sha256sum --check --status --strict -; \
    unzip "$SDK" && mv dart-sdk "$DART_SDK" && rm "$SDK";
