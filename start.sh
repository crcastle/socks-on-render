#!/bin/sh

/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
until /app/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=render-app
do
    sleep 0.1
done
echo Tailscale started
NODE_ENV=production node index.js
