# ðŸš€ QualifAI Flutter â€” Complete New Chat Brief
> Ø§Ù„Ù€ brief Ø§Ù„ÙƒØ§Ù…Ù„ Ù„Ù„Ø¨Ø¯Ø¡ ÙÙŠ Ø´Ø§Øª Ø¬Ø¯ÙŠØ¯ Ù†Ø¸ÙŠÙ

---

## ðŸ”— Ø§Ù„Ø±ÙˆØ§Ø¨Ø·

| Ø§Ù„Ù…ÙˆØ±Ø¯ | Ø§Ù„Ø±Ø§Ø¨Ø· |
|--------|--------|
| **GitHub (NEW)** | Ø³ÙŠÙÙ†Ø´Ø£ repo Ø¬Ø¯ÙŠØ¯ |
| **GitHub (OLD/reference)** | https://github.com/abdoRashed22/QualifAI.git |
| **API Base URL** | https://qualefai.runasp.net/api |
| **Swagger** | https://qualefai.runasp.net/swagger/index.html |
| **Figma Design** | https://www.figma.com/design/2v0cElubrU8aS84xSXxwvQ/QualifAi |
| **Figma Prototype** | https://www.figma.com/proto/2v0cElubrU8aS84xSXxwvQ/QualifAi?node-id=0-1 |

## ðŸ”‘ Test Account
- Email: abdo@gmail.com
- Password: 123123

---

## âš™ï¸ Ø§Ù„Ù‚Ø±Ø§Ø±Ø§Øª Ø§Ù„ØªÙ‚Ù†ÙŠØ© Ø§Ù„Ù†Ù‡Ø§Ø¦ÙŠØ© (Ù„Ø§ ØªØªØºÙŠØ±)

| | |
|--|--|
| Architecture | MVVM + Cubit/BLoC |
| Navigation | go_router Ù…Ø¹ role-based guards |
| DI | get_it |
| State | flutter_bloc (Cubit) |
| Backend | REST API ÙÙ‚Ø· |
| Local DB | hive_flutter |
| Notifications | Polling 30s |
| Font | google_fonts (Cairo) â€” Ù„Ø§ files Ù…Ø­Ù„ÙŠØ© |
| Theme | Dark/Light toggle |
| Locale | AR (RTL) / EN |
| Platform | Android 12+ (API 31) |
| ScreenUtil | designSize: 390Ã—844 |

---

## ðŸ› Ø§Ù„Ù…Ø´Ø§ÙƒÙ„ Ø§Ù„Ù…Ø­Ù„ÙˆÙ„Ø©

### âœ… 1. Arabic Text Garbled (SnackBar / Responses)
**Ø§Ù„Ø³Ø¨Ø¨:** Dio ÙŠÙ‚Ø±Ø£ bytes Ø¨Ù€ Latin-1 Ø§ÙØªØ±Ø§Ø¶ÙŠØ§Ù‹
**Ø§Ù„Ø­Ù„:** `responseType: ResponseType.bytes` + `_Utf8DecoderInterceptor`

```dart
// ÙÙŠ DioClient:
BaseOptions(responseType: ResponseType.bytes, ...)

// Interceptor ÙŠØ¹Ù…Ù„ UTF-8 decode:
class _Utf8DecoderInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is List<int>) {
      final decoded = utf8.decode(response.data as List<int>, allowMalformed: true);
      try { response.data = jsonDecode(decoded); } catch (_) { response.data = decoded; }
    }
    handler.next(response);
  }
}
```

### âœ… 2. Cairo Font Not Loading
**Ø§Ù„Ø³Ø¨Ø¨:** Ù…Ù„ÙØ§Øª Ø§Ù„Ù€ font Ù…Ø´ Ù…ÙˆØ¬ÙˆØ¯Ø© ÙÙŠ assets
**Ø§Ù„Ø­Ù„:** Ø§Ø³ØªØ®Ø¯Ø§Ù… `google_fonts: ^6.2.1` Ø¨Ø¯Ù„ local files
```dart
import 'package:google_fonts/google_fonts.dart';
textStyle: GoogleFonts.cairo(fontSize: 14)
// Ø£Ùˆ Ù„Ù„Ù€ TextTheme ÙƒÙ„Ù‡:
textTheme: GoogleFonts.cairoTextTheme(base.textTheme)
```

### âœ… 3. POST /Employee â†’ 500
**Ø§Ù„Ø³Ø¨Ø¨:** Backend errorØŒ Ù…Ø´ Flutter
**Ø§Ù„Ø­Ù„:** Ø§Ø³ØªØ®Ø¯Ø§Ù… roleId Ø­Ù‚ÙŠÙ‚ÙŠ Ù…Ù† GET /Roles

### âš ï¸ 4. Login Response Structure (Unknown)
Ù„Ù…Ø§ ØªØ¹Ù…Ù„ login Ù†Ø§Ø¬Ø­ØŒ Ø§Ù„Ù€ API response structure Ù…Ø´ Ù…ÙˆØ«Ù‚ ÙÙŠ Swagger.
ÙÙŠ `auth_remote_ds.dart` Ø¹Ù…Ù„ flexible parsing:
```dart
factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
  return LoginResponseModel(
    token: json['token'] ?? json['accessToken'] ?? json['jwt'] ?? '',
    firstName: json['firstName'] ?? json['first_name'] ?? '',
    lastName: json['lastName'] ?? json['last_name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? json['roles']?[0] ?? json['userRole'] ?? 'quality_employee',
  );
}
```

---

## ðŸ“ Folder Structure Ø§Ù„ÙƒØ§Ù…Ù„Ø©

```
qualif_ai/
â”œâ”€â”€ lib/
â”‚   â”œâ”€â”€ main.dart
â”‚   â”œâ”€â”€ core/
â”‚   â”‚   â”œâ”€â”€ api/
â”‚   â”‚   â”‚   â”œâ”€â”€ api_endpoints.dart
â”‚   â”‚   â”‚   â””â”€â”€ dio_client.dart          â† UTF-8 fix Ù‡Ù†Ø§
â”‚   â”‚   â”œâ”€â”€ cache/
â”‚   â”‚   â”‚   â””â”€â”€ hive_cache.dart
â”‚   â”‚   â”œâ”€â”€ di/
â”‚   â”‚   â”‚   â””â”€â”€ injection.dart
â”‚   â”‚   â”œâ”€â”€ errors/
â”‚   â”‚   â”‚   â””â”€â”€ failures.dart
â”‚   â”‚   â”œâ”€â”€ localization/
â”‚   â”‚   â”‚   â”œâ”€â”€ app_strings.dart
â”‚   â”‚   â”‚   â””â”€â”€ locale_cubit.dart
â”‚   â”‚   â”œâ”€â”€ router/
â”‚   â”‚   â”‚   â””â”€â”€ app_router.dart
â”‚   â”‚   â””â”€â”€ theme/
â”‚   â”‚       â”œâ”€â”€ app_colors.dart
â”‚   â”‚       â”œâ”€â”€ app_theme.dart           â† google_fonts fix Ù‡Ù†Ø§
â”‚   â”‚       â””â”€â”€ theme_cubit.dart
â”‚   â”‚
â”‚   â”œâ”€â”€ features/
â”‚   â”‚   â”œâ”€â”€ auth/
â”‚   â”‚   â”‚   â”œâ”€â”€ data/models/auth_model.dart
â”‚   â”‚   â”‚   â”œâ”€â”€ data/remote/auth_remote_ds.dart
â”‚   â”‚   â”‚   â”œâ”€â”€ domain/repositories/auth_repository.dart
â”‚   â”‚   â”‚   â”œâ”€â”€ repository/auth_repository_impl.dart
â”‚   â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â”‚   â”‚       â”œâ”€â”€ cubit/auth_cubit.dart + auth_state.dart
â”‚   â”‚   â”‚       â””â”€â”€ screens/splash_screen.dart + login_screen.dart + forgot_password_screen.dart
â”‚   â”‚   â”‚
â”‚   â”‚   â”œâ”€â”€ dashboard/         â† DashboardCubit + DashboardScreen (charts)
â”‚   â”‚   â”œâ”€â”€ accreditation/     â† 5 screens: Types, Standards, Detail, Upload, AI
â”‚   â”‚   â”œâ”€â”€ chat/              â† ChatList + ChatScreen (polling 10s)
â”‚   â”‚   â”œâ”€â”€ deadlines/         â† DeadlinesScreen (filter tabs)
â”‚   â”‚   â”œâ”€â”€ notifications/     â† NotificationsScreen (polling 30s)
â”‚   â”‚   â”œâ”€â”€ profile/           â† ProfileScreen (settings + theme + lang)
â”‚   â”‚   â”œâ”€â”€ reports/           â† ReportsList + ReportDetail
â”‚   â”‚   â””â”€â”€ admin/             â† AdminDashboard + 5 admin screens
â”‚   â”‚
â”‚   â””â”€â”€ shared/
â”‚       â””â”€â”€ widgets/
â”‚           â”œâ”€â”€ main_scaffold.dart       â† Bottom nav (user + admin)
â”‚           â”œâ”€â”€ app_button.dart
â”‚           â”œâ”€â”€ app_text_field.dart
â”‚           â”œâ”€â”€ app_card.dart            â† AppCard + AppBadge + AppProgressBar + ...
â”‚           â””â”€â”€ app_badge.dart           â† re-export
â”‚
â”œâ”€â”€ android/
â”‚   â””â”€â”€ app/src/main/
â”‚       â”œâ”€â”€ AndroidManifest.xml          â† INTERNET + FILE permissions
â”‚       â””â”€â”€ res/xml/file_paths.xml
â”‚
â”œâ”€â”€ assets/
â”‚   â”œâ”€â”€ images/
â”‚   â””â”€â”€ icons/
â”‚
â””â”€â”€ pubspec.yaml                         â† google_fonts added, no local fonts
```

---

## ðŸ‘¥ User Roles (Ù…Ù† JWT)

| Role String | Ø§Ù„ØµÙØ­Ø© Ø¨Ø¹Ø¯ Login |
|-------------|-----------------|
| `system_admin` | /admin (AdminDashboard) |
| `quality_manager` | /dashboard |
| `quality_employee` | /dashboard |
| `reviewer` | /reports |

---

## ðŸ“± Ø§Ù„Ù€ 21 Screen

### Auth (3)
- SplashScreen â€” auto-navigate Ø¨Ø¹Ø¯ 2s
- LoginScreen â€” email + password + BLoC
- ForgotPasswordScreen

### Main App (13)
- DashboardScreen â€” stats + bar chart
- AccreditationTypesScreen â€” Academic / Programmatic
- StandardsListScreen â€” 7 Ù…Ø¹Ø§ÙŠÙŠØ± + progress bars
- StandardDetailScreen â€” files list + deadline dialog
- FileUploadScreen â€” drag/drop + PDF/Word
- AiAnalysisScreen â€” score circle + recommendations
- ReportsListScreen
- ReportDetailScreen â€” gap analysis + send button
- DeadlinesScreen â€” filter tabs
- NotificationsScreen â€” polling
- ChatListScreen
- ChatScreen â€” messages + polling
- ProfileScreen â€” edit + dark/light + AR/EN

### Admin (5)
- AdminDashboardScreen â€” grid menu
- EmployeesScreen â€” CRUD
- RolesScreen â€” CRUD + permissions
- CollegesScreen
- PricingScreen â€” plans cards
- ActivityLogScreen

---

## ðŸŒ API Endpoints

```
BASE: https://qualefai.runasp.net/api

Auth:
  POST /Auth/login              {email, password}
  POST /Auth/forgot-password    {email}

Profile:
  GET  /Profile
  PUT  /Profile/update          {email, firstName, lastName}
  PUT  /Profile/update-password {oldPassword, newPassword}
  POST /Profile/upload-photo    multipart: file
  DELETE /Profile/delete-photo

Accreditation:
  GET  /Accreditation/sections
  GET  /Accreditation/sections/{id}
  POST /Accreditation/documents/{id}/upload         multipart: File
  POST /Accreditation/documents/{id}/set-deadline   {deadline, reminders:{oneWeekBefore,oneDayBefore,onDueDate}}
  GET  /Accreditation/deadlines

Notifications:
  GET  /Notification
  GET  /Notification/unread-count
  PUT  /Notification/mark-all-read

Chat:
  GET  /Chat/colleges
  GET  /Chat/{collegeId}/messages
  POST /Chat/send               {content, collegeId, receiverId?}
  GET  /Chat/unread

Admin â€” Employee:
  GET    /Employee
  POST   /Employee              {firstName, lastName, email, password, roleId}
  GET    /Employee/{id}
  PUT    /Employee/{id}         {employeeId, firstName, lastName, email, password, roleId}
  DELETE /Employee/{id}

Admin â€” Roles:
  GET    /Roles
  POST   /Roles                 {roleName, description}
  GET    /Roles/{id}
  DELETE /Roles/{id}
  GET    /Roles/{id}/permissions
  POST   /Roles/{id}/permissions  [permId1, permId2, ...]

Admin â€” Colleges:
  GET    /Colleges
  POST   /Colleges              multipart: UniversityName, CollegeName, InstitutionType, AccreditationType, SubscriptionStartDate, ManagerEmail, ManagerPassword, Image
  GET    /Colleges/{id}
  PUT    /Colleges/{id}
  DELETE /Colleges/{id}

Admin â€” Plans:
  GET    /Plan
  POST   /Plan                  {name, price, description, features[]}
  GET    /Plan/{id}
  PUT    /Plan/{id}
  DELETE /Plan/{id}

Admin â€” Other:
  GET  /Permissions
  GET  /ActivityLog
  GET  /Pricing
  POST /Pricing/subscribe       {cardHolderName, cardNumber, cvv, expiryDate, rememberCardInfo}
  GET  /Subscription
  GET  /Subscription/college/{id}
  PUT  /Subscription/{id}
  PUT  /Subscription/suspend/{id}
  PUT  /Subscription/activate/{id}
  POST /AdminNotification/send  {collegeId, title, message, scheduledAt}
  POST /Support/submit          {name, email, message}
  GET  /Enum/institution-types
  GET  /Enum/accreditation-types
```

---

## ðŸ“¦ pubspec.yaml Key Dependencies

```yaml
flutter_bloc: ^8.1.6
equatable: ^2.0.5
go_router: ^14.2.0
dio: ^5.7.0
pretty_dio_logger: ^1.4.0
get_it: ^8.0.2
hive_flutter: ^1.1.0
freezed_annotation: ^2.4.4
json_annotation: ^4.9.0
dartz: ^0.10.1
flutter_screenutil: ^5.9.3
cached_network_image: ^3.4.1
fl_chart: ^0.69.0
google_fonts: ^6.2.1        # â† Cairo font, no local files
file_picker: ^8.1.2
permission_handler: ^11.3.1
intl: ^0.19.0
connectivity_plus: ^6.0.5
jwt_decoder: ^2.0.1
image_picker: ^1.1.2
```

---

## ðŸŽ¨ Design Colors (Ù…Ù† Ø§Ù„Ù€ Figma)

```dart
// Primary
static const navyBlue = Color(0xFF1B2B5E);
static const blue     = Color(0xFF2B4EAE);
static const cyan     = Color(0xFF00C2FF);

// Background Light
static const bgLight  = Color(0xFFF4F6FA);
static const white    = Color(0xFFFFFFFF);
static const borderLight = Color(0xFFE0E4EF);

// Background Dark
static const bgDark      = Color(0xFF0F1626);
static const surfaceDark = Color(0xFF1A2540);

// Status
static const success = Color(0xFF27AE60);
static const warning = Color(0xFFF39C12);
static const error   = Color(0xFFE74C3C);
```

---

## ðŸ”§ Ù…Ø§ ÙŠØ¬Ø¨ Ø¹Ù…Ù„Ù‡ ÙÙŠ Ø§Ù„Ø´Ø§Øª Ø§Ù„Ø¬Ø¯ÙŠØ¯

### Priority 1 â€” Ø§Ù„Ø£Ù‡Ù…
1. **ØªØ·Ø¨ÙŠÙ‚ Ø§Ù„Ù€ Figma design Ø¹Ù„Ù‰ ÙƒÙ„ screen** â€” Ø§Ù„Ù€ design Ø§Ù„Ø­Ø§Ù„ÙŠ Ø¨Ø³ÙŠØ· Ø¬Ø¯Ø§Ù‹ Ù…Ù‚Ø§Ø±Ù†Ø© Ø¨Ø§Ù„Ù€ Figma
2. **Ø§Ø®ØªØ¨Ø§Ø± login flow** Ù…Ø¹ account: abdo@gmail.com / 123123
3. **Ø§Ù„ØªØ£ÙƒØ¯ Ù…Ù† UTF-8 fix** ÙŠØ¹Ù…Ù„ ØµØ­

### Priority 2
4. **Ø¥Ø¶Ø§ÙØ© loading shimmer** Ø¨Ø¯Ù„ progress indicators
5. **Error states** Ø£Ø­Ø³Ù† ØªØµÙ…ÙŠÙ…Ø§Ù‹
6. **Empty states** Ù…Ø¹ illustrations

### Priority 3
7. **Support screen** (POST /Support/submit)
8. **Subscription screen** Ù„Ù„Ù€ college manager
9. **Notifications send** Ù„Ù„Ù€ admin

---

## ðŸ“‹ Prompt Ù„Ù„Ø´Ø§Øª Ø§Ù„Ø¬Ø¯ÙŠØ¯

```
Ø£Ù†Ø§ Ø´Ø§ØºÙ„ Ù…Ø´Ø±ÙˆØ¹ ØªØ®Ø±Ø¬ Flutter â€” QualifAI

ðŸ“Œ Ø§Ù„Ø¨Ø±ÙŠÙ Ø§Ù„ÙƒØ§Ù…Ù„ ÙÙŠ Ø§Ù„Ù€ repo Ø§Ù„Ù‚Ø¯ÙŠÙ…:
https://github.com/abdoRashed22/QualifAI.git
(Ø§Ù‚Ø±Ø£ PROJECT_BRIEF.md Ùˆ NEW_CHAT_BRIEF.md)

ðŸ”‘ Test account: abdo@gmail.com / 123123
ðŸŒ API: https://qualefai.runasp.net/api
ðŸŽ¨ Figma: https://www.figma.com/design/2v0cElubrU8aS84xSXxwvQ/QualifAi

Ø§Ù„Ù…Ø´Ø±ÙˆØ¹ Ø¹Ù†Ø¯Ù‡ ÙƒÙˆØ¯ ÙƒØ§Ù…Ù„ØŒ Ø¨Ø³ Ù…Ø­ØªØ§Ø¬:
1. ØªØ·Ø¨ÙŠÙ‚ Ø§Ù„Ù€ Figma design Ø§Ù„ØµØ­ Ø¹Ù„Ù‰ Ø§Ù„Ù€ screens
2. Ø§Ù„ØªØ£ÙƒØ¯ Ù…Ù† UTF-8 fix Ø´ØºØ§Ù„ (dio responseType: bytes + interceptor)
3. google_fonts Cairo Ø¨Ø¯Ù„ local font files

Architecture: MVVM + Cubit | go_router | get_it | hive | dio
Platform: Android 12+ | designSize: 390x844 | Arabic RTL

Ø§Ø¨Ø¯Ø£ Ø¨Ù€ login screen ÙˆØªØ£ÙƒØ¯ Ø¥Ù†Ù‡ ÙŠØ´ØªØºÙ„ Ù…Ø¹ Ø§Ù„Ù€ API.
```

---
*Updated: April 2026*
