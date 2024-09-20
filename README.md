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

- curl
- nodejs
- npm
- apache2-utils

### Creating an Arcjet Account in the testing environment

Head to https://app.arcjettest.com/ and create an account, add a new site, and get your SDK key.

#### Debian Script

```bash
# Update and install basic dependencies
sudo apt update
sudo apt install -y curl nodejs npm apache2-utils

# Clone the repository
git clone https://github.com/bendechrai/arcjet-performance-test
cd arcjet-performance-test
npm install

# Create a .env.local file and prompt for an ARCJET_KEY to inject
cp .env.local.example .env.local
echo -n "Paste your ARCJET_KEY here: "
sed -i.bak "s/ajkey_.*/$(head -n 1)/g" .env.local && rm .env.local.bak

# Run the Next.js application
npm run build
npm start
```

### Performance Testing

In another terminal, run:

```sh
cd arcjet-performance-test/
./test.sh | tee results.txt
```

### Analyzing Results

Save the output of these tests to a file (e.g., `results.txt`) and analyze the results using the provided analysis script.

```sh
./parse_results.sh < results.txt
```