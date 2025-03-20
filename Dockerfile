FROM nginx:1.24.0

RUN apt-get update && apt-get install -y curl bash openssl sudo jq && \
    curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash && \
    mv /root/yandex-cloud/bin/yc /usr/local/bin/ && \
    rm -rf /root/yandex-cloud

COPY script.sh /usr/local/bin/script.sh
COPY cronfile /etc/cron.d/cronfile
COPY nginx.conf /etc/nginx/nginx.conf
COPY authorized_key.json /root/.config/yandex-cloud/authorized_key.json

COPY nginx.conf /etc/nginx/nginx.conf
COPY ./nginx /usr/share/nginx

RUN mkdir -p /var/cache/nginx/client_temp /run /var/log/nginx && \
    chmod +x /usr/local/bin/script.sh && \
    chmod 0644 /etc/cron.d/cronfile

USER root

ENV YC_CONFIG_PATH=/root/.config/yandex-cloud/authorized_key.json

CMD ["/bin/sh", "-c", "/usr/local/bin/script.sh && crond -f & exec nginx -g 'daemon off;'"]
