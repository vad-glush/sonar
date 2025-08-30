#!/bin/bash

# Скрипт обновления SonarQube до версии 25.8.0.112029-community
# Автор: Assistant
# Дата: $(date)

set -e  # Остановка при ошибке

echo "🚀 Начинаем обновление SonarQube до версии 25.8.0.112029-community"
echo "================================================================"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Проверка прав доступа
if [ "$EUID" -ne 0 ]; then
    error "Этот скрипт должен выполняться с правами root"
fi

log "Пропускаем создание резервной копии (есть снапшот машины)"

# Остановка текущих контейнеров
log "Остановка текущих контейнеров..."
cd /home/corp.ekassir.com/glushkovvs/Docker-compose/26_08_2025/
docker-compose -f docker_sonar.yml down

# Обновление PostgreSQL до 15.6
log "Обновление PostgreSQL до версии 15.6..."

# Создание временного контейнера PostgreSQL 15.6 для миграции
log "Создание временного контейнера PostgreSQL 15.6..."
docker run --name postgres_temp_15 \
    -e POSTGRES_USER=sonar \
    -e POSTGRES_PASSWORD=sonar \
    -e POSTGRES_DB=sonar \
    -v /var/storage/sonarqube/db:/var/lib/postgresql/data \
    -d postgres:15.6

# Ожидание запуска PostgreSQL
log "Ожидание запуска PostgreSQL 15.6..."
sleep 30

# Проверка подключения к PostgreSQL
log "Проверка подключения к PostgreSQL 15.6..."
if docker exec postgres_temp_15 pg_isready -U sonar; then
    log "PostgreSQL 15.6 успешно запущен"
else
    error "PostgreSQL 15.6 не удалось запустить"
fi

# Проверка данных
log "Проверка целостности данных..."
if docker exec postgres_temp_15 psql -U sonar -d sonar -c "SELECT COUNT(*) FROM users;" > /dev/null 2>&1; then
    log "Данные доступны в PostgreSQL 15.6"
else
    warn "Возможны проблемы с данными в PostgreSQL 15.6"
fi

# Остановка временного контейнера
log "Остановка временного контейнера PostgreSQL..."
docker stop postgres_temp_15
docker rm postgres_temp_15

# Обновление docker-compose файла
log "Обновление docker-compose файла..."
cp docker_sonar.yml docker_sonar_backup.yml
cp docker_sonar_25_upgraded.yml docker_sonar.yml

# Загрузка новых образов
log "Загрузка новых Docker образов..."
docker pull sonarqube:25.8.0.112029-community
docker pull postgres:15.6

# Запуск обновленной конфигурации
log "Запуск обновленной конфигурации..."
docker-compose -f docker_sonar.yml up -d

# Ожидание запуска
log "Ожидание запуска SonarQube 25.8.0..."
sleep 60

# Проверка статуса
log "Проверка статуса SonarQube..."
if curl -s http://localhost:9000/api/system/status | grep -q "UP"; then
    log "SonarQube 25.8.0 успешно запущен!"
else
    warn "SonarQube может еще запускаться, проверьте логи"
fi

# Проверка версии
log "Проверка версии SonarQube..."
VERSION=$(curl -s http://localhost:9000/api/system/status | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
log "Установленная версия: $VERSION"

# Проверка PostgreSQL
log "Проверка версии PostgreSQL..."
PG_VERSION=$(docker exec sonarqube-postgres psql -U sonar -t -c "SELECT version();" | head -1)
log "Версия PostgreSQL: $PG_VERSION"

echo "================================================================"
log "Обновление завершено!"
log "SonarQube доступен по адресу: http://10.0.21.47:9000"
echo "================================================================"

# Инструкции по откату
echo ""
warn "Для отката к предыдущей версии выполните:"
echo "1. cd /home/corp.ekassir.com/glushkovvs/Docker-compose/26_08_2025/"
echo "2. docker-compose -f docker_sonar.yml down"
echo "3. cp docker_sonar_backup.yml docker_sonar.yml"
echo "4. docker-compose -f docker_sonar.yml up -d"
echo ""
