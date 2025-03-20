#!/bin/sh

export YC_CONFIG_PATH=/root/.config/yandex-cloud/authorized_key.json
yc config set service-account-key /root/.config/yandex-cloud/authorized_key.json

LOCKBOX_SECRET_ID="e6qbe9r68i094v9o9oic"

if ! yc lockbox payload get --id "$LOCKBOX_SECRET_ID" --format json > /dev/null 2>&1; then
    echo "Ошибка: Невозможно получить данные из Lockbox. Проверьте аутентификацию."
    exit 1
fi

SECRET_JSON=$(yc lockbox payload get --id "$LOCKBOX_SECRET_ID" --format json)

BASIC_AUTH=$(echo "$SECRET_JSON" | jq -r '.entries[] | select(.key=="basic") | .text_value')

USERNAME=$(echo "$BASIC_AUTH" | cut -d':' -f1)
PASSWORD=$(echo "$BASIC_AUTH" | cut -d':' -f2)

echo "$USERNAME:$(openssl passwd -apr1 "$PASSWORD")" > /etc/nginx/.htpasswd

nginx -s reload
