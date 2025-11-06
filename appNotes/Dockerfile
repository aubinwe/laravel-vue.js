FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git curl libpng-dev zip unzip default-mysql-client netcat-openbsd \
    && docker-php-ext-install pdo pdo_mysql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .
RUN composer install --no-dev --no-scripts --no-autoloader
RUN composer dump-autoload --optimize
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]