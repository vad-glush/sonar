#!/bin/bash

echo "🛑 Остановка SonarQube..."

# Остановка контейнеров
docker-compose -f docker_sonar_local.yml down

echo "✅ SonarQube остановлен!"
echo ""
echo "💾 Данные сохранены в Docker volumes"
echo "🚀 Для повторного запуска используйте: ./start_local.sh"
