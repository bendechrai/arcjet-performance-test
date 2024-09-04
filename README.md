# Next.js Performance Test

This repository contains a Dockerized setup for testing the performance of various rate limiting and bot detection configurations using Next.js, Nginx, Fail2Ban, and Arcjet. The tests are designed to evaluate and compare the effectiveness and impact of different security measures, both locally and in cloud environments like Fly.io, where Arcjet has endpoints available.

## Overview

This project aims to assess the performance implications of implementing security measures directly in a Next.js application using Arcjet versus traditional network-level tools like Nginx and Fail2Ban. The configurations are tested locally within a Docker environment and can be extended to Fly.io for cloud-based testing.

## Features

- **Automated Setup:** A Docker environment that automatically configures and runs tests for Nginx, Fail2Ban, and Arcjet.
- **Scripted Performance Testing:** Utilizes `wrk` for load testing to gather metrics on response times, throughput, and resource usage.
- **Configurable:** Easily switch between different configurations to test unprotected, Arcjet-protected, and traditional security setups.
- **Cloud-Ready:** Designed for deployment on Fly.io to test in environments where Arcjet has active endpoints.

## Configurations

The repository includes multiple configurations:

- **Nginx Baseline:** Nginx as a reverse proxy without additional protections.
- **Nginx Rate Limiting:** Nginx configured with rate limiting settings.
- **Nginx Bot Protection:** Nginx configured to block requests from known bots.
- **Fail2Ban:** Integrated with Nginx to monitor logs and ban IPs based on defined patterns.
- **Arcjet Rate Limiting and Bot Detection:** In-app protections directly integrated into the Next.js application.

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

### Building the Docker Image

Build the Docker image using the provided Dockerfile:

```bash
docker build -t nextjs-performance-test .
```

### Running the Container Locally

Run the Docker container and expose the necessary ports:

```bash
docker run -d --name nextjs-performance-container -p 8080:80 nextjs-performance-test
```

This command will start the Next.js app, Nginx, and Fail2Ban with the specified configurations and begin running the performance tests as defined in the `script.sh`.

### Deploying to Fly.io

To deploy the application on Fly.io for testing in a cloud environment:

1. **Log in to Fly.io:**

   ```bash
   flyctl auth login
   ```

2. **Create and Launch the Application:**

   ```bash
   flyctl launch
   ```

   Follow the prompts to set up your app, selecting a region that aligns with Arcjet’s endpoint locations for optimal testing.

3. **Deploy the Application:**

   ```bash
   flyctl deploy
   ```

4. **Monitor Logs and Results:**

   Use Fly.io’s monitoring tools to view logs and performance metrics. The results will be similar to the local tests, allowing you to compare performance between local and cloud environments.

## Understanding the Results

The test outputs will include key performance metrics such as:

- **Response Times:** How quickly the server responds under load.
- **Throughput:** The number of requests handled per second.
- **Resource Usage:** CPU and memory utilization during the tests.
- **Error Rates:** Incidences of failed requests or timeouts.

These metrics will help you evaluate the impact of different security configurations on your Next.js application.