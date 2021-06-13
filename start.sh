#!/bin/sh

/app/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
until /app/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=render-app
do
    sleep 0.1
done
echo Tailscale started
ALL_PROXY=socks5://localhost:1055/ curl -vv -g "http://[fd7a:115c:a1e0:ab12:4843:cd96:6272:8c6b]"