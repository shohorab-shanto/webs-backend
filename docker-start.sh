#!/bin/bash
set -e

cd /var/www/html

echo "🚀 Running Laravel setup..."

# Ensure writable permissions for Laravel
chown -R www-data:www-data storage bootstrap/cache database
chmod -R 775 storage bootstrap/cache
chmod 664 database/database.sqlite

# Ensure SQLite database exists
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite
chown www-data:www-data database/database.sqlite

# Generate .env if missing
if [ ! -f /var/www/html/.env ]; then
  cp .env.example .env
fi

# Force DB connection to SQLite
sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=sqlite/" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=/var/www/html/database/database.sqlite|" .env

# Generate app key if missing
if ! grep -q "APP_KEY=base64" .env; then
  php artisan key:generate
fi

# Prepare session table and run migrations (SQLite safe)
php artisan session:table || true
php artisan migrate --force || true

# Cache configs
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Adjust Apache to Render's assigned PORT
PORT=${PORT:-80}
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "✅ Laravel ready. Starting Apache..."
exec apache2-foreground
