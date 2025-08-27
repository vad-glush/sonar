#!/bin/bash

echo "🚀 Запуск финальной версии SonarQube 9.9.8 LTS с Community Branch Plugin 1.14.0..."

# Остановка существующих контейнеров
echo "📦 Остановка существующих контейнеров..."
docker-compose -f docker_sonar_final.yml down

# Сборка и запуск контейнеров
echo "🔨 Сборка и запуск контейнеров..."
docker-compose -f docker_sonar_final.yml up -d --build

# Ожидание запуска
echo "⏳ Ожидание запуска SonarQube..."
sleep 30

# Проверка статуса
echo "📊 Проверка статуса контейнеров..."
docker ps | grep sonarqube

echo ""
echo "✅ SonarQube 9.9.8 LTS с плагином 1.14.0 запущен!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   docker logs sonarqube-final"
echo ""
echo "🛑 Для остановки:"
echo "   docker-compose -f docker_sonar_final.yml down"
