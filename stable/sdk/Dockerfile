FROM debian:buster-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		openssh-client \
		unzip \
	; \
	rm -rf /var/lib/apt/lists/*

COPY install_dart.sh /usr/local/bin
RUN /usr/local/bin/install_dart.sh 2.12.4 stable linux x64 /usr/lib/dart

ENV DART_SDK /usr/lib/dart
ENV PATH $DART_SDK/bin:$PATH
ENV DART_VERSION {{DART_VERSION}}

# create a minimal "scratch" environment for creating hyper-minimal images
# usage: COPY --from=dart:xxx /scratch-runtime/ /
# use hard links here to save on space
RUN set -eux; \
	for f in \
		/lib/x86_64-linux-gnu/libc.so.6 \
		/lib/x86_64-linux-gnu/libdl.so.2 \
		/lib/x86_64-linux-gnu/libm.so.6 \
		/lib/x86_64-linux-gnu/libnss_dns.so.2 \
		/lib/x86_64-linux-gnu/libpthread.so.0 \
		/lib/x86_64-linux-gnu/libresolv.so.2 \
		/lib/x86_64-linux-gnu/librt.so.1 \
		/lib64/ld-linux-x86-64.so.2 \
	; do \
		dir="$(dirname "$f")"; \
		mkdir -p "/scratch-runtime$dir"; \
		cp --archive --link --dereference --no-target-directory "$f" "/scratch-runtime$f"; \
	done
# don't hard link due cross-device link errors for a couple of the files
RUN set -eux; \
	for f in \
	    /etc/hosts \
		/etc/nsswitch.conf \
		/etc/resolv.conf \
		/etc/ssl/certs \
		/usr/share/ca-certificates \
	; do \
		dir="$(dirname "$f")"; \
		mkdir -p "/scratch-runtime$dir"; \
		cp --archive --dereference --no-target-directory "$f" "/scratch-runtime$f"; \
	done
