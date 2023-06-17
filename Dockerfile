ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-alpine

RUN apk --update add --no-cache --virtual .build-deps autoconf \
        g++ libtool make curl-dev gettext-dev linux-headers libzip-dev libzip zip \
        re2c freetype freetype-dev libpng \
        libpng-dev libjpeg-turbo libjpeg-turbo-dev libwebp-dev

RUN pecl install redis && \
    docker-php-ext-install pdo_mysql mysqli opcache bcmath zip && \
    docker-php-ext-enable redis

RUN docker-php-ext-configure gd --with-webp --with-freetype --with-jpeg; \
    NPROC=$(getconf _NPROCESSORS_ONLN); \
    docker-php-ext-install "-j${NPROC}" gd;

RUN apk del .build-deps \
    && docker-php-source delete

# Install composer and change it's cache home
RUN curl -o /usr/bin/composer https://getcomposer.org/download/2.5.8/composer.phar \
    && chmod +x /usr/bin/composer
ENV COMPOSER_HOME=/tmp/composer

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data


WORKDIR /www
