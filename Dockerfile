FROM php:8.3.8-fpm

# Install common php extension dependencies
RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip

# Set the working directory
COPY ./laravel_app /var/www
WORKDIR /var/www

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory permissions
COPY --chown=www:www ./laravel_app /var/www

# Change current user to www
USER www

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# copy composer.json to workdir & install dependencies
COPY ./laravel_app/composer.json ./
RUN composer install

EXPOSE 9000
CMD ["php-fpm"]
