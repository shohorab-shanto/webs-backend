#!/bin/bash
set -e
cd /var/www/html

echo "🚀 Booting Laravel on Render..."

# Prepare writable temp storage
mkdir -p /tmp/database /tmp/storage
touch /tmp/database/database.sqlite
chmod -R 775 /tmp/database /tmp/storage
chown -R www-data:www-data /tmp/database /tmp/storage

# Copy .env if missing
[ ! -f .env ] && cp .env.example .env

# Force SQLite path inside /tmp
sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=sqlite/" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=/tmp/database/database.sqlite|" .env

# Generate key
php artisan key:generate --force || true

# Link storage + cache config
php artisan storage:link || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Migrate only if allowed
if [ "${DISABLE_MIGRATIONS}" != "1" ]; then
  php artisan migrate --force || true
else
  echo "⚠️ Skipping migrations"
fi

# Adjust Apache to Render's assigned port
PORT=${PORT:-8080}
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "✅ Laravel ready at port ${PORT}"
exec apache2-foreground
