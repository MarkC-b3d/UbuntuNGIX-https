#!/bin/bash

# Exit on error
set -e

# Function to check if a command is available
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Prompt for the domain name
read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
DOCUMENT_ROOT="/var/www/html"

# Update package list
echo "Updating package list..."
sudo apt update

# Check if Nginx is installed
if command_exists nginx; then
    echo "Nginx is already installed."
else
    echo "Installing Nginx..."
    sudo apt install -y nginx
fi

# Check if Certbot is installed
if command_exists certbot; then
    echo "Certbot is already installed."
else
    echo "Installing Certbot and Nginx plugin..."
    sudo apt install -y certbot python3-certbot-nginx
fi

# Allow Nginx through the firewall
echo "Configuring firewall..."
sudo ufw allow 'Nginx Full'

# Set up Nginx configuration
echo "Setting up Nginx configuration for $DOMAIN_NAME..."
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOL
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;

    root $DOCUMENT_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx to apply changes
echo "Reloading Nginx..."
sudo systemctl reload nginx

# Obtain SSL certificate
echo "Obtaining SSL certificate with Certbot for $DOMAIN_NAME..."
sudo certbot --nginx -d $DOMAIN_NAME -d www.$DOMAIN_NAME

# Set up automatic renewal
echo "Setting up automatic SSL certificate renewal..."
sudo systemctl enable certbot.timer

# Verify Certbot renewal
echo "Verifying Certbot renewal..."
sudo certbot renew --dry-run

# Set up Nginx directory and file permissions
echo "Setting correct file permissions..."
if dir_exists "$DOCUMENT_ROOT"; then
    echo "Setting ownership and permissions for $DOCUMENT_ROOT"
    sudo chown -R www-data:www-data "$DOCUMENT_ROOT"
    sudo find "$DOCUMENT_ROOT" -type d -exec chmod 755 {} \;
    sudo find "$DOCUMENT_ROOT" -type f -exec chmod 644 {} \;
else
    echo "Directory $DOCUMENT_ROOT does not exist. Please check the document root."
    exit 1
fi

# Verify Nginx configuration
echo "Testing Nginx configuration again..."
if command_exists nginx; then
    sudo nginx -t
else
    echo "Nginx is not installed. Please install Nginx first."
    exit 1
fi

# Reload Nginx to apply changes
echo "Reloading Nginx..."
sudo systemctl reload nginx

# Check Nginx error log
echo "Checking Nginx error log for issues..."
sudo tail -n 50 /var/log/nginx/error.log

# Verify content presence
echo "Verifying content in $DOCUMENT_ROOT..."
if file_exists "$DOCUMENT_ROOT/index.html"; then
    echo "Index file found."
else
    echo "Index file not found. Ensure an index.html file is present in $DOCUMENT_ROOT."
    echo "Creating a sample index.html file..."
    echo "<!DOCTYPE html><html><body><h1>It works!</h1></body></html>" | sudo tee "$DOCUMENT_ROOT/index.html"
fi

# Optional: Handle SELinux if installed
if command_exists setenforce; then
    echo "SELinux is installed. Temporarily disabling SELinux..."
    sudo setenforce 0
    echo "If this resolves the issue, consider adjusting SELinux policies instead of keeping it disabled."
fi

# Optional: Handle AppArmor if installed
if [ -d "/etc/apparmor.d/" ]; then
    echo "AppArmor is installed. Ensure Nginx profile allows access to $DOCUMENT_ROOT."
    # Example command to disable AppArmor profile for Nginx (be cautious with this)
    # sudo aa-complain /etc/apparmor.d/usr.sbin.nginx
fi

# Final message
echo "Script execution complete. Review the outputs above to troubleshoot any issues."
echo "Your site should now be accessible via HTTPS at https://$DOMAIN_NAME and https://www.$DOMAIN_NAME."
