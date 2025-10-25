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

# Run migrations (SQLite safe)
php artisan migrate --force || true

# Cache configs
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "✅ Laravel ready. Starting Apache..."
exec apache2-foreground
