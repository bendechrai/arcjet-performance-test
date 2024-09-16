# Next.js Performance Test

This repository contains a Dockerized setup for testing the performance of various rate limiting and bot detection configurations using Next.js, Nginx, and Arcjet. The tests are designed to evaluate and compare the effectiveness and impact of different security measures, both locally and in cloud environments like Fly.io, where Arcjet has endpoints available.

## Overview

This project aims to assess the performance implications of implementing security measures directly in a Next.js application using Arcjet versus traditional network-level tools like Nginx. The configurations are tested locally within a Docker environment and can be extended to Fly.io for cloud-based testing.

## Features

- **Automated Setup:** A Docker environment that automatically configures and runs tests for Nginx and Arcjet.
- **Scripted Performance Testing:** Utilizes `wrk` for load testing to gather metrics on response times, throughput, and resource usage.
- **Configurable:** Easily switch between different configurations to test unprotected, Arcjet-protected, and traditional security setups.
- **Cloud-Ready:** Designed for deployment on Fly.io to test in environments where Arcjet has active endpoints.

## Configurations

The repository includes multiple configurations:

- **Nginx Baseline:** Nginx as without additional protections.
- **Arcjet Rate Limiting:** Nginx as without additional protections, calling an Arcjet protected route.
- **Arcjet Bot Protection:** Nginx as without additional protections, calling an Arcjet protected route.
- **Nginx Rate Limiting:** Nginx configured with rate limiting settings.
- **Nginx Bot Protection:** Nginx configured to block requests from known bots.

## Getting Started

### Prerequisites

- Docker installed on your local machine.
- A Fly.io account for cloud deployment.

### Cloning the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/arcjet/nextjs-performance-test.git
cd nextjs-performance-test
```

### Creating an Arcjet Account in the testing environment

Head to https://app.arcjettest.com/ and create an account, aa new site, and get your SDK key.

### Environment Setup

Copy the `nextjs-app/.env.local.example` file to `nextjs-app/.env.local` and update the necessary environment variables.

### Building the Docker Image

Build the Docker image using the provided Dockerfile:

```bash
docker build -t nextjs-performance-test .
```

### Running the Container Locally

Run the Docker container and expose the necessary ports:

```bash
docker run -d --name nextjs-performance-container -p 8080:80 \
  --env-file nextjs-app/.env.local \
  nextjs-performance-test
```

This command will start the Next.js app, and Nginx with the specified configurations and begin running the performance tests as defined in the `script.sh`.

### Deploying to Fly.io

To deploy the application on Fly.io for testing in a cloud environment:

1. **Log in to Fly.io:**

   ```bash
   flyctl auth login
   ```

2. **Create and Launch the Application:**

   As we don't have test deployments in Fly, we'll connect from the
   IAD region in Fly to the IAD region in AWS, so ensure we use a
   close Arcjet endpoint.

   ```bash
   flyctl launch --region iad 
   ```

   Follow the prompts to set up your app, selecting a region that aligns with Arcjet’s endpoint locations for optimal testing.

3. **Monitor Logs and Results:**

   Use Fly.io’s monitoring tools to view logs and performance metrics. The results will appear in the Live Logs section.
