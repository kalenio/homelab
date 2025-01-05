# Latest version tags available at https://hub.docker.com/_/caddy
FROM caddy:2.8.4-builder-alpine AS builder

RUN xcaddy build \
	--with github.com/caddy-dns/cloudflare

FROM caddy:2.8.4

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
