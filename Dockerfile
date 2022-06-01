FROM php:8.1-apache
MAINTAINER TyRoyal
RUN a2enmod rewrite

RUN apt-get update && apt-get install imagemagick libmagickwand-dev -y \
    && pecl install imagick \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable imagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/* \
    && rm -rf /tmp/* 

RUN { \
    echo 'post_max_size = 100M;';\
    echo 'upload_max_filesize = 100M;';\
    echo 'max_execution_time = 600S;';\
    } > /usr/local/etc/php/conf.d/docker-php-upload.ini; 

RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini; \
    \
    mkdir -p /var/www/data; \
    chown -R www-data:root /var/www; \
    chmod -R g=u /var/www

COPY ./ /var/www/lsky/
COPY ./000-default.conf /etc/apache2/sites-enabled/
COPY entrypoint.sh /

WORKDIR /var/www/html
VOLUME /var/www/html
EXPOSE 80

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["apachectl","-D","FOREGROUND"]