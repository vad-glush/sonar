#!/bin/bash

echo "🚀 Офлайн обновление SonarQube на сервере..."
echo ""

# Проверка наличия образов
echo "📦 Проверка наличия образов..."
if ! docker images | grep -q "sonarqube.*9.9.8-community"; then
    echo "❌ Образ sonarqube:9.9.8-community не найден!"
    echo "💡 Загрузите образ командой: docker load -i sonarqube-9.9.8-community.tar"
    exit 1
fi

if ! docker images | grep -q "postgres.*15.6"; then
    echo "❌ Образ postgres:15.6 не найден!"
    echo "💡 Загрузите образ командой: docker load -i postgres-15.6.tar"
    exit 1
fi

echo "✅ Образы найдены"

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
cat > /home/corp.ekassir.com/glushkovvs/Docker-compose/Dockerfile.sonarqube-9.9.8-with-plugin << 'EOF'
FROM sonarqube:9.9.8-community

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
    curl -L -o sonarqube-community-branch-plugin-1.14.0.jar \
    https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/1.14.0/sonarqube-community-branch-plugin-1.14.0.jar

# Установка прав доступа
RUN chown -R sonarqube:root /opt/sonarqube/extensions/plugins

USER sonarqube

# Проверка установки плагина
RUN ls -la /opt/sonarqube/extensions/plugins/
EOF

echo "✅ Dockerfile создан"

# Создание обновленного docker-compose файла
echo "📝 Создание обновленного docker-compose файла..."
cat > /home/corp.ekassir.com/glushkovvs/Docker-compose/docker_sonar_offline_upgrade.yml << 'EOF'
version: '3'

services:
  sonarqube:
    build:
      context: .
      dockerfile: Dockerfile.sonarqube-9.9.8-with-plugin
    container_name: sonarqube-upgraded
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
      - sonar.es.bootstrap.checks.disable=true
      - sonar.jdbc.username=sonar
      - sonar.jdbc.password=sonar
      - sonar.jdbc.url=jdbc:postgresql://sonarqube-postgres:5432/sonar
      - SONAR_WEB_JAVAADDITIONALOPTS=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin-1.14.0.jar=web
      - SONAR_CE_JAVAADDITIONALOPTS=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin-1.14.0.jar=ce
    volumes:
      - sonar_datax:/opt/sonarqube/data:rw
      - sonar_conf:/opt/sonarqube/conf:rw
      - sonar_logs:/opt/sonarqube/logs:rw
      - sonar_ext:/opt/sonarqube/extensions:rw
    ports:
      - "9000:9000"
    networks:
      - sonarnet
    extra_hosts:
      - "ibpsoft:192.168.7.222"
    restart: always
    depends_on:
      - sonarqube-postgres

  sonarqube-postgres:
    image: postgres:15.6
    container_name: sonarqube-postgres-upgraded
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - sonar_data_db:/var/lib/postgresql/data:rw
    networks:
      - sonarnet
    restart: always

networks:
  sonarnet:
    driver: bridge

volumes:
  sonar_datax:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/storage/sonarqube/data/data/'
  sonar_conf:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/storage/sonarqube/data/conf/'
  sonar_logs:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/storage/sonarqube/data/logs/'
  sonar_ext:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/storage/sonarqube/data/extensions/'
  sonar_data_db:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/storage/sonarqube/db/'
EOF

echo "✅ Обновленный docker-compose файл создан"

# Запуск обновленной версии
echo "🚀 Запуск обновленной версии..."
sudo docker-compose -f docker_sonar_offline_upgrade.yml up -d --build

# Ожидание запуска
echo "⏳ Ожидание запуска SonarQube..."
sleep 60

# Проверка статуса
echo "📊 Проверка статуса обновленной версии..."
curl -s http://localhost:9000/api/system/status
echo ""

echo ""
echo "✅ Офлайн обновление завершено!"
echo "🌐 Доступен по адресу: http://localhost:9000"
echo "🔑 Логин по умолчанию: admin/admin"
echo ""
echo "📋 Для просмотра логов:"
echo "   sudo docker logs sonarqube-upgraded"
echo ""
echo "🛑 Для отката (если нужно):"
echo "   sudo docker-compose -f docker_sonar.yml down"
echo "   sudo docker-compose -f docker_sonar.yml up -d"
