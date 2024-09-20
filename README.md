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

* AWS `us-east-1`
* AWS `eu-west-1`
* Fly.io `iad`

We tested this by launching a `t4g.small` instance in AWS `us-east-1` running `Debian 12 (HVM) 64-bit (Arm)`.

### Prerequisites

* nginx
* caddy
* curl
* nodejs
* npm
* apache2-utils

#### Debian install

```sh
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install nginx caddy curl nodejs npm apache2-utils
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

Copy the output and paste it into ChatGTP with the following prompt:

> The following is the output of a number of `ab` tests to determine response times of different security configurations. Analyze the data, and return a CSV matrix with "Requests per second" and "Response time (ms)" across the top, and a row for each test down the side. Return this as plain text.


