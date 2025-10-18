# 🔐 Настройка авторизации Flutter

## ✅ Что сделано

### Backend
- ✅ **API Gateway** настроен на порт `3011` с CORS для Flutter
- ✅ **Auth Service** (порт `3001`) проксируется через `/auth/*`
- ✅ **Vocabulary Service** (порт `3003`) проксируется через `/vocabulary/*`
- ✅ JWT авторизация настроена глобально
- ✅ Endpoint'ы для speech recognition проксируются

### Flutter
- ✅ Модель `User` и `AuthResponse`
- ✅ `ApiService` с поддержкой JWT токенов
- ✅ `AuthProvider` для state management
- ✅ Автоматическое сохранение токенов в `SharedPreferences`
- ✅ Автоматический refresh токена при 401
- ✅ Экраны **Login** и **Register**
- ✅ **Splash Screen** с проверкой авторизации
- ✅ Защищенные маршруты (redirect при отсутствии токена)
- ✅ Кнопка выхода в главном меню

## 🚀 Запуск

### 1. Запустите Backend сервисы

**В PowerShell (из корня проекта):**

```powershell
# Terminal 1: API Gateway (порт 3011)
cd services/api-gateway
npm run start:dev

# Terminal 2: Auth Service (порт 3001)
cd services/auth-service
npm run start:dev

# Terminal 3: Vocabulary Service (порт 3003)
cd services/vocabulary-service
npm run start:dev
```

**Проверьте, что сервисы запущены:**
- API Gateway: http://localhost:3011
- Auth Service: http://localhost:3001
- Vocabulary Service: http://localhost:3003

### 2. Запустите Flutter приложение

```powershell
cd mobile_app_flutter
flutter run -d chrome
```

Или используйте скрипт:
```powershell
.\run.ps1
```

## 📱 Использование

### Первый запуск
1. Приложение откроется на **Splash Screen**
2. Автоматически проверится наличие токена
3. Если токена нет → перенаправление на экран **Login**

### Регистрация
1. На экране Login нажмите **"Inscription"**
2. Заполните форму:
   - **Prénom** (имя)
   - **Nom** (фамилия)
   - **Email**
   - **Mot de passe** (минимум 6 символов)
   - **Confirmer le mot de passe**
3. Нажмите **"S'inscrire"**
4. Токены автоматически сохранятся
5. Перенаправление на главный экран

### Вход
1. На экране Login введите:
   - **Email**
   - **Mot de passe**
2. Нажмите **"Se connecter"**
3. Токены автоматически сохранятся
4. Перенаправление на главный экран

### Автоматический вход
- При следующем запуске приложения токен загрузится автоматически
- Если токен валиден → сразу главный экран
- Если токен истек → автоматический refresh
- Если refresh не удался → перенаправление на Login

### Выход
- В правом верхнем углу главного экрана нажмите иконку **🚪 Logout**
- Токены удалятся
- Перенаправление на экран Login

## 🔑 Структура токенов

### Access Token
- Время жизни: **15 минут** (настраивается в auth-service)
- Используется для всех API запросов
- Автоматически добавляется в заголовок `Authorization: Bearer <token>`

### Refresh Token
- Время жизни: **7 дней** (настраивается в auth-service)
- Используется для обновления access токена
- Автоматически вызывается при получении 401 ошибки

### Хранение
- Токены хранятся в `SharedPreferences` (веб: localStorage)
- Ключи: `access_token`, `refresh_token`

## 🛡️ Защищенные маршруты

Все маршруты, кроме `/login`, `/register` и `/`, требуют авторизации:
- `/main` - Главный экран
- `/galaxies` - Список галактик
- `/galaxy/:name` - Список подтем
- `/vocabulary/:galaxy/:subtopic` - Словарь
- `/word/:id` - Детали слова

При попытке доступа без токена → автоматический redirect на `/login`.

## 🔧 API Endpoints (через Gateway)

### Auth
- `POST /auth/register` - Регистрация
- `POST /auth/login` - Вход
- `POST /auth/refresh-token` - Обновление токена
- `GET /auth/profile` - Профиль пользователя (требует JWT)

### Vocabulary
- `GET /vocabulary/lexicon?galaxy=X&subtopic=Y` - Получить слова (требует JWT)
- `POST /vocabulary/lexicon` - Добавить слово (требует JWT)
- `POST /vocabulary/speech/recognize` - Распознать речь (требует JWT)

## 🐛 Troubleshooting

### "Ошибка входа" / "Utilisateur non trouvé"
- Проверьте, что auth-service запущен на порту 3001
- Проверьте, что api-gateway запущен на порту 3011
- Проверьте в консоли браузера (DevTools → Console) ошибки

### "Ошибка загрузки словаря" / 401 Unauthorized
- Проверьте, что vocabulary-service запущен на порту 3003
- Проверьте, что вы авторизованы (токен в localStorage)
- Попробуйте выйти и войти снова

### "Failed to load resource: net::ERR_CONNECTION_REFUSED"
- Убедитесь, что все 3 сервиса запущены:
  ```powershell
  # Проверка портов
  netstat -ano | findstr "3001 3003 3011"
  ```

### Токен не сохраняется / постоянно logout
- Откройте DevTools → Application → Local Storage
- Проверьте наличие `access_token` и `refresh_token`
- Если их нет, проверьте консоль на ошибки при login

## 📊 Структура проекта

```
mobile_app_flutter/
├── lib/
│   ├── models/
│   │   ├── user.dart             ← User, AuthResponse модели
│   │   ├── word.dart
│   │   └── galaxy.dart
│   ├── services/
│   │   └── api_service.dart      ← API клиент с JWT
│   ├── providers/
│   │   ├── auth_provider.dart    ← State management для авторизации
│   │   ├── vocabulary_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── main_screen.dart
│   │   ├── galaxy_selection_screen.dart
│   │   ├── subtopic_selection_screen.dart
│   │   └── vocabulary_screen.dart
│   └── main.dart                 ← Router с auth guards
└── AUTH_SETUP.md                 ← Этот файл
```

## ✨ Следующие шаги

- [ ] Добавить "Забыли пароль?"
- [ ] Добавить подтверждение email
- [ ] Добавить профиль пользователя
- [ ] Добавить изменение пароля
- [ ] Добавить социальные логины (Google, etc.)

