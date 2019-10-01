FROM php:7.1-fpm

RUN apt-get -qq update && apt-get -qq -y install  \
    automake \
    cmake \
    g++ \
    git \
    libicu-dev \
    libmagickwand-dev \
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
    opcache \
    pdo_mysql \
    sockets \
    zip \
  && git clone git://github.com/alanxz/rabbitmq-c.git \
    && cd rabbitmq-c \
    && mkdir build && cd build \
    && cmake -DENABLE_SSL_SUPPORT=OFF .. \
    && cmake --build . --target install  \
    && pecl install amqp imagick xdebug igbinary \
    && rm -rf ../rabbitmq-c \
  && docker-php-ext-enable amqp imagick xdebug igbinary \
  && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz \
  && rm -rf /var/lib/apt/lists/*
