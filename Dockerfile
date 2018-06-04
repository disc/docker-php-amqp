FROM php:7.1-fpm

RUN apt-get -qq update && apt-get -qq -y install  \
    automake \
    cmake \
    g++ \
    git \
    libicu-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng-dev \
    librabbitmq-dev \
    libreadline-dev \
    pkg-config \
    ssh-client \
    supervisor \
    zlib1g-dev \
  && docker-php-ext-install \
    bcmath \
    gd \
    intl \
    mcrypt \
    opcache \
    pdo_mysql \
    zip \
  && git clone git://github.com/alanxz/rabbitmq-c.git \
    && cd rabbitmq-c \
    && mkdir build && cd build \
    && cmake -DENABLE_SSL_SUPPORT=OFF .. \
    && cmake --build . --target install  \
    && pecl install amqp imagick xdebug igbinary \
  && docker-php-ext-enable amqp imagick xdebug igbinary \
  && rm -rf /var/lib/apt/lists/*
