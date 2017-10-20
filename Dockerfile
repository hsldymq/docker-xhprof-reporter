FROM php:7.1-fpm-alpine

ADD build/ /docker-build/

RUN echo -e "https://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttps://mirrors.ustc.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk --no-cache add ca-certificates && update-ca-certificates && \
    apk --no-cache add \
        autoconf \
        build-base \
        zlib-dev \
        libtool \
        linux-headers \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        graphviz \
        pcre-dev \
        ttf-dejavu \
        ttf-droid \
        ttf-freefont \
        ttf-liberation \
        ttf-ubuntu-font-family

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd

RUN mkdir -p /var/tmp/volume/xhprof && \
    chmod -R 777 /var/tmp/volume && \
    mkdir -p /var/www/xhprof/xhprof_html && \
    mkdir -p /var/www/xhprof/xhprof_lib && \
    cp -R /docker-build/php-extensions/xhprof/xhprof_html/* /var/www/xhprof/xhprof_html && \
    cp -R /docker-build/php-extensions/xhprof/xhprof_lib/* /var/www/xhprof/xhprof_lib && \
    chmod -R a+w /var/www/xhprof

# 安装xhprof扩展
RUN cd /docker-build/php-extensions/xhprof/extension && \
    phpize && ./configure && make && make install && \
    echo -e "extension=xhprof.so\nxhprof.output_dir=/var/tmp/volume/xhprof" > /usr/local/etc/php/conf.d/xhprof.ini && \
    rm -rf /docker-build

WORKDIR /var/www/xhprof/xhprof_html

ENTRYPOINT ["docker-php-entrypoint"]

CMD ["php", "-S", "0.0.0.0:9527"]

EXPOSE 9527

