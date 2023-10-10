FROM php:8.1-apache
MAINTAINER TyRoyal
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/



RUN set -ex; \
    a2enmod rewrite; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    chmod +x /usr/local/bin/install-php-extensions; \
    install-php-extensions imagick bcmath pdo_mysql redis; \
    apt-get clean; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/* ;\
    rm -rf /var/cache/apt/* ;\
    rm -rf /tmp/* ;

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