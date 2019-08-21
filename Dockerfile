FROM php:7.2-fpm-alpine3.10 as temp

COPY extensions /extensions

# 编译xhprof
RUN echo -e "https://mirrors.aliyun.com/alpine/v3.10/main\n" > /etc/apk/repositories && \
    echo -e "https://mirrors.aliyun.com/alpine/v3.10/community\n" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS && \
    cd /extensions/xhprof && phpize && ./configure && make && make install && \
    mkdir /php-ext && cp $(php-config --extension-dir)/xhprof.so /php-ext

FROM php:7.2-fpm-alpine3.10

COPY --from=temp /php-ext/* /php-ext/
COPY profiler_gui/ /var/www/xhprof/

RUN echo -e "https://mirrors.aliyun.com/alpine/v3.10/main\n" > /etc/apk/repositories && \
    echo -e "https://mirrors.aliyun.com/alpine/v3.10/community\n" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk --no-cache add \
        ca-certificates \
        freetype-dev libpng-dev libjpeg-turbo-dev \
        graphviz \
        pcre-dev \
        ttf-dejavu \
        ttf-droid \
        ttf-freefont \
        ttf-liberation \
        ttf-ubuntu-font-family && \
    update-ca-certificates

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    mv /php-ext/xhprof.so $(php-config --extension-dir) && \
    docker-php-ext-enable xhprof && \
    printf "\nxhprof.output_dir = \"\${XHPROF_OUTPUT_DIR}\"" >> /usr/local/etc/php/conf.d/xhprof.ini

COPY php.ini /usr/local/etc/php/conf.d/0.php.ini

ENV XHPROF_OUTPUT_DIR="" \
    PHP_TIMEZONE="Asia/Shanghai"

WORKDIR /var/www/xhprof/xhprof_html

ENTRYPOINT ["docker-php-entrypoint"]

CMD ["php", "-S", "0.0.0.0:9527"]

EXPOSE 9527

