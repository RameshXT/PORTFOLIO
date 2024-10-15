# Ubuntu base image
FROM ubuntu:20.04

# Set non-interactive mode for apt-get to avoid prompts
ARG DEBIAN_FRONTEND=noninteractive

# Apache2
RUN apt-get update && apt-get install -y apache2

# Remove default Apache HTML files
RUN rm -rf /var/www/html/*

# Copy all files from the current directory to the Apache web root directory
COPY . /var/www/html/

# Expose port
EXPOSE 80

# Start Apache service in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
