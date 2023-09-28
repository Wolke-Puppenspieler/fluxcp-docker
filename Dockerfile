FROM alpine:3.7

ENV PHP_FPM_USER=www \
    PHP_FPM_GROUP=www \
    PHP_FPM_LISTEN_MODE=0660 \
    PHP_MEMORY_LIMIT=128M \
    PHP_MAX_UPLOAD=50M \
    PHP_MAX_FILE_UPLOAD=200 \
    PHP_MAX_POST=100M \
    PHP_DISPLAY_ERRORS=On \
    PHP_DISPLAY_STARTUP_ERRORS=On \
    PHP_ERROR_REPORTING=E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR \
    PHP_CGI_FIX_PATHINFO=0

RUN mkdir -p /var/www/fluxcp \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisord.d \
    && apk update \
    && apk add --no-cache nginx php5-fpm php5-pdo php5-pdo_mysql php5-gd gd tidyhtml git nano dos2unix mysql-client bind-tools p7zip supervisor \
    && adduser -D -g 'www' www

RUN sed -i "s|;listen.owner\s*=\s*nobody|listen.owner = ${PHP_FPM_USER}|g" /etc/php5/php-fpm.conf \
    && sed -i "s|;listen.group\s*=\s*nobody|listen.group = ${PHP_FPM_GROUP}|g" /etc/php5/php-fpm.conf \
    && sed -i "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" /etc/php5/php-fpm.conf \
    && sed -i "s|user\s*=\s*nobody|user = ${PHP_FPM_USER}|g" /etc/php5/php-fpm.conf \
    && sed -i "s|group\s*=\s*nobody|group = ${PHP_FPM_GROUP}|g" /etc/php5/php-fpm.conf \
    && sed -i "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php5/php-fpm.conf \
    && sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php5/php.ini \
    && sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" /etc/php5/php.ini \
    && sed -i "s#error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = ${PHP_ERROR_REPORTING}#i" /etc/php5/php.ini \
    && sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php5/php.ini \
    && sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" /etc/php5/php.ini \
    && sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php5/php.ini \
    && sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php5/php.ini \
    && sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" /etc/php5/php.ini

COPY items.7z /tmp/
RUN 7z x /tmp/items.7z -o/var/www/fluxcp \
    && chown -R www:www /var/www \
    && rm -f /tmp/items.7z

RUN mkdir -p /var/www/fluxcp \
    && wget 'https://github.com/HerculesWS/FluxCP/archive/refs/heads/master.zip' -O /tmp/fluxcp.zip \
    && ln -s /var/www/fluxcp /tmp/FluxCP-master \
    && unzip /tmp/fluxcp.zip -d /tmp \
    && rm -f /tmp/FluxCP-master \
    && chown -R www:www /var/lib/nginx \
    && chown -R www:www /var/www

COPY config/servers.loader.php /tmp/servers.loader.php
COPY config/servers.override.default.php /tmp/servers.override.default.php
RUN mv '/var/www/fluxcp/config/servers.php' '/var/www/fluxcp/config/servers.base.php' \
    && mv '/tmp/servers.loader.php' '/var/www/fluxcp/config/servers.php' \
    && mv '/tmp/servers.override.default.php' '/var/www/fluxcp/config/servers.override.php'

COPY supervisord.conf /etc/
COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]