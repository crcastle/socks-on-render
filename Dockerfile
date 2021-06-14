FROM node:lts-alpine as builder
ENV NODE_ENV=production
WORKDIR /app
COPY . ./
RUN npm install --production


# FROM golang:1.16.2-alpine3.13 as builder
# WORKDIR /app
# COPY . ./
# This is where one could build the application code as well.


FROM alpine:latest as tailscale
WORKDIR /app
COPY . ./
ENV TSFILE=tailscale_1.8.7_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
    tar xzf ${TSFILE} --strip-components=1
COPY . ./


FROM alpine:latest

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

# Copy binary to production image
COPY --from=builder . ./
COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale
RUN mkdir -p /var/cache/tailscale
RUN mkdir -p /var/lib/tailscale

RUN addgroup -S nonroot && adduser -S nonroot -G nonroot
RUN chown nonroot:nonroot /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

USER nonroot

# Run on container startup.
WORKDIR /app
CMD ["/app/start.sh"]
