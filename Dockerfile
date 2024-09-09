# Use a lightweight Linux base image
FROM debian:latest

# Install necessary packages including Nginx, Fail2Ban, Node.js, and npm
RUN apt-get update \
 && apt-get install -y nginx fail2ban curl nodejs npm wrk \
 && apt-get clean

# Set the working directory for Nginx configurations
WORKDIR /testing-config

# Copy Nginx configuration files to /testing-config
COPY config/ .

# Set the working directory for the Next.js app
WORKDIR /app

# Copy the Next.js app files to the working directory
COPY nextjs-app/ .

# Install dependencies for the Next.js app
RUN npm install

# Build the Next.js app
RUN npm run build

# Copy the custom startup script and set permissions
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Start Nginx, Fail2Ban, and Next.js app using a custom startup script
CMD ["/start.sh"]
