# See list of supported versions: https://github.com/phpipam/phpipam?tab=readme-ov-file#supported-php-versions
# Or check the check script: https://github.com/phpipam/phpipam/blob/master/functions/checks/check_php_build.php
# renovate-docker: depName=php
ARG PHP_VERSION="8.3.30"
# renovate-docker: depName=dunglas/frankenphp
ARG FRANKENPHP_VERSION="1.12.1"

#---------------------------------------------------------
FROM bitnami/git@sha256:e1d8c8b3fe0d8b213157478b1db32d405331394a60eacae0e8b4a4e0c650e9ed AS clone

# renovate-github-release: repo=phpipam/phpipam
ARG PHPIPAM_VERSION="v1.7.4"

RUN git clone --depth 1 --recursive -b "${PHPIPAM_VERSION}" https://github.com/phpipam/phpipam.git /phpipam

#---------------------------------------------------------
FROM composer AS composer

COPY --from=clone --exclude=.git /phpipam /app
WORKDIR /app/functions

RUN composer install --ignore-platform-reqs

#---------------------------------------------------------
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-trixie

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
    # mbstring \
    # Undocumented dependencies: \
    gd \
    # iconv \
    # ctype \
    # curl \
    # dom \
    # pcre \
    # libxml \
    # Additional dependencies for phpipam: \
    snmp


# renovate-debian: suite=trixie depName=fping
ARG FPING_VERSION="5.1-1"

# renovate-debian: suite=trixie depName=inetutils-ping
ARG INETUTILS_PING_VERSION="2:2.6-3+deb13u2"

RUN apt-get update && \
    apt-get install -y \
    fping="${FPING_VERSION}" \
    inetutils-ping="${INETUTILS_PING_VERSION}" \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
COPY --from=composer /app /var/www/phpipam

#RUN cp /var/www/phpipam/config.dist.php /var/www/phpipam/config.php
RUN cp /var/www/phpipam/config.docker.php /var/www/phpipam/config.php

