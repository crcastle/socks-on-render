FROM node:lts-alpine as builder
ENV NODE_ENV=production
WORKDIR /app
COPY . ./
RUN npm install --production


FROM alpine:latest as tailscale
WORKDIR /app
COPY . ./
ENV TSFILE=tailscale_1.12.1_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
    tar xzf ${TSFILE} --strip-components=1
COPY . ./


FROM alpine:latest

RUN apk update && apk add ca-certificates curl && rm -rf /var/cache/apk/*

# Copy binary to production image
COPY --from=builder . ./
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale
RUN mkdir -p /var/cache/tailscale
RUN mkdir -p /var/lib/tailscale

RUN chown root:root /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
USER root

# Run on container startup.
WORKDIR /app
CMD ["/app/start.sh"]
