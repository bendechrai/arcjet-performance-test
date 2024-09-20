# Next.js Performance Test

This repository contains a Next.js application and various nginx configuration files for testing the performance of various rate limiting and bot detection configurations. The tests are designed to evaluate and compare the effectiveness and impact of different security measures.

## Overview

This project aims to assess the performance implications of implementing security measures directly in a Next.js application using Arcjet versus traditional network-level tools like Nginx.

## Configurations

The repository includes multiple configurations:

- **Nginx Baseline:** Nginx as a proxy without additional protections.
- **Arcjet Rate Limiting:** Nginx as as a proxy without additional protections, calling an Arcjet protected route.
- **Arcjet Bot Protection:** Nginx as as a proxy without additional protections, calling an Arcjet protected route.
- **Nginx Rate Limiting:** Nginx as a proxy configured with rate limiting settings.
- **Nginx Bot Protection:** Nginx as a proxy configured to block requests from known bots.

## Getting Started

In order to run this against the test environment, you will need to make sure you host close to our test services. These are located in the following locations:

- AWS `us-east-1`
- AWS `eu-west-1`
- Fly.io `iad`

We tested this by launching a `t4g.small` instance in AWS `us-east-1` running `Debian 12 (HVM) 64-bit (Arm)`.

### Prerequisites

- nginx
- caddy (with rate limiting)
- curl
- nodejs
- npm
- apache2-utils
- go (for building Caddy)

#### Debian install

```bash
# Update and install basic dependencies
sudo apt update
sudo apt install -y nginx curl nodejs npm apache2-utils wget

# Install a more recent version of Go (1.21)
wget https://go.dev/dl/go1.21.3.linux-arm64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.3.linux-arm64.tar.gz
rm go1.21.3.linux-arm64.tar.gz

# Add Go to PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Install xcaddy (Caddy builder)
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# Build Caddy with rate limiting module
~/go/bin/xcaddy build --with github.com/mholt/caddy-ratelimit

# Move the built Caddy to /usr/bin and set permissions
sudo mv caddy /usr/bin/
sudo chown root:root /usr/bin/caddy
sudo chmod 755 /usr/bin/caddy

# Set up Caddy as a service
sudo groupadd --system caddy
sudo useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy

# Create Caddy service file
cat << EOF | sudo tee /etc/systemd/system/caddy.service
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

# Create Caddy config directory
sudo mkdir -p /etc/caddy

# Create a basic Caddyfile
echo ":80" | sudo tee /etc/caddy/Caddyfile

# Reload systemd, enable and start Caddy
sudo systemctl daemon-reload
sudo systemctl enable caddy
sudo systemctl start caddy
```

### Creating an Arcjet Account in the testing environment

Head to https://app.arcjettest.com/ and create an account, add a new site, and get your SDK key.

### Clone and install

```sh
git clone https://github.com/bendechrai/arcjet-performance-test
cd arcjet-performance-test/nextjs-app
npm install
```

### Environment Setup

Copy the `.env.local.example` file to `.env.local` and update the necessary environment variables.

### Start the Application

```sh
npm run build
npm start
```

### Performance Testing

In another terminal, run:

```sh
cd arcjet-performance-test/
./test.sh
```

### Analyzing Results

Save the output of these tests to a file (e.g., `results.txt`) and analyze the results using the provided analysis script.

```sh
./parse_results.sh results.txt
```
