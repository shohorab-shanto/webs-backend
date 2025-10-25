FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    git \
    && docker-php-ext-install pdo_sqlite \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Set Apache DocumentRoot to Laravel public directory
ENV APACHE_DOCUMENT_ROOT=/var/www/html/backend/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Copy project files into container
COPY . /var/www/html

WORKDIR /var/www/html/backend

# Set correct permissions
RUN chmod -R 775 storage bootstrap/cache || true && \
    touch database/database.sqlite && chmod 664 database/database.sqlite || true

# Expose port 80 (Render auto-detects)
EXPOSE 80

# Start Apache (default command)
CMD ["apache2-foreground"]
