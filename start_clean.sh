#!/bin/bash

echo "🚀 Запуск чистой версии SonarQube 10.7.0 с Community Branch Plugin..."

# Остановка существующих контейнеров
echo "📦 Остановка существующих контейнеров..."
docker-compose -f docker_sonar_clean.yml down

# Сборка и запуск
echo "🔨 Сборка и запуск контейнеров..."
docker-compose -f docker_sonar_clean.yml up --build -d

echo "⏳ Ожидание запуска SonarQube..."
sleep 60

# Проверка статуса
echo "📊 Проверка статуса контейнеров..."
docker-compose -f docker_sonar_clean.yml ps

echo ""
echo "✅ SonarQube 10.7.0 запущен!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   docker logs sonarqube-clean"
echo ""
echo "🛑 Для остановки:"
echo "   docker-compose -f docker_sonar_clean.yml down"
