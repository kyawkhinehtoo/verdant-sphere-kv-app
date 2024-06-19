# Use an official PHP image as the base image
FROM php:8.3.6-apache

# Set the working directory
WORKDIR /var/www/html

# Enable Apache mod_rewrite module and install required libraries and PHP extensions
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    libicu-dev \
    libmariadb-dev \
    default-mysql-client \
    unzip zip \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gettext intl pdo_mysql gd zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite

# Copy Composer from the official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy the application files
COPY . .

# Set file ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Switch to www-data user
USER www-data

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Expose the web server port
EXPOSE 80

