FROM debian:bullseye-slim

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
    case "$(dpkg --print-architecture)" in \
        amd64) \
            TRIPLET="x86_64-linux-gnu" ; \
            FILES="/lib64/ld-linux-x86-64.so.2" ;; \
        armhf) \
            TRIPLET="arm-linux-gnueabihf" ; \
            FILES="/lib/ld-linux-armhf.so.3 \
                /lib/arm-linux-gnueabihf/ld-linux-armhf.so.3";; \
        arm64) \
            TRIPLET="aarch64-linux-gnu" ; \
            FILES="/lib/ld-linux-aarch64.so.1 \
                /lib/aarch64-linux-gnu/ld-linux-aarch64.so.1" ;; \
        *) \
            echo "Unsupported architecture" ; \
            exit 5;; \
    esac; \
    FILES="$FILES \
        /etc/nsswitch.conf \
        /etc/ssl/certs \
        /usr/share/ca-certificates \
        /lib/$TRIPLET/libc.so.6 \
        /lib/$TRIPLET/libdl.so.2 \
        /lib/$TRIPLET/libm.so.6 \
        /lib/$TRIPLET/libnss_dns.so.2 \
        /lib/$TRIPLET/libpthread.so.0 \
        /lib/$TRIPLET/libresolv.so.2 \
        /lib/$TRIPLET/librt.so.1"; \
    for f in $FILES; do \
        dir=$(dirname "$f"); \
        mkdir -p "/runtime$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/runtime$f"; \
    done

ENV DART_SDK /usr/lib/dart
ENV PATH $DART_SDK/bin:$PATH

WORKDIR /root
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
        amd64) \
            DART_SHA256=edca0fe2afb7cb2a5d6c1ebc65cc9cf92db50940cad452de8ff0040272fe4444; \
            SDK_ARCH="x64";; \
        armhf) \
            DART_SHA256=5a6a93f26d38037c5de99f4b6dc6d9b61d30409f6e405e1704db337a4514e8ca; \
            SDK_ARCH="arm";; \
        arm64) \
            DART_SHA256=4bb7866c4fdda23e3d9603b27b3c669376b3740b7b9eca2feb8e9ccbc1673bb8; \
            SDK_ARCH="arm64";; \
    esac; \
    SDK="dartsdk-linux-${SDK_ARCH}-release.zip"; \
    BASEURL="https://storage.googleapis.com/dart-archive/channels"; \
    URL="$BASEURL/beta/release/2.17.0-182.1.beta/sdk/$SDK"; \
    echo "SDK: $URL" >> dart_setup.log ; \
    curl -fLO "$URL"; \
    echo "$DART_SHA256 *$SDK" \
        | sha256sum --check --status --strict -; \
    unzip "$SDK" && mv dart-sdk "$DART_SDK" && rm "$SDK" && chmod 755 "$DART_SDK/bin";
