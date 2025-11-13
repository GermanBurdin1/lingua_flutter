# Скрипт для запуска Flutter приложения
# Обновляем PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Запускаем приложение
flutter run -d chrome








