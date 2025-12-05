# 🔐 إعداد Google OAuth للتطبيق

## المشكلة
الخطأ: `com.google.android.gms.common.api.ApiException: 10`
**المعنى**: Missing or Invalid OAuth Configuration

## ✅ الحل الكامل

### 1️⃣ احصل على SHA-1 Fingerprint

شغّل في Terminal:

```bash
cd c:\Users\NAZER\Desktop\EduVerse\ui\android
gradlew signingReport
```

**النتيجة المتوقعة:**
```
Variant: debugAndroidTest
Config: debug
Store: C:\Users\NAZER\.android\debug.keystore
Alias: AndroidDebugKey
MD5: ...
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90
SHA-256: ...
```

✅ **انسخ الـ SHA1 value بدون النقاط** (AB CD EF... → ABCDEF...)
أو انسخه كما هو مع النقاط - Google يقبل الاثنين

---

### 2️⃣ إنشاء Google Cloud Project

#### أ) اذهب إلى Google Cloud Console
https://console.cloud.google.com

#### ب) إنشاء Project جديد
- اضغط على dropdown بجانب "Google Cloud" في الأعلى
- اختر "NEW PROJECT"
- اسم المشروع: `EduVerse`
- اضغط "CREATE"

#### ج) تفعيل Google Drive API
- اذهب إلى "APIs & Services" → "Library"
- ابحث عن "Google Drive API"
- اختره واضغط "ENABLE"

---

### 3️⃣ إنشاء OAuth Consent Screen

- اذهب إلى "APIs & Services" → "OAuth consent screen"
- اختر **External** → "CREATE"
- ملأ النموذج:
  - **App name**: EduVerse
  - **User support email**: your-email@gmail.com
  - **Developer contact**: your-email@gmail.com
- اضغط "SAVE AND CONTINUE"
- في الـ scopes: اختر الـ scopes التالية:
  ```
  https://www.googleapis.com/auth/drive.file
  https://www.googleapis.com/auth/drive
  ```
- اضغط "SAVE AND CONTINUE" → "SAVE AND CONTINUE" مجدداً

---

### 4️⃣ إنشاء OAuth 2.0 Client ID

- اذهب إلى "APIs & Services" → "Credentials"
- اضغط "+ CREATE CREDENTIALS" → "OAuth 2.0 Client ID"
- اختر "Android"
- ملأ النموذج:
  - **Name**: Android Client
  - **Package name**: `com.example.ui`
  - **SHA-1 certificate fingerprint**: (الذي حصلت عليه من الخطوة 1)
- اضغط "CREATE"

✅ **انسخ الـ Client ID الذي ظهر** (يبدأ بـ مثلاً: `1234567890-abcdefghijk.apps.googleusercontent.com`)

---

### 5️⃣ أضفِ Client ID في التطبيق

افتح ملف `lib/services/google_drive_service.dart`:

```dart
class GoogleDriveService {
  // استبدل YOUR_CLIENT_ID بـ Client ID من الخطوة السابقة
  static const String clientId = '1234567890-abcdefghijk.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive',
    ],
  );
  // ... الباقي
}
```

---

### 6️⃣ تنظيف البيانات المخزنة

شغّل:

```bash
flutter clean
flutter pub get
```

---

### 7️⃣ أعد بناء التطبيق

```bash
flutter run
```

---

## ✨ اختبار الإعداد

1. اذهب إلى صفحة SignUp
2. ملأ البيانات: username, email, fullName, password, role
3. اضغط "Continue"
4. اختر صورة
5. اضغط "Start"
6. **يجب أن تظهر شاشة Google Sign-In** ✅
7. سجّل دخول بحسابك على Google
8. يجب أن تكون الصورة ترفع بنجاح! 🎉

---

## 🐛 استكشاف الأخطاء

### الخطأ: "Error 10"
**السبب**: Client ID غير صحيح أو SHA-1 غير متطابق
**الحل**: تحقق من SHA-1 و Client ID مرة أخرى

### الخطأ: "sign_in_cancelled"
**السبب**: قفلت نافذة Google Sign-In
**الحل**: حاول مجدداً

### الخطأ: "Permission denied"
**السبب**: لم تعطِ الـ permissions المطلوبة
**الحل**: في نافذة Google Sign-In، اختر "Allow"

### الخطأ: "Invalid OAuth client"
**السبب**: قد يكون المشروع لم يحفظ OAuth Consent Screen بشكل صحيح
**الحل**: امسح المشروع وأعد إنشاء واحد جديد

---

## 📝 تفاصيل إضافية

### Package Name
- تطبيقك: `com.example.ui`
- يجب أن يطابق ما في `android/app/build.gradle.kts`:
```gradle
applicationId = "com.example.ui"
```

### SHA-1 Fingerprint
- الـ debug keystore مسار ثابت: `C:\Users\NAZER\.android\debug.keystore`
- الـ release keystore يكون في مكان آخر إذا حققت الـ build

### التطبيق مستقر الآن
بعد إكمال هذه الخطوات، لن تحصل على أي أخطاء OAuth! ✅

---

## 🚀 التالي

بعد نجاح الإعداد:
1. اختبر الـ flow الكامل (SignUp → Photo Upload → Registration)
2. تحقق من أن الـ email confirmation يصل
3. جرّب تسجيل الدخول بـ email و password الجديد
