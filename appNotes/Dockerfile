# backend/Dockerfile
FROM php:8.2-fpm-alpine

# Installation des dépendances système
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    mysql-client \
    netcat-openbsd

# Installation des extensions PHP
RUN docker-php-ext-install pdo pdo_mysql gd xml

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copier les fichiers de dépendances
COPY composer*.json ./

# Installer les dépendances PHP
RUN composer install --no-dev --no-scripts --no-autoloader

# Copier le code source
COPY . .

# Finaliser l'installation
RUN composer dump-autoload --optimize && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8000

# Script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]