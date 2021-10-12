FROM debian:buster-slim

ARG DART_CHANNEL="stable"
ARG DART_VERSION="2.14.3"

ENV DART_SDK /usr/lib/dart
ENV PATH $DART_SDK/bin:$PATH

WORKDIR /root

# Create a minimal runtime environment for executing AOT-compiled Dart code
# with the smallest possible image size.
# usage: COPY --from=atsigncompany/buildimage /runtime/ /
# uses hard links here to save space

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        openssh-client \
        unzip \
        dnsutils \
        git \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    case "$(uname -m)" in \
     armv7l | armv7) ARCH="arm-linux-gnueabihf" ; \
      mkdir -p /runtime/lib/"$ARCH" ; \
      cp /lib/ld-linux-armhf.so.3 /runtime/lib/ld-linux-armhf.so.3 ; \
      cp /lib/arm-linux-gnueabihf/ld-linux-armhf.so.3 \
         /runtime/lib/arm-linux-gnueabihf/ld-linux-armhf.so.3 ;; \
     aarch64) ARCH="aarch64-linux-gnu" ; \
      mkdir -p /runtime/lib/"$ARCH" ; \
      cp /lib/ld-linux-aarch64.so.1 /runtime/lib/ld-linux-aarch64.so.1 ; \
      cp /lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 \
         /runtime/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 ;; \
     x86_64) ARCH="x86_64-linux-gnu" ; \
      mkdir -p /runtime/lib64/ ; \
      cp /lib64/ld-linux-x86-64.so.2 /runtime/lib64/ld-linux-x86-64.so.2 ;; \
     *) echo "Unsupported architecture" ; \
      exit 5;; \
    esac && \
    for f in \
        /etc/nsswitch.conf \
        /etc/ssl/certs \
        /lib/"$ARCH"/libc.so.6 \
        /lib/"$ARCH"/libdl.so.2 \
        /lib/"$ARCH"/libm.so.6 \
        /lib/"$ARCH"/libnss_dns.so.2 \
        /lib/"$ARCH"/libpthread.so.0 \
        /lib/"$ARCH"/libresolv.so.2 \
        /lib/"$ARCH"/librt.so.1 \
        /usr/share/ca-certificates \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/runtime$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/runtime$f"; \
    done; \
    SDKARCH=$(case "$(uname -m)" in x86_64) echo "x64";; armv7l) echo "arm";;\
     aarch64) echo "arm64";; esac;); \
    SDK="dartsdk-linux-$SDKARCH-release.zip"; \
    BASEURL="https://storage.googleapis.com/dart-archive/channels"; \
    URL="$BASEURL/$DART_CHANNEL/release/$DART_VERSION/sdk/$SDK"; \
    echo "SDK: $URL" >> dart_setup.log ; \
    curl -fLO "$URL"; \
    unzip "$SDK" && mv dart-sdk "$DART_SDK" && rm "$SDK";
