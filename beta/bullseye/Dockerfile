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
            DART_SHA256=dc3123d87c1b6b43087520ba9fa7e6fd91f3c4652178d55ca41825f4fc7100fe; \
            SDK_ARCH="x64";; \
        armhf) \
            DART_SHA256=3b825fa4c6bdd7809185d9acbe4e7030900ea0edd14c17aa6255d7665910e9a1; \
            SDK_ARCH="arm";; \
        arm64) \
            DART_SHA256=f6c0f0777241fb8b2d0607295f794956b9a91d3251f639c32fd351902dfae931; \
            SDK_ARCH="arm64";; \
    esac; \
    SDK="dartsdk-linux-${SDK_ARCH}-release.zip"; \
    BASEURL="https://storage.googleapis.com/dart-archive/channels"; \
    URL="$BASEURL/beta/release/2.17.0-266.5.beta/sdk/$SDK"; \
    echo "SDK: $URL" >> dart_setup.log ; \
    curl -fLO "$URL"; \
    echo "$DART_SHA256 *$SDK" \
        | sha256sum --check --status --strict -; \
    unzip "$SDK" && mv dart-sdk "$DART_SDK" && rm "$SDK" \
        && chmod 755 "$DART_SDK" && chmod 755 "$DART_SDK/bin";
