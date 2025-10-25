# ----------------------------
# 🐘 Laravel PHP 8.2 + Apache
# ----------------------------
FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_sqlite \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Set Apache DocumentRoot to Laravel's public directory
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Copy project files into container
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# ✅ Install Composer from the official image (faster + stable)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Install PHP dependencies for Laravel
RUN composer install --no-dev --optimize-autoloader \
    && chown -R www-data:www-data /var/www/html/vendor

# Ensure writable directories and SQLite file exist
RUN mkdir -p database \
    && touch database/database.sqlite \
    && chown -R www-data:www-data storage bootstrap/cache database vendor \
    && chmod -R 775 storage bootstrap/cache \
    && chmod 664 database/database.sqlite

# Copy and enable custom startup script
COPY docker-start.sh /usr/local/bin/docker-start.sh
RUN chmod +x /usr/local/bin/docker-start.sh

# Expose Apache HTTP port
EXPOSE 80

# Run startup script (artisan setup + Apache)
CMD ["docker-start.sh"]
