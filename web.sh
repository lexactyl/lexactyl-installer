#!/bin/bash

# Configuration file path
config_file="panel/config.toml"

# Check if config.toml exists and read the port from it
if [[ -f "$config_file" ]]; then
    # Extract the port value (assuming format like "port = 3000")
    port=$(grep -oP 'port\s*=\s*\K[0-9]+' "$config_file")
    if [[ -z "$port" ]]; then
        echo "Port not found in config.toml. Please ensure it's correctly set."
        exit 1
    fi
    echo "Detected port from config.toml: $port"
else
    echo "Configuration file not found. Please ensure $config_file exists."
    exit 1
fi

# Ask if they want to run on localhost or domain
read -p "Do you want to run Lexactyl on (1) localhost or (2) a custom domain? Enter 1 or 2: " choice

if [[ "$choice" == "1" ]]; then
    # Run Lexactyl on localhost
    echo "Starting Lexactyl on localhost at port $port..."
    node panel/app.js
elif [[ "$choice" == "2" ]]; then
    # Ask for the domain
    read -p "Enter the domain you want to use for Lexactyl (e.g., example.com): " domain

    # Set up Nginx configuration
    nginx_config="/etc/nginx/sites-available/$domain"
    sudo tee "$nginx_config" > /dev/null <<EOF
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    # Enable Nginx site and reload configuration
    sudo ln -s "$nginx_config" /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx

    echo "Nginx configured for $domain. You can now access Lexactyl at http://$domain."

    # Start Lexactyl
    node panel/app.js
else
    echo "Invalid choice. Please enter 1 or 2."
    exit 1
fi
