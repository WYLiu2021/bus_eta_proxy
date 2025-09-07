Cloudflare Tunnel setup (quick)

1. Install cloudflared on your NAS or use the provided Docker container.

2. Authenticate and create a tunnel (on a machine with browser access):

   cloudflared tunnel login
   cloudflared tunnel create hkbus-proxy

   This will produce a credentials JSON file. Copy that JSON to `cloudflared/hkbus-proxy.json` in this repo.

3. Create a DNS record (CNAME) for `subdomain.yourdomain.com` pointing to the tunnel created.
   Or run:

   cloudflared tunnel route dns hkbus-proxy subdomain.yourdomain.com

4. Start via Docker Compose on your NAS:

   docker compose -f docker-compose.cloudflared.yml up -d --build

5. The tunnel will forward requests to the backend service at backend:8000 inside the compose network.

Notes:
- Replace `subdomain.yourdomain.com` with your desired hostname.
- Keep the credentials JSON secret.
- For automatic startup, use systemd or Docker restart policies.
