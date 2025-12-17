# 💡 أمثلة عملية للتحسينات المقترحة

## 1. إضافة Semantics للـ Accessibility

### قبل التحسين:
```dart
ElevatedButton(
  onPressed: () => _submitForm(),
  child: Text('Submit'),
)
```

### بعد التحسين:
```dart
Semantics(
  label: 'Submit refund request button',
  hint: 'Double tap to submit your refund request',
  button: true,
  child: ElevatedButton(
    onPressed: () => _submitForm(),
    child: Text('Submit'),
  ),
)
```

---

## 2. تحسين Error Handling

### قبل التحسين:
```dart
try {
  final result = await apiService.getData();
} catch (e) {
  showSnackBar('Error occurred');
}
```

### بعد التحسين:
```dart
try {
  final result = await apiService.getData();
} catch (e) {
  AppErrorHandler.handleError(
    context,
    e,
    onRetry: () => _loadData(),
  );
}
```

---

## 3. إضافة Certificate Pinning

### إضافة في `dio_factory.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

class DioFactory {
  static Dio createDio() {
    final dio = Dio();
    
    // Certificate Pinning
    dio.httpClientAdapter = CertificatePinningAdapter(
      allowedSHAFingerprints: [
        'YOUR_CERTIFICATE_SHA256_FINGERPRINT',
      ],
      validateHost: true,
    );
    
    return dio;
  }
}
```

---

## 4. تحسين Validation

### قبل التحسين:
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }
  if (value.length < 8) {
    return 'Too short';
  }
  return null;
}
```

### بعد التحسين:
```dart
// في ملف validators.dart
class Validators {
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }
  
  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.length < min) {
      return message ?? 'Minimum length is $min characters';
    }
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }
}

// الاستخدام
validator: (value) => Validators.required(value) ?? 
                     Validators.minLength(value, 8),
```

---

## 5. إضافة Performance Monitoring

### في `api_service.dart`:
```dart
import 'package:firebase_performance/firebase_performance.dart';

class ApiService {
  Future<Response> get(String endpoint) async {
    final trace = FirebasePerformance.instance.newTrace('api_$endpoint');
    await trace.start();
    
    try {
      final response = await dio.get(endpoint);
      await trace.stop();
      return response;
    } catch (e) {
      trace.putAttribute('error', e.toString());
      await trace.stop();
      rethrow;
    }
  }
}
```

---

## 6. تحسين Image Loading

### قبل التحسين:
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
)
```

### بعد التحسين:
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  // تحسين الذاكرة
  memCacheWidth: 300,
  memCacheHeight: 300,
  maxWidthDiskCache: 300,
  maxHeightDiskCache: 300,
  // Placeholder محسّن
  placeholder: (context, url) => ImageShimmer(
    width: 300,
    height: 300,
  ),
  // Error handling محسّن
  errorWidget: (context, url, error) => Icon(
    Icons.error_outline,
    size: 50,
    color: AppColors.errorClr,
  ),
)
```

---

## 7. إضافة Widget Tests

### مثال: Test للـ Login Form
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconsult/features/auth/login/presentation/login_screen.dart';

void main() {
  testWidgets('Login form validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );
    
    // Find submit button
    final submitButton = find.text('Login');
    expect(submitButton, findsOneWidget);
    
    // Tap submit without filling fields
    await tester.tap(submitButton);
    await tester.pump();
    
    // Check for error messages
    expect(find.text('Card number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
  
  testWidgets('Login form accepts valid input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );
    
    // Fill form
    await tester.enterText(find.byKey(Key('card_number')), '123456789');
    await tester.enterText(find.byKey(Key('password')), 'password123');
    
    // Tap submit
    await tester.tap(find.text('Login'));
    await tester.pump();
    
    // Check no error messages
    expect(find.text('Card number is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });
}
```

---

## 8. إضافة Focus Management

### في Forms:
```dart
class RefundRequestScreen extends StatefulWidget {
  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();
  
  @override
  void dispose() {
    _dateFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            focusNode: _dateFocusNode,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_noteFocusNode);
            },
            // ...
          ),
          TextFormField(
            focusNode: _noteFocusNode,
            // ...
          ),
        ],
      ),
    );
  }
}
```

---

## 9. تحسين Offline Handling

### في Repository:
```dart
class HomeRepository {
  Future<ApiResult<HomeResponse>> getHomeInfo(String lang) async {
    try {
      // محاولة جلب البيانات من API
      final response = await _apiService.getHomeInfo(lang);
      
      // حفظ في Cache عند النجاح
      await CacheService.cacheHomeData(response);
      
      return ApiResult.success(response);
    } on DioException catch (e) {
      // في حالة عدم وجود إنترنت
      if (e.type == DioExceptionType.connectionError) {
        // محاولة جلب من Cache
        final cachedData = await CacheService.getCachedHomeData();
        if (cachedData != null) {
          return ApiResult.success(cachedData);
        }
      }
      
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

---

## 10. إضافة Dark Mode Support

### في `app_theme.dart`:
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryClr,
      // ...
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryClrDark,
      scaffoldBackgroundColor: Colors.grey[900],
      // ...
    );
  }
}
```

### في `main.dart`:
```dart
class MediConsultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // يتبع إعدادات النظام
      // ...
    );
  }
}
```

---

## 11. تحسين Logging

### إنشاء Logger Service:
```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    
    // إرسال للـ Crashlytics أيضاً
    FirebaseCrashlyticsService.instance.recordError(
      exception: error ?? message,
      stackTrace: stackTrace ?? StackTrace.current,
      reason: message,
    );
  }
}
```

---

## 12. إضافة Retry Logic محسّن

### في `retry_interceptor.dart`:
```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  
  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        await Future.delayed(retryDelay);
        
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }
    
    handler.reject(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}
```

---

## 13. تحسين Cache Management

### إضافة Cache Expiry:
```dart
class CacheService {
  static const int _defaultExpiryHours = 1;
  
  static Future<void> cacheHomeData(
    HomeResponse data, {
    int expiryHours = _defaultExpiryHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    
    await prefs.setString('home_data', jsonString);
    await prefs.setInt('home_data_expiry', 
      DateTime.now().add(Duration(hours: expiryHours)).millisecondsSinceEpoch,
    );
  }
  
  static Future<HomeResponse?> getCachedHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('home_data');
    final expiry = prefs.getInt('home_data_expiry');
    
    if (jsonString == null || expiry == null) {
      return null;
    }
    
    // Check if expired
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await clearHomeCache();
      return null;
    }
    
    try {
      final jsonData = jsonDecode(jsonString);
      return HomeResponse.fromJson(jsonData);
    } catch (e) {
      await clearHomeCache();
      return null;
    }
  }
}
```

---

## 14. إضافة Analytics Events

### في `analytics_service.dart`:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  // Events محددّة
  static Future<void> logLogin({required String method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method},
    );
  }
  
  static Future<void> logRefundRequest({
    required String type,
    required double amount,
  }) async {
    await logEvent(
      name: 'refund_request',
      parameters: {
        'type': type,
        'amount': amount,
      },
    );
  }
}
```

---

## 15. تحسين Build Configuration

### في `android/app/build.gradle.kts`:
```kotlin
android {
    buildTypes {
        release {
            // Enable ProGuard
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard rules
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Signing config
            signingConfig = signingConfigs.getByName("release")
        }
    }
    
    // Build optimizations
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
}
```

---

## 📝 ملاحظات

- هذه الأمثلة قابلة للتطبيق مباشرة
- يجب تعديلها حسب احتياجات المشروع
- يجب اختبار كل تحسين قبل تطبيقه في Production
- يجب مراجعة الكود مع الفريق قبل الـ Merge

---

**آخر تحديث**: ديسمبر 2024

