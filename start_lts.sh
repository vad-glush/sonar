#!/bin/bash

echo "🚀 Запуск SonarQube LTS версии..."

# Остановка существующих контейнеров
echo "📦 Остановка существующих контейнеров..."
docker-compose -f docker_sonar_lts.yml down

# Запуск контейнеров
echo "🔨 Запуск контейнеров..."
docker-compose -f docker_sonar_lts.yml up -d

# Ожидание запуска
echo "⏳ Ожидание запуска SonarQube..."
sleep 30

# Проверка статуса
echo "📊 Проверка статуса контейнеров..."
docker ps | grep sonarqube

echo ""
echo "✅ SonarQube LTS запущен!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   docker logs sonarqube-lts"
echo ""
echo "🛑 Для остановки:"
echo "   docker-compose -f docker_sonar_lts.yml down"
