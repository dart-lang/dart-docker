FROM debian:trixie-slim

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
        riscv64) \
            TRIPLET="riscv64-linux-gnu" ; \
            FILES="/lib/ld-linux-riscv64-lp64d.so.1 \
                /lib/riscv64-linux-gnu/ld-linux-riscv64-lp64d.so.1" ;; \
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
ENV PATH $DART_SDK/bin:/root/.pub-cache/bin:$PATH

WORKDIR /root
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
        amd64) \
            DART_SHA256=75bf2badc56cd6aff829042a0112ca5f3cf50bcf7fd95c29bc76650579dc00e1; \
            SDK_ARCH="x64";; \
        armhf) \
            DART_SHA256=c2bc9f74f3d77ff5e2d66b10eb9acb81e1978ef7ec88772a8a0231d0dbc526ac; \
            SDK_ARCH="arm";; \
        arm64) \
            DART_SHA256=e9a028b0be5325e2cbf5118ab6c6c407d302fb220ae5dc7d9d6f5648676fb724; \
            SDK_ARCH="arm64";; \
        riscv64) \
            DART_SHA256=81df475711bf672ef4d04bcbef3cc563b6e9224ba0742f73cd538ff649361d74; \
            SDK_ARCH="riscv64";; \
    esac; \
    SDK="dartsdk-linux-${SDK_ARCH}-release.zip"; \
    BASEURL="https://storage.googleapis.com/dart-archive/channels"; \
    URL="$BASEURL/stable/release/3.9.0/sdk/$SDK"; \
    echo "SDK: $URL" >> dart_setup.log ; \
    curl -fLO "$URL"; \
    echo "$DART_SHA256 *$SDK" \
        | sha256sum --check --status --strict -; \
    unzip "$SDK" && mv dart-sdk "$DART_SDK" && rm "$SDK" \
        && chmod 755 "$DART_SDK" && chmod 755 "$DART_SDK/bin";
