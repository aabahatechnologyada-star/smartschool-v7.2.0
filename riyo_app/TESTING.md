# Riyo App - Testing Guide

## Quick Start

### 1. Run Mock Backend (Terminal 1)
```bash
cd /tmp/smartschool/riyo_app
dart run test/mock_backend.dart
```
Runs on `http://localhost:8080` with all API endpoints.

### 2. Update App Config for Local Testing
Edit `lib/api_config.dart`:
```dart
static const String BASE_URL = 'http://10.0.2.2:8080';  // Android emulator
// or
static const String BASE_URL = 'http://localhost:8080';  // iOS simulator / web
```

### 3. Run App
```bash
flutter run -d <device_id>
```

### 4. Test Login
Use any non-empty credentials:
- Username: `student123`
- Password: `password123`

---

## Mock Backend Endpoints

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/riyo_api/login` | POST | No | Returns token + student profile |
| `/riyo_api/profile` | GET | Yes | Student info |
| `/riyo_api/notices` | GET | Yes | School notices |
| `/riyo_api/examresults` | GET | Yes | Exam results with subjects |
| `/riyo_api/dashboard` | GET | Yes | Dashboard stats |
| `/riyo_api/attendance` | GET | Yes | Monthly attendance |
| `/riyo_api/fees` | GET | Yes | Fee status & transactions |
| `/riyo_api/setup` | GET | No | App config |

---

## Running Tests

### Unit Tests
```bash
flutter test test/
```

### Integration Tests
```bash
flutter test integration_test/
```

### Mock Backend Tests
```bash
dart run test/mock_backend.dart
```

---

## CI Testing (GitHub Actions)

The workflow `.github/workflows/build_app.yml`:
1. Sets up Flutter 3.22
2. Generates platform dirs
3. Runs `flutter analyze`
4. Builds Android APK (multi-arch)
5. Builds iOS (unsigned)
6. Uploads artifacts

---

## Test Credentials

| Username | Password | Result |
|----------|----------|--------|
| any non-empty | any non-empty | ✅ Success |
| empty | any | ❌ 400 error |
| any | empty | ❌ 400 error |

---

## Manual E2E Test Checklist

- [ ] App launches → shows login screen
- [ ] Valid login → navigates to Home tab
- [ ] Home tab → loads notices + exam results
- [ ] Pull-to-refresh → reloads feed
- [ ] Search tab → search + explore tabs work
- [ ] Notifications tab → All/Mentions tabs
- [ ] Messages tab → conversation list
- [ ] Profile tab → stats, info, quick actions
- [ ] Bottom nav → switches tabs smoothly
- [ ] Logout → returns to login
- [ ] Token persists → auto-login on restart