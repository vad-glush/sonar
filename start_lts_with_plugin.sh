#!/bin/bash

echo "🚀 Запуск SonarQube LTS с Community Branch Plugin 1.14.0..."

# Остановка существующих контейнеров
echo "📦 Остановка существующих контейнеров..."
docker-compose -f docker_sonar_lts_with_plugin.yml down

# Сборка и запуск контейнеров
echo "🔨 Сборка и запуск контейнеров..."
docker-compose -f docker_sonar_lts_with_plugin.yml up -d --build

# Ожидание запуска
echo "⏳ Ожидание запуска SonarQube..."
sleep 30

# Проверка статуса
echo "📊 Проверка статуса контейнеров..."
docker ps | grep sonarqube

echo ""
echo "✅ SonarQube LTS с плагином 1.14.0 запущен!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   docker logs sonarqube-lts-with-plugin"
echo ""
echo "🛑 Для остановки:"
echo "   docker-compose -f docker_sonar_lts_with_plugin.yml down"
