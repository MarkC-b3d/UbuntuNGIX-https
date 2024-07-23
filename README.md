# Nginx and Certbot Setup Script

This script automates the setup of Nginx and Certbot on a Ubuntu server, configures Nginx for a specified domain, and obtains an SSL certificate using Certbot.

## Prerequisites

- A Ubuntu server with root or sudo privileges.
- A domain name pointed to your server's IP address.
- Basic knowledge of terminal commands.

## Usage

1. Clone this repository or download the script to your server.
2. Make the script executable:
    ```bash
    chmod +x setup_nginx_certbot.sh
    ```
3. Run the script:
    ```bash
    sudo ./setup_nginx_certbot.sh
    ```

## Script Workflow

1. **Update package list**: Ensures your package list is up-to-date.
2. **Check for Nginx**: Installs Nginx if it's not already installed.
3. **Check for Certbot**: Installs Certbot and its Nginx plugin if not already installed.
4. **Configure Firewall**: Allows Nginx through the firewall.
5. **Set up Nginx configuration**: Configures Nginx for your domain.
6. **Reload Nginx**: Applies the new Nginx configuration.
7. **Obtain SSL Certificate**: Uses Certbot to obtain an SSL certificate for your domain.
8. **Set up automatic renewal**: Ensures SSL certificates are renewed automatically.
9. **Set directory and file permissions**: Sets the correct permissions for the web root directory.
10. **Verify and reload Nginx configuration**: Ensures Nginx configuration is correct and reloads it.
11. **Check Nginx error log**: Displays the last 50 lines of the Nginx error log for troubleshooting.
12. **Verify content presence**: Ensures an `index.html` file exists in the web root, creates a sample if not.
13. **Handle SELinux/AppArmor (optional)**: Provides steps to temporarily disable SELinux and ensure AppArmor profile allows access to the web root.

## Notes

- This script assumes your web root is `/var/www/html`. Modify the `DOCUMENT_ROOT` variable in the script if your web root is different.
- SELinux and AppArmor handling is optional and should be used with caution. It's better to adjust their policies rather than disable them.
- Ensure your domain name is correctly pointed to your server's IP address before running the script.

## Troubleshooting

If you encounter any issues:

- Check the Nginx error log:
    ```bash
    sudo tail -n 50 /var/log/nginx/error.log
    ```
- Ensure your domain is correctly pointed to your server's IP address.
- Verify that the `index.html` file exists in your document root.

## License

This project is licensed under the MIT License.
