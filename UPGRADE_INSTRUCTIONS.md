Vg39)@v;
# Инструкции по обновлению SonarQube до 25.8.0.112029-community

## 📋 Подготовка

### 1. Подключение к серверу
```bash
ssh glushkovvs@10.0.21.47
```

### 2. Переход в рабочую директорию
```bash
cd /root/Docker-compose/26_08_2025/
```

### 3. Проверка текущего состояния
```bash
# Проверка версии SonarQube
curl http://localhost:9000/api/system/status

# Проверка версии PostgreSQL
docker exec sonarqube-postgres psql -U sonar -c "SELECT version();"

# Проверка размера данных
du -sh /var/storage/sonarqube/
```

## 🚀 Выполнение обновления

### Вариант 1: Автоматическое обновление (рекомендуется)

1. **Скопируйте файлы на сервер:**
```bash
# На вашем локальном компьютере
scp docker_sonar_25_upgraded.yml glushkovvs@10.0.21.47:/root/Docker-compose/26_08_2025/
scp upgrade_to_25_script.sh glushkovvs@10.0.21.47:/root/Docker-compose/26_08_2025/
```

2. **На сервере выполните:**
```bash
cd /root/Docker-compose/26_08_2025/
chmod +x upgrade_to_25_script.sh
./upgrade_to_25_script.sh
```

### Вариант 2: Ручное обновление

#### Шаг 1: Остановка контейнеров
```bash
# Остановка контейнеров
docker-compose -f docker_sonar.yml down
```

#### Шаг 2: Тестирование PostgreSQL 15.6
```bash
# Создание временного контейнера
docker run --name postgres_temp_15 \
    -e POSTGRES_USER=sonar \
    -e POSTGRES_PASSWORD=sonar \
    -e POSTGRES_DB=sonar \
    -v /var/storage/sonarqube/db:/var/lib/postgresql/data \
    -d postgres:15.6

# Ожидание запуска
sleep 30

# Проверка данных
docker exec postgres_temp_15 psql -U sonar -d sonar -c "SELECT COUNT(*) FROM users;"

# Остановка временного контейнера
docker stop postgres_temp_15
docker rm postgres_temp_15
```

#### Шаг 3: Обновление конфигурации
```bash
# Резервная копия текущей конфигурации
cp docker_sonar.yml docker_sonar_backup.yml

# Замена на новую конфигурацию
cp docker_sonar_25_upgraded.yml docker_sonar.yml
```

#### Шаг 4: Загрузка новых образов
```bash
docker pull sonarqube:25.8.0.112029-community
docker pull postgres:15.6
```

#### Шаг 5: Запуск обновленной конфигурации
```bash
docker-compose -f docker_sonar.yml up -d
```

#### Шаг 6: Ожидание и проверка
```bash
# Ожидание запуска
sleep 60

# Проверка статуса
curl http://localhost:9000/api/system/status

# Проверка версии
curl -s http://localhost:9000/api/system/status | grep -o '"version":"[^"]*"'
```

## 🔍 Проверка после обновления

### 1. Проверка версий
```bash
# SonarQube
curl -s http://localhost:9000/api/system/status | grep -o '"version":"[^"]*"'

# PostgreSQL
docker exec sonarqube-postgres psql -U sonar -c "SELECT version();"
```

### 2. Проверка данных
```bash
# Количество пользователей
docker exec sonarqube-postgres psql -U sonar -d sonar -c "SELECT COUNT(*) FROM users;"

# Количество проектов
docker exec sonarqube-postgres psql -U sonar -d sonar -c "SELECT COUNT(*) FROM projects;"

# Размер базы данных
docker exec sonarqube-postgres psql -U sonar -d sonar -c "SELECT pg_size_pretty(pg_database_size('sonar'));"
```

### 3. Проверка плагина
```bash
# Проверка логов на наличие плагина
docker logs sonarqube | grep -i "community branch plugin"
```

## ⚠️ Возможные проблемы и решения

### Проблема 1: PostgreSQL не запускается
```bash
# Проверка логов
docker logs sonarqube-postgres

# Проверка прав доступа
ls -la /var/storage/sonarqube/db/
chown -R 999:999 /var/storage/sonarqube/db/
```

### Проблема 2: SonarQube не подключается к базе
```bash
# Проверка переменных окружения
docker exec sonarqube env | grep -E "(JDBC|POSTGRES)"

# Проверка сети
docker network ls
docker network inspect 26_08_2025_sonarnet
```

### Проблема 3: Ошибки миграции
```bash
# Проверка логов SonarQube
docker logs sonarqube | grep -i "migration\|error"

# Возможное решение - очистка кэша
docker exec sonarqube rm -rf /opt/sonarqube/temp/*
```

## 🔄 Откат к предыдущей версии

Если что-то пошло не так:

```bash
# Остановка текущих контейнеров
docker-compose -f docker_sonar.yml down

# Восстановление резервной копии
cp docker_sonar_backup.yml docker_sonar.yml

# Запуск предыдущей версии
docker-compose -f docker_sonar.yml up -d
```

## 📊 Ожидаемые результаты

После успешного обновления:
- **SonarQube**: 25.8.0.112029-community
- **PostgreSQL**: 15.6
- **Community Branch Plugin**: 25.7.0
- **Все данные**: Сохранены
- **Функциональность**: Полностью работоспособна

## 🎯 Контакты для поддержки

При возникновении проблем:
1. Проверьте логи: `docker logs sonarqube`
2. Проверьте статус: `curl http://localhost:9000/api/system/status`
3. Используйте снапшот машины для полного отката
