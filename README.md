# SonarQube 9.9.8 с Community Branch Plugin

Этот проект содержит конфигурацию SonarQube 9.9.8 Community Edition с установленным плагином sonarqube-community-branch-plugin.

## 📋 Версии компонентов

- **SonarQube**: 9.9.8-community (стабильная версия с конкретным тегом)
- **PostgreSQL**: 15.6 (последняя стабильная версия)
- **Community Branch Plugin**: 1.24.0 (совместимая версия для SonarQube 9.x)

## 📁 Файлы

- `docker_sonar.yml` - основная конфигурация для продакшена
- `docker_sonar_local.yml` - локальная версия для тестирования
- `Dockerfile.sonarqube` - Dockerfile для сборки образа с плагином
- `start_local.sh` - скрипт для запуска локальной версии
- `stop_local.sh` - скрипт для остановки локальной версии

## 🚀 Локальное тестирование

Для запуска локальной версии используйте удобные скрипты:

```bash
# Запуск
./start_local.sh

# Остановка
./stop_local.sh
```

Или вручную:

```bash
# Сборка и запуск
docker-compose -f docker_sonar_local.yml up --build

# Остановка
docker-compose -f docker_sonar_local.yml down
```

После запуска SonarQube будет доступен по адресу: http://localhost:9000

**Логин по умолчанию**: admin/admin

## 🏭 Продакшен

Для запуска в продакшене используйте `docker_sonar.yml`:

```bash
docker-compose -f docker_sonar.yml up --build
```

**Важно**: Перед запуском убедитесь, что директории для volumes существуют:
- `/var/storage/sonarqube/data/data/`
- `/var/storage/sonarqube/data/conf/`
- `/var/storage/sonarqube/data/logs/`
- `/var/storage/sonarqube/data/extensions/`
- `/var/storage/sonarqube/db/`

## 🔌 Плагин Community Branch

Плагин автоматически устанавливается при сборке образа и позволяет:
- Анализировать ветки и pull requests
- Создавать отдельные проекты для веток
- Интегрироваться с GitLab, GitHub, Bitbucket

## ✅ Проверка установки плагина

После запуска SonarQube:
1. Войдите в административную панель
2. Перейдите в Administration → Marketplace
3. Найдите "Community Branch Plugin" в списке установленных плагинов

## 📊 Логи

Для просмотра логов:

```bash
# Логи SonarQube
docker logs sonarqube-local

# Логи PostgreSQL
docker logs sonarqube-postgres-local
```

## 🔧 Преимущества использования конкретных тегов

- **Стабильность**: Избегаем неожиданных изменений при обновлении
- **Воспроизводимость**: Одинаковое поведение в разных средах
- **Безопасность**: Контролируем, какая именно версия используется
- **Отладка**: Легче найти и исправить проблемы

## 📈 Сравнение с latest

| Аспект | latest | 9.9.8-community |
|--------|--------|-----------------|
| Стабильность | ⚠️ Может меняться | ✅ Фиксированная |
| Размер образа | 1.22GB | 604MB |
| Совместимость | ⚠️ Может сломаться | ✅ Проверенная |
| Поддержка | ✅ Последние фичи | ✅ LTS поддержка |
