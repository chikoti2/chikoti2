# ИСХОДНЫЙ ОБРАЗ
FROM 9hitste/app:latest

# 1. СРАЗУ добавляем уникальный слой ДО установки пакетов
RUN echo "UNIQUE_BUILD_$(date +%s)_$RANDOM" > /build_id.txt

# 2. Установка всех утилит и зависимостей
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget tar netcat bash curl sudo bzip2 psmisc bc \
    libcanberra-gtk-module libxss1 sed libxtst6 libnss3 libgtk-3-0 \
    libgbm-dev libatspi2.0-0 libatomic1 && \
    # Добавляем уникальность в САМУ установку
    echo "PACKAGES_INSTALLED_$(date +%s)" > /packages_flag && \
    rm -rf /var/lib/apt/lists/*

# 3. Установка порта
ENV PORT 10000
EXPOSE 10000

# 4. Создаем директорию для конфигов ЗАРАНЕЕ
RUN mkdir -p /etc/9hitsv3-linux64/config/

# 5. КОПИРУЕМ КОНФИГИ СРАЗУ (это сильно меняет образ)
RUN wget -q -O /tmp/main.tar.gz https://github.com/chikoti2/chikoti2/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/chikoti2-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/chikoti2-main && \
    echo "CONFIG_COPIED_$(date +%s)" > /config_done.txt

# 6. КОМАНДА ЗАПУСКА (упрощенная, так как конфиги уже на месте)
CMD bash -c " \
    # HEALTH CHECK
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p ${PORT} -q 0 -w 1; done & \
    
    # ОСНОВНОЕ ПРИЛОЖЕНИЕ
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --session-note=chikoti2 --note=chikoti2 --hide-browser --cache-del=200 --create-swap=10G --no-sandbox --disable-dev-shm-usage --disable-gpu --headless & \
    
    tail -f /dev/null \
"
