# See list of supported versions: https://github.com/phpipam/phpipam?tab=readme-ov-file#supported-php-versions
# Or check the check script: https://github.com/phpipam/phpipam/blob/master/functions/checks/check_php_build.php
# renovate-docker: depName=php
ARG PHP_VERSION="8.3.29"
# renovate-docker: depName=dunglas/frankenphp
ARG FRANKENPHP_VERSION="1.11.1"

#---------------------------------------------------------
FROM bitnami/git@sha256:e1d8c8b3fe0d8b213157478b1db32d405331394a60eacae0e8b4a4e0c650e9ed AS clone

# renovate-github-release: repo=phpipam/phpipam
ARG PHPIPAM_VERSION="v1.7.4"

RUN git clone --depth 1 --recursive -b "${PHPIPAM_VERSION}" https://github.com/phpipam/phpipam.git /phpipam

#---------------------------------------------------------
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}

# Check required extensions for phpipam: https://phpipam.net/documents/installation/
# And undocumented dependencies: https://github.com/phpipam/phpipam/blob/master/functions/checks/check_php_build.php
RUN install-php-extensions \
    pdo_mysql \
    # session \
    sockets \
    # openssl \
    gmp \
    ldap \
    # crypt \
    # SimpleXML \
    # json \
    gettext \
    # filter \
    pcntl \
    # cli \
    # mbstring
    # Undocumented dependencies:
    gd
    # iconv \
    # ctype \
    # curl \
    # dom \
    # pcre \
    # libxml \

ENV SERVER_ROOT=/var/www/phpipam
ENV SERVER_NAME=:80
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

ARG USER=appuser
RUN <<-EOF
	useradd ${USER}
	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp
	chown -R ${USER}:${USER} /config/caddy /data/caddy
EOF
USER ${USER}

WORKDIR /var/www/phpipam
COPY --from=clone --exclude=.git /phpipam /var/www/phpipam

#RUN cp /var/www/phpipam/config.dist.php /var/www/phpipam/config.php
RUN cp /var/www/phpipam/config.docker.php /var/www/phpipam/config.php

