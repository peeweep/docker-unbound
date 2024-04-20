FROM alpine:edge AS builder
WORKDIR /unbound-build
RUN apk update && apk add build-base flex openssl-dev expat-dev byacc libevent-dev
RUN wget https://github.com/NLnetLabs/unbound/archive/refs/tags/release-1.19.3.tar.gz -O - | tar -xz && \
	cd unbound-release-1.19.3 || exit && \
	export CFLAGS="-O3" && \
	./configure \
	    --enable-subnet \
	    --enable-cachedb \
	    --with-libevent \
	    --with-username=root \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-pidfile=/tmp/unbound.pid && \
	pwd && \
	make && \
	strip unbound && \
	strip unbound-checkconf

FROM alpine:edge
WORKDIR /etc/unbound
COPY --from=builder /unbound-build/unbound-release-1.19.3/unbound /usr/sbin/unbound
COPY --from=builder /unbound-build/unbound-release-1.19.3/unbound-checkconf /usr/sbin/unbound-checkconf
RUN apk add --no-cache libevent-dev
CMD /usr/sbin/unbound
