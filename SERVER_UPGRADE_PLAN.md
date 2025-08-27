# 📋 ПЛАН ОБНОВЛЕНИЯ SONARQUBE НА СЕРВЕРЕ

## 🎯 Текущее состояние сервера

### Версии
- **SonarQube**: 9.8-SNAPSHOT (кастомный образ `cloudkasten/sonar-with-branch`)
- **Community Branch Plugin**: 1.13.0
- **PostgreSQL**: 11.15
- **Docker Compose**: версия 2

### Конфигурация
- **Путь**: `/home/corp.ekassir.com/glushkovvs/Docker-compose/`
- **Файл**: `docker_sonar.yml`
- **Сеть**: docker-compose_sonarnet
- **Volumes**: bind mounts на `/var/storage/sonarqube/`

## 🚀 Планируемое обновление

### Новые версии
- **SonarQube**: LTS (9.9.8.100196)
- **Community Branch Plugin**: 1.14.0 (совместимая с 9.x)
- **PostgreSQL**: 15.6 (обновление с 11.15)
- **Docker Compose**: версия 3

### Что сохранится
✅ **Все данные**: проекты, настройки, история анализов
✅ **Конфигурация**: все настройки SonarQube
✅ **Плагины**: обновленная версия Community Branch Plugin
✅ **Volumes**: все bind mounts остаются без изменений
✅ **Сеть**: та же сеть docker-compose_sonarnet

## 📁 Файлы для обновления

### 1. Новый docker-compose файл
```bash
# Скопируйте файл docker_sonar_server_upgrade.yml в директорию
/home/corp.ekassir.com/glushkovvs/Docker-compose/
```

### 2. Dockerfile для сборки образа
```bash
# Dockerfile.sonarqube-lts-with-plugin будет создан автоматически
```

### 3. Скрипт обновления
```bash
# upgrade_server.sh - автоматизированный скрипт обновления
```

## 🔄 Процесс обновления

### Этап 1: Подготовка
1. ✅ Создание резервной копии текущего docker-compose файла
2. ✅ Проверка текущего статуса SonarQube
3. ✅ Создание Dockerfile для нового образа

### Этап 2: Обновление
1. 🛑 Остановка текущих контейнеров
2. 🔨 Сборка нового образа с SonarQube LTS и плагином 1.14.0
3. 🚀 Запуск обновленных контейнеров
4. ⏳ Ожидание запуска и проверка статуса

### Этап 3: Проверка
1. ✅ Проверка API статуса
2. ✅ Проверка загрузки плагина
3. ✅ Проверка веб-интерфейса
4. ✅ Проверка всех данных

## 🛡️ Безопасность

### Резервное копирование
- Автоматическое создание резервной копии docker-compose файла
- Все данные сохраняются в bind mounts
- Возможность быстрого отката

### Откат
```bash
# Если что-то пойдет не так:
sudo docker-compose -f docker_sonar.yml down
sudo docker-compose -f docker_sonar.yml up -d
```

## 📊 Ожидаемые улучшения

### Производительность
- Обновленный PostgreSQL 15.6
- Оптимизации SonarQube LTS
- Улучшенная стабильность

### Функциональность
- Последние исправления безопасности
- Улучшенная совместимость плагина
- Поддержка новых функций

## 🎯 Команды для выполнения

### 1. Копирование файлов на сервер
```bash
# Скопируйте файлы в /home/corp.ekassir.com/glushkovvs/Docker-compose/
```

### 2. Запуск обновления
```bash
cd /home/corp.ekassir.com/glushkovvs/Docker-compose/
chmod +x upgrade_server.sh
./upgrade_server.sh
```

### 3. Проверка после обновления
```bash
curl -s http://localhost:9000/api/system/status
sudo docker logs sonarqube-upgraded
```

## ⚠️ Важные замечания

1. **Время простоя**: ~5-10 минут во время обновления
2. **Данные**: Все данные сохраняются
3. **Плагин**: Обновляется с 1.13.0 до 1.14.0
4. **PostgreSQL**: Обновляется с 11.15 до 15.6
5. **Совместимость**: Плагин 1.14.0 совместим с SonarQube 9.x LTS

## 🎉 Ожидаемый результат

После обновления у вас будет:
- ✅ SonarQube LTS 9.9.8.100196
- ✅ Community Branch Plugin 1.14.0
- ✅ PostgreSQL 15.6
- ✅ Все данные и настройки сохранены
- ✅ Улучшенная производительность и стабильность
