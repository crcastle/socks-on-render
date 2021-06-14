


You'll need at least two computers connected to your Tailscale network. One of them will be the application we deploy to Render. The other can be something like your local development machine.

## Setup

1. Install and configure Tailscale on your local development machine.
1. Fork this repo to a GitHub account from which you can deploy to Render.
1. Create a [new Private Service](https://dashboard.render.com/select-repo?type=pserv) on Render using the forked repo.
1. Create an Environment Variable named `TAILSCALE_AUTHKEY` for the service and set its value as a new Tailscale "Reusable Key" you generate at https://login.tailscale.com/admin/settings/authkeys (Ephemeral Keys seem like a better option here, but I couldn't get them to work--maybe because Render doesn't support IPv6).
1. Lastly, clone this repo locally.

## Connect to Render Private Service from your local development machine

1. Ensure you're authenticated and connected to Tailscale on your laptop.
1. Go to https://login.tailscale.com/admin/machines and get the *Tailscale* IP address of the Render Private Service you just deployed.
    1. Note that Tailscale seems to create three entries for my Private Service, and they take a while to all show up. I had to wait until the third one appeared and then grabbed that IP address. The other two IP addresses (maybe) worked temporarily, however the third one seems to work indefinitely.
1. Go to `http://<IP_ADDRESS>:10000` in a browser (or use `curl`). Replace `<IP_ADDRESS>` with the IP address from the previous step. You should see `Hello World!` followed by some information about the machine responding to the request.

Note that Render's load balancer is not routing this HTTP request to your Private Service. The request is going over an encrypted Wireguard network managed by Tailscale directly to your Render Private Service.

## Connect to your local development machine from Render Private Service

1. From the `socks-on-render` directory that you cloned to your local development machine run `node index.js`. We'll connect to this server from your Render Private Service.
1. Open the [Render dashboard](https://dashboard.render.com) for the Private Service you deployed and go to the Shell tab.
1. From the embedded shell run `ALL_PROXY=socks5://localhost:1055/ curl <IP_ADDRESS>`, replacing `<IP_ADDRESS>` with the Tailscale IP address for your laptop. You can get this IP address from https://login.tailscale.com/admin/machines. The `ALL_PROXY` environment variable is telling `curl` to use the proxy you specify. In this case, it a SOCKS5 proxy that the `tailscaled` process is managing.
1. You should see "Hello World!" followed by some information about the machine responding to the request.

This is being served from your local laptop over the encrypted Wireguard network managed by Tailscale.

## Why is this interesting?

- You can create an encrypted private network between any number of processes assuming they have internet access.
- The encrypted private network is what Wireguard + Tailscale is, but making Wireguard + Tailscale work as part of a Render deploy is difficult. Tailscale normally needs access to Linux's `/dev/net/tun`. That's not available in Render (and Heroku, Google Cloud Run, etc).
- The communication is encrypted but traveling over the public internet.
- That encrypted connection is point-to-point, not going through a bastion host or load balancer or similar.

## FIXME

- Why do multiple entries for a single service show up in tailscale UI?
- Why doesn't Tailscale's Magic DNS work from the Render Private Service?
