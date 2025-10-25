FROM php:8.2-apache

# Install system dependencies and PHP extensions needed by Laravel
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    git \
    && docker-php-ext-install pdo_sqlite \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Set Apache DocumentRoot to Laravel's public directory located under backend
ENV APACHE_DOCUMENT_ROOT=/var/www/html/backend/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

WORKDIR /var/www/html

# No need to copy source; we will mount the project via bind volume in compose
# Expose handled by base image (port 80)