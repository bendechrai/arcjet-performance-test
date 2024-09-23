# Next.js Performance Test

This repository contains a Next.js application and a script to test the performance of
rate limiting and bot detection configurations.

## Overview

This project aims to assess the performance implications of implementing security
measures directly in a Next.js application using Arcjet.

## Getting Started

We tested this by launching a `t4g.small` instance in AWS `us-east-1` running `Debian 12 (HVM) 64-bit (Arm)`.

### Prerequisites

- curl
- nodejs
- npm
- apache2-utils

### Creating an Arcjet Account

Head to https://app.arcjet.com/ and create an account, add a new site, and get your SDK key.

#### Debian Script

```bash
# Update and install basic dependencies
sudo apt update
sudo apt install -y curl nodejs npm apache2-utils

# Clone the repository
git clone https://github.com/bendechrai/arcjet-performance-test
cd arcjet-performance-test/nextjs-app
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