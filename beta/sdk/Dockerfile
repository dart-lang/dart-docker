FROM debian:buster-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		openssh-client \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	apt-get update; \
	savedAptMark="$(apt-mark showmanual)"; \
# temporary key-fetching dependencies
	apt-get install -y --no-install-recommends \
		dirmngr \
		gnupg \
		wget \
	; \
	\
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
	wget -qO- 'https://dl.google.com/linux/linux_signing_key.pub' | gpg --batch --import; \
	mkdir -p /usr/local/share/keyrings; \
# full fingerprint so that GnuPG validates it too
	gpg --batch --export EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796 > /usr/local/share/keyrings/google.gpg; \
	rm -rf "$GNUPGHOME"; \
	\
# purge temporary dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
# TODO looks like the repo only contains "amd64", despite https://dart.dev/get-dart#linux 😇
	dpkgArch="$(dpkg --print-architecture)"; \
	echo "deb [ arch=$dpkgArch signed-by=/usr/local/share/keyrings/google.gpg ] https://storage.googleapis.com/download.dartlang.org/linux/debian testing main" > /etc/apt/sources.list.d/dart.list; \
	\
# smoke test
	apt-get update; \
	rm -rf /var/lib/apt/lists/*

ENV DART_SDK /usr/lib/dart
ENV PATH $DART_SDK/bin:$PATH

ENV DART_VERSION 2.13.0-211.6.beta-1

RUN set -eux; \
	apt-get update; \
	apt-get install -y dart="$DART_VERSION"; \
	rm -rf /var/lib/apt/lists/*

# create a minimal "scratch" environment for creating hyper-minimal images
# usage: COPY --from=dart:xxx /scratch-runtime/ /
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
		mkdir -p "/scratch-runtime$dir"; \
		cp --archive --link --dereference --no-target-directory "$f" "/scratch-runtime$f"; \
	done
