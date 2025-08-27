#!/bin/bash

echo "🚀 Запуск SonarQube 9.9.8 LTS с Community Branch Plugin..."

# Остановка существующих контейнеров
echo "📦 Остановка существующих контейнеров..."
docker-compose -f docker_sonar_local.yml down

# Сборка и запуск
echo "🔨 Сборка и запуск контейнеров..."
docker-compose -f docker_sonar_local.yml up --build -d

echo "⏳ Ожидание запуска SonarQube..."
sleep 60

# Проверка статуса
echo "📊 Проверка статуса контейнеров..."
docker-compose -f docker_sonar_local.yml ps

echo ""
echo "✅ SonarQube 9.9.8 LTS запущен!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   docker logs sonarqube-local"
echo ""
echo "🛑 Для остановки:"
echo "   docker-compose -f docker_sonar_local.yml down"
