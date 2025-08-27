#!/bin/bash

echo "🚀 Безопасное обновление SonarQube на сервере..."
echo ""

# Проверка текущего статуса
echo "📊 Проверка текущего статуса..."
curl -s http://localhost:9000/api/system/status
echo ""

# Создание резервной копии
echo "💾 Создание резервной копии..."
sudo cp /home/corp.ekassir.com/glushkovvs/Docker-compose/docker_sonar.yml /home/corp.ekassir.com/glushkovvs/Docker-compose/docker_sonar.yml.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Резервная копия создана"

# Остановка текущих контейнеров
echo "🛑 Остановка текущих контейнеров..."
cd /home/corp.ekassir.com/glushkovvs/Docker-compose
sudo docker-compose -f docker_sonar.yml down

# Создание Dockerfile для обновления
echo "🔨 Создание Dockerfile для обновления..."
cat > /home/corp.ekassir.com/glushkovvs/Docker-compose/Dockerfile.sonarqube-lts-with-plugin << 'EOF'
FROM sonarqube:lts-community

USER root

# Установка необходимых инструментов
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Создание директории для плагинов
RUN mkdir -p /opt/sonarqube/extensions/plugins

# Загрузка и установка sonarqube-community-branch-plugin 1.14.0
RUN cd /opt/sonarqube/extensions/plugins && \
    wget -O sonarqube-community-branch-plugin-1.14.0.jar \
    https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/1.14.0/sonarqube-community-branch-plugin-1.14.0.jar

# Установка прав доступа
RUN chown -R sonarqube:root /opt/sonarqube/extensions/plugins

USER sonarqube

# Проверка установки плагина
RUN ls -la /opt/sonarqube/extensions/plugins/
EOF

echo "✅ Dockerfile создан"

# Запуск обновленной версии
echo "🚀 Запуск обновленной версии..."
sudo docker-compose -f docker_sonar_server_upgrade.yml up -d --build

# Ожидание запуска
echo "⏳ Ожидание запуска SonarQube..."
sleep 60

# Проверка статуса
echo "📊 Проверка статуса обновленной версии..."
curl -s http://localhost:9000/api/system/status
echo ""

echo ""
echo "✅ Обновление завершено!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   sudo docker logs sonarqube-upgraded"
echo ""
echo "🛑 Для отката (если нужно):"
echo "   sudo docker-compose -f docker_sonar.yml down"
echo "   sudo docker-compose -f docker_sonar.yml up -d"
