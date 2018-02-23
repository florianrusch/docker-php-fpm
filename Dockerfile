FROM php:fpm-alpine3.7
LABEL maintainer="dev@florianrusch.de"

RUN apk update && apk upgrade && \
    apk add bash bash-doc bash-completion --no-cache && \

    # Install Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer --version && \

    # Set timezone
    rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \

    # Type docker-php-ext-install to see available extensions
    docker-php-ext-install mysqli pdo_mysql opcache && \

    # install xdebug
    apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS && \
    pecl install xdebug && \
    docker-php-ext-enable mysqli pdo_mysql opcache xdebug && \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    apk del .phpize-deps && \

    echo "file_uploads = On" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "memory_limit = 64M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/custom.ini && \

    # Custom commands
    echo 'alias sf3="php bin/console"' >> ~/.bashrc && \
    echo 'alias ll="ls -la --color"' >> ~/.bashrc && \

    # Final cleanup
    rm -rf /var/cache/apk/* /tmp/*

ADD symfony.pool.conf /usr/local/etc/php-fpm.d/

WORKDIR /usr/share/nginx/html

EXPOSE 9000
