# See https://github.com/docker-library/php/blob/4677ca134fe48d20c820a19becb99198824d78e3/7.0/fpm/Dockerfile
FROM php:fpm-alpine
MAINTAINER Florian Rusch <dev@florianrusch.de>

RUN apk update && apk upgrade && \
    apk add git unzip bash bash-doc bash-completion --no-cache && \

	# Install Composer
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
	composer --version && \

	# Set timezone
	rm /etc/localtime && \
	ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \

	# Type docker-php-ext-install to see available extensions
	docker-php-ext-install pdo_mysql opcache && \

	# install xdebug
	pecl install xdebug && \
	docker-php-ext-enable xdebug opcache && \
	echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \

	# Custom commands
	echo 'alias sf3="php bin/console"' >> ~/.bashrc && \
	echo 'alias ll="ls -la --color"' >> ~/.bashrc && \

	# Final cleanup
	rm -rf /var/cache/apk/* /tmp/*

ADD symfony.pool.conf /usr/local/etc/php-fpm.d/

WORKDIR /usr/share/nginx/html

EXPOSE 9000
