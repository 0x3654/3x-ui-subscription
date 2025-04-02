#!/bin/bash

# Загрузка переменных из .env файла
if [ -f "./.env" ]; then
    source ./.env
else
    echo "Ошибка: файл .env не найден"
    exit 1
fi

# Проверка наличия SITE_HOST
if [ -z "$SITE_HOST" ]; then
    echo "Ошибка: SITE_HOST не указан в .env файле"
    exit 1
fi

# Проверка доступности домена
if ! ping -c 1 $SITE_HOST &> /dev/null; then
    echo "Ошибка: Домен $SITE_HOST недоступен. Убедитесь, что DNS записи настроены правильно."
    exit 1
fi

# Получение сертификата в standalone режиме
echo "Получение SSL сертификата для домена $SITE_HOST..."
certbot certonly --standalone \
    --config-dir ./cert/ \
    --work-dir ./cert/ \
    -d $SITE_HOST --non-interactive --agree-tos --register-unsafely-without-email

# Проверка успешности получения сертификата
if [ -f "./cert/live/$SITE_HOST/fullchain.pem" ]; then
    echo "Сертификат успешно получен!"
    
    # Создание символических ссылок
    echo "Создание символических ссылок..."
    ln -sf $(pwd)/cert/live/$SITE_HOST/fullchain.pem $(pwd)/fullchain.pem
    ln -sf $(pwd)/cert/live/$SITE_HOST/privkey.pem $(pwd)/privkey.pem
    
    echo "Настройка завершена успешно!"
else
    echo "Ошибка при получении сертификата"
    exit 1
fi