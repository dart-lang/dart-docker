FROM debian:buster-slim

ENV DART_VERSION   2.12.4
ENV CHANNEL        stable
ENV PLATFORM       linux
ENV ARCH           x64

ENV DART_SDK /usr/lib/dart

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		openssh-client \
		unzip \
		dnsutils \
	; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN set -eux; \
    SDK="dartsdk-$PLATFORM-$ARCH-release.zip"; \
    BASEURL="https://storage.googleapis.com/dart-archive/channels"; \
    URL="$BASEURL/$CHANNEL/release/$DART_VERSION/sdk/$SDK"; \
    echo "SDK: $URL" >> dart_setup.log ; \
    curl -fLO "$URL" && curl -fLO "$URL".sha256sum; \
    sha256sum --status -c "$SDK".sha256sum; \
    unzip "$SDK" && mv dart-sdk "$DART_SDK" && rm "$SDK";

ENV PATH $DART_SDK/bin:$PATH

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
