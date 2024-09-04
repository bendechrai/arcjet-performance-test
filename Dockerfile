# Use a lightweight Linux base image
FROM debian:latest

# Install necessary packages including Nginx, Fail2Ban, Node.js, and npm
RUN apt-get update || apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y fail2ban
RUN apt-get install -y curl
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN apt-get clean

# Set the working directory for the Next.js app
WORKDIR /app

# Copy package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install dependencies for the Next.js app
RUN npm install

# Copy the Next.js app files to the working directory
COPY . .

# Build the Next.js app
RUN npm run build

# Copy Nginx configuration files
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-rate-limit.conf /etc/nginx/conf.d/nginx-rate-limit.conf
COPY config/nginx-bot-protect.conf /etc/nginx/conf.d/nginx-bot-protect.conf
COPY config/nginx-fail2ban.conf /etc/nginx/conf.d/nginx-fail2ban.conf

# Copy Fail2Ban configuration files to the correct locations
COPY config/fail2ban-nginx-limit.conf /etc/fail2ban/filter.d/nginx-limit.conf
COPY config/fail2ban.jail.local /etc/fail2ban/jail.local

# Start Nginx, Fail2Ban, and Next.js app using a custom startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
