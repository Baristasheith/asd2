# Ahmad Rest & Cafe — المرحلة 1 + 2

تطبيق مطعم فاخر (Flutter).

## المرحلة الأولى (Auth Flow)

1. ✅ Project setup (pubspec.yaml + بنية المجلدات Feature-Based)
2. ✅ Theme مركزي (ألوان، خطوط، ThemeData) — أسود / ذهبي / كريمي
3. ✅ Localization كامل (EN / AR / KU / DE) عبر `flutter_localizations` + `intl` + ملفات `.arb`
4. ✅ دعم RTL/LTR تلقائي عند تغيير اللغة (بدون إعادة تشغيل)
5. ✅ Splash Screen بأنيميشن Fade + Scale + خط ذهبي متحرك
6. ✅ Welcome Screen فاخر بأنيميشن متدرج (staggered) لكل عنصر + زر لغة سريع + Bottom Sheet لاختيار اللغة
7. ✅ Authentication UI: Login + Signup (بدون ربط فعلي بـ Google/Facebook/Backend بعد — هذا واجهات فقط)

## المرحلة الثانية (التنقل الرئيسي)

8. ✅ Bottom Navigation Bar فاخر مخصص (Home / Menu / Cart / Orders / Profile) مبني على `StatefulShellRoute` من go_router، يحافظ على حالة كل تبويب
9. ✅ Home Screen: ترحيب + Featured Dishes (سكرول أفقي) + Categories + Popular Now
10. ✅ Menu Screen: بحث + فلترة حسب التصنيف + شبكة أطباق (Grid)
11. ✅ Cart Screen: عناصر السلة + Stepper للكمية + ملخص السعر (Subtotal/Delivery/Total) + Checkout + حالة "سلة فارغة"
12. ✅ Orders Screen: سجل الطلبات بحالاته (Preparing/On the way/Delivered/Cancelled) + حالة "لا طلبات"
13. ✅ Profile Screen: صورة شخصية، بيانات المستخدم، روابط لـ Orders/Favorites/Settings/Help/Logout (مع تأكيد الخروج)
14. ✅ Settings Screen: يحوي **Language Selector** (البند رقم 8 من طلبك الأصلي) + إشعارات + رقم إصدار التطبيق
15. ✅ بعد نجاح تسجيل الدخول/إنشاء الحساب ينتقل المستخدم مباشرة إلى Home

> ملاحظة: كل بيانات الأطباق والطلبات في هذه المرحلة هي **بيانات وهمية (Mock)**
> داخل `lib/features/menu/data/mock_menu_data.dart` و
> `lib/features/orders/data/mock_orders_data.dart` لعرض التصميم فقط، بانتظار
> ربط Backend حقيقي لاحقًا. كذلك صور الأطباق حاليًا عبارة عن Placeholder
> أنيق (أيقونة على تدرج ذهبي غامق) بدل صور حقيقية — الودجت
> `DishImagePlaceholder` مصمم ليُستبدل لاحقًا بصورة حقيقية بدون تغيير أي Layout.

## المرحلة الثالثة (تفاصيل الطبق + المفضلة)

16. ✅ **Dish Details Screen**: صورة كبيرة، الاسم، السعر، الوصف، محدد الكمية، وزر "أضف إلى السلة" يعرض السعر الإجمالي مباشرة
17. ✅ زر **مفضلة (قلب)** متحرك على كل بطاقة طبق (Home/Menu) وفي شاشة التفاصيل، مرتبط بحالة موحدة عبر Riverpod
18. ✅ **Favorites Screen** فعلية (بدل الرابط الفارغ سابقًا) بنفس تصميم شبكة القائمة، مع حالة "لا توجد مفضلة"
19. ✅ الضغط على أي بطاقة طبق (وليس فقط زر الإضافة) يفتح الآن شاشة التفاصيل

## المرحلة الرابعة (تفاصيل الطلب + تعديل الملف الشخصي)

20. ✅ **Edit Profile Screen**: نموذج فعلي لتعديل الاسم/اسم المستخدم/الهاتف/البريد مع صورة شخصية وزر تغييرها
21. ✅ **Order Details Screen**: رقم الطلب، الحالة، التاريخ، قائمة العناصر، الإجمالي، وزر "إعادة الطلب" للطلبات المكتملة/الملغاة
22. ✅ الضغط على أي طلب في Orders يفتح الآن تفاصيله الكاملة
23. ✅ زر "تعديل الملف الشخصي" في Profile يفتح الشاشة الفعلية بدل رابط فارغ

## المرحلة الخامسة (اختيار صورة حقيقية للملف الشخصي)

24. ✅ **AvatarPicker** فعلي (كاميرا/معرض/إزالة) عبر `image_picker`، بقائمة Bottom Sheet فاخرة، مستخدم في Signup و Edit Profile
25. ✅ نفس تجربة الاختيار موحّدة في الشاشتين (مكوّن واحد مشترك `core/widgets/avatar_picker.dart`)

> ⚠️ **صلاحيات مطلوبة بعد `flutter create`**: يجب إضافة أذونات الكاميرا/المعرض
> يدويًا (لأن مجلدات android/ios تُنشأ من جهازك وليست جزءًا من هذا الملف
> المضغوط):
>
> **iOS** — أضف في `ios/Runner/Info.plist`:
> ```xml
> <key>NSCameraUsageDescription</key>
> <string>Ahmad Rest & Cafe needs camera access to set your profile photo</string>
> <key>NSPhotoLibraryUsageDescription</key>
> <string>Ahmad Rest & Cafe needs photo library access to set your profile photo</string>
> ```
>
> **Android** — تأكد أن `minSdkVersion` في `android/app/build.gradle` هو 21
> أو أعلى (متطلب `image_picker`). لا حاجة لإذن كاميرا صريح في
> AndroidManifest لأنظمة Android الحديثة عند استخدام `image_picker` (يطلبه
> وقت التشغيل تلقائيًا)، لكن تأكد من مراجعة توثيق الحزمة إن واجهت مشاكل.

## المرحلة الثالثة عشرة (لوحة ألوان جديدة: تركوازي هادئ + ذهبي فخم)

58. ✅ طبّقت لوحة الألوان اللي حددتها بالضبط:

| الاسم | القيمة | الاستخدام |
|---|---|---|
| الخلفية الرئيسية | `#F3F8FA` | خلفية كل الشاشات |
| اللون الأساسي (تركوازي) | `#6F9FA8` | الأزرار، الروابط، التبويب النشط، الحدود عند التركيز |
| الذهبي الفخم | `#D6B56D` | لمسة فخامة محدودة: شعار AHMAD، والأسعار حصرًا |
| النص الأساسي | `#243238` | كل النصوص الأساسية |
| الأبيض / خلفية البطاقات | `#FFFFFF` | كل الكروت والحاويات |
| الحدود | `#DCE7E9` | كل الخطوط الفاصلة والحدود الخفيفة |

59. ✅ **تصميم بلونين متعمّد**: التركوازي هو اللون التفاعلي الأساسي (كل
    الأزرار، الأيقونات، التبويبات)، بينما الذهبي الفخم مخصّص **فقط**
    لشعار "AHMAD REST & CAFE" ولعرض الأسعار (`AppTextStyles.price`)
    — حتى يبقى الذهبي له وقع خاص بدل ما يتكرر بكل مكان
60. ✅ **فحصت تباين الألوان (Contrast)** فعليًا قبل التطبيق: النص الأبيض
    كان بيصير صعب القراءة فوق التركوازي (تباين 2.9:1 فقط)، فغيّرت نص
    الأزرار للون الداكن (`#243238`) بدلاً منه — تباين 4.5:1 مقروء بوضوح.
    ونفس الشيء طبّقته على الذهبي: الدرجة الفاتحة منه لا تصلح كنص على
    خلفية بيضاء (تباين ~2:1)، فاستخدمت درجة ذهبية أغمق (`#B0904F`)
    خصيصًا للنصوص (الأسعار) بينما الذهبي الأصلي يبقى للتدرجات والشارات

## المرحلة الثانية عشرة (تجهيز الشعار لـ iPhone وأندرويد معًا)

54. ✅ فصلت الشعار تلقائيًا عن خلفيته السوداء (إزالة خلفية برمجية) لإنشاء
    نسخة **شفافة** حقيقية — بدل الاعتماد على الصورة المسطّحة نفسها
55. ✅ أضفت **هامش أمان (Safe Zone)** حول الشعار (~62% من المساحة) حتى
    ما يُقص شيء من قبعة الشيف أو الشوكة عند تطبيق أندرويد لأشكاله
    المختلفة (دائرة، مربع مدوّر، قطرة...)
56. ✅ **iOS**: يستخدم النسخة الكاملة المسطّحة (`app_icon.png`) — هذا
    هو المعيار في آيفون أصلًا، حيث النظام يطبّق الزوايا المدوّرة بنفسه
57. ✅ **أندرويد (Adaptive Icon)**: يستخدم النسخة الشفافة
    (`app_icon_foreground.png`) فوق خلفية سوداء مطابقة (`#0A0A0A`)،
    فتبدو مطابقة تمامًا للتصميم الأصلي بغض النظر عن شكل القص

النتيجة: نفس الشعار، لكن جاهز بمعيار كل منصة — بدون أي هامش أسود زائد
أو اقتصاص غير مقصود.

## المرحلة الحادية عشرة (شعار مخصص من تصميمك)

52. ✅ استبدلت أيقونة التطبيق بالشعار اللي أرسلته (حرف A بقبعة شيف +
    شوكة + خط حركة، بتدرج برتقالي/ذهبي على خلفية سوداء) — محفوظة في
    `assets/icon/app_icon.png` و`assets/icon/app_icon_foreground.png`
53. ✅ حدّثت لون خلفية Adaptive Icon (أندرويد) وشاشة الـ Splash الأصلية
    ليطابق نفس الأسود في شعارك (`#0A0A0A`)

> ℹ️ عالجت لاحقًا مسألة الخلفية غير الشفافة تلقائيًا — انظر المرحلة
> الثانية عشرة أدناه لتفاصيل النسخة النهائية المهيّأة لـ iOS وأندرويد.

## المرحلة العاشرة (رفع صورة حقيقية لكل صنف)

48. ✅ **رفع صورة للطبق** من لوحة الأدمن: عند إضافة/تعديل أي صنف، فيه الآن
    مربع لاختيار صورة (كاميرا أو معرض) بنفس أسلوب اختيار الصورة الشخصية
49. ✅ الصورة تُرفع فعليًا إلى Firebase Storage تحت `dishes/{dishId}.jpg`
    ويُحفظ رابطها في مستند الطبق بحقل `imageUrl`
50. ✅ كل الشاشات (Home، Menu، Cart، Dish Details، Admin) تعرض الصورة
    الحقيقية تلقائيًا إن وُجدت، وإلا ترجع للأيقونة كـ Placeholder — بدون
    أي تغيير إضافي مطلوب، لأن كل الشاشات تعتمد على ودجت واحد مشترك
    (`DishImagePlaceholder`)
51. ✅ إمكانية حذف الصورة والرجوع للأيقونة الافتراضية

### 🔒 حدّث قواعد Firebase Storage لتشمل صور الأطباق

أضف هذا لقواعد Storage (بجانب قاعدة `avatars` من مرحلة المصادقة):

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /dishes/{dishId}.jpg {
      allow read: if true;
      // TODO: قيّدها لاحقًا بصلاحية أدمن فقط (نفس ملاحظة قاعدة
      // Firestore الخاصة بمجموعة dishes أعلاه)
      allow write: if request.auth != null;
    }
  }
}
```

## المرحلة التاسعة (تغيير الهوية البصرية إلى أخضر زيتوني وأبيض)

43. ✅ **استبدال كامل** للهوية البصرية: بدل الأسود/الذهبي الفاخر، أصبح
    التطبيق بهوية **فاتحة** — أبيض دافئ + أخضر "سيج" (Sage) هادئ وطبيعي
44. ✅ التغيير تم بالكامل من ملف واحد مركزي (`lib/core/theme/app_colors.dart`)
    تمامًا كما كانت البنية مصممة من البداية — لم يحتج الأمر تعديل تصميم
    أي شاشة يدويًا، فقط استبدال قيم الألوان وأسماء الرموز
45. ✅ تم تحويل الثيم من `ThemeData.dark()` إلى `ThemeData.light()` كأساس
    (كان يجب تغييره أيضًا حتى تُطبَّق الألوان الافتراضية الصحيحة على كل
    عناصر Material غير المخصصة يدويًا)
46. ✅ تم ضبط درجة الأخضر (`#5F7455`) خصيصًا لتحقيق تباين لوني (contrast)
    ≥ 5:1 مع النص الأبيض فوقه — يحقق معيار WCAG AA لسهولة القراءة
47. ✅ أيقونة التطبيق (App Icon) أُعيد إنشاؤها بنفس الأخضر/الأبيض الجديد

**خريطة إعادة تسمية الألوان** (للمرجعية إذا كان عندك فروع/تعديلات محلية):

| القديم (أسود/ذهبي) | الجديد (أخضر/أبيض) |
|---|---|
| `backgroundBlack` | `backgroundLight` |
| `surfaceDark` / `surfaceDarkElevated` | `surfaceCard` / `surfaceCardElevated` |
| `primaryGold` / `primaryGoldLight` | `primarySage` / `primarySageLight` |
| `textOnGold` | `textOnSage` |
| `goldGradient` | `sageGradient` |
| `ivory` | (أُلغي، استُبدل بـ `surfaceCard`) |

> ⚠️ **ملاحظة صغيرة**: أسماء بعض الكلاسات البرمجية الداخلية مثل
> `GoldGradientButton` أو ملف `gold_gradient_button.dart` بقيت بنفس
> الاسم القديم عمدًا (لتفادي خطر تعديل +15 ملف يستوردها بدون داعٍ
> وظيفي) — لكنها الآن **تعرض اللون الأخضر فعليًا**، فقط الاسم البرمجي
> الداخلي لم يتغيّر. هذا لا يؤثر على المستخدم إطلاقًا، فقط ملاحظة لأي
> مطوّر يقرأ الكود لاحقًا.

## المرحلة الثامنة (القائمة/السلة/الطلبات/المفضلة على Firestore الحقيقي)

37. ✅ **القائمة (Menu)**: كل الأطباق تُقرأ الآن مباشرة من مجموعة Firestore
    `dishes` عبر Stream حي — أي تغيير هناك ينعكس فورًا في التطبيق بدون
    إعادة تشغيل
38. ✅ **بذر تلقائي (Auto-seed)**: أول مرة يفتح فيها أي مستخدم شاشة Home
    على قاعدة بيانات فارغة، يُنسخ كتالوج تجريبي من 8 أطباق تلقائيًا إلى
    Firestore (`MenuRepository.seedIfEmpty`) — بعدها لا يتكرر
39. ✅ **السلة (Cart)**: تُخزَّن فعليًا في `users/{uid}/cart/{dishId}`
    وتُزامَن لحظيًا؛ الكميات تُحدَّث عبر `FieldValue.increment` لتفادي
    تعارض النقرات السريعة
40. ✅ **المفضلة (Favorites)**: تُخزَّن في `users/{uid}/favorites/{dishId}`
41. ✅ **الطلبات (Orders)**: زر **Checkout** أصبح فعليًا — يُنشئ مستند طلب
    حقيقي في `users/{uid}/orders/{orderId}` من محتوى السلة، ثم يُفرّغ
    السلة تلقائيًا وينقلك لتبويب Orders لتراه فورًا
42. ✅ كل الشاشات (Home/Menu/Cart/Orders/Favorites/Dish Details/Order
    Details) تعرض حالات **تحميل** و**خطأ** أنيقة بدل الانتظار الصامت

> **بنية البيانات في Firestore:**
> ```
> dishes/{dishId}                       ← عام، يقرأه أي مستخدم مسجّل
>   name, description, price, category, isFeatured
>
> users/{uid}
>   fullName, email, username, phone, photoUrl, provider   ← من مرحلة المصادقة
>
> users/{uid}/cart/{dishId}
>   quantity
>
> users/{uid}/favorites/{dishId}
>   addedAt
>
> users/{uid}/orders/{orderId}
>   items: [{dishName, quantity}], total, status, createdAt
> ```

### 🔒 حدّث قواعد Firestore لتشمل المجموعات الجديدة

أضف هذا لقواعد Firestore (بالإضافة لقاعدة `users/{userId}` من مرحلة
المصادقة):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /cart/{dishId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /favorites/{dishId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /orders/{orderId} {
        allow read, create: if request.auth != null && request.auth.uid == userId;
        allow update, delete: if false; // orders are append-only from the app
      }
    }

    match /dishes/{dishId} {
      // Any signed-in user can read AND write for now (so the auto-seed
      // step works out of the box). Before shipping, lock `write` down
      // to an admin role/custom claim and manage the menu from a proper
      // admin panel instead.
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

> ⚠️ **الصورة الحقيقية للأطباق** لا تزال Placeholder (أيقونة حسب
> التصنيف) — لا يوجد بعد حقل صورة في مستند `dishes`. إضافتها لاحقًا تعني
> فقط إضافة حقل `imageUrl` في Firestore واستبدال widget واحد
> (`DishImagePlaceholder`).

## المرحلة السابعة (Backend حقيقي عبر Firebase)

31. ✅ **Firebase Authentication حقيقي**: تسجيل الدخول بالبريد/كلمة المرور، Google، وFacebook أصبح جميعها يمر عبر Firebase Auth الحقيقي — **الجلسة تبقى محفوظة تلقائيًا بعد إغلاق التطبيق وإعادة فتحه** (Splash يتحقق من الجلسة ويوجّه المستخدم مباشرة لـ Home إن كان مسجّلاً دخوله)
32. ✅ **Cloud Firestore**: بيانات الملف الشخصي الإضافية (اسم المستخدم، الهاتف) تُحفظ في مجموعة `users/{uid}` وتُدمج تلقائيًا مع هوية Firebase Auth
33. ✅ **Firebase Storage**: الصورة الشخصية المُختارة (من Signup أو Edit Profile) تُرفع فعليًا إلى `avatars/{uid}.jpg` وتُستخدم كصورة حساب حقيقية
34. ✅ **نسيت كلمة المرور** أصبح فعليًا (`sendPasswordResetEmail`) ويرسل رابط إعادة تعيين حقيقي
35. ✅ رسائل خطأ مترجمة (4 لغات) لكل حالات فشل Firebase الشائعة (بريد مستخدم، كلمة مرور ضعيفة، مستخدم غير موجود...)
36. ✅ **تسجيل الخروج** الحقيقي ينظّف جلسة Firebase Auth بالإضافة لجلسة Google/Facebook

> ⚠️ **القائمة/السلة/الطلبات ما زالت بيانات وهمية (Mock)** في هذه المرحلة
> بناءً على اختيارك بالتركيز على المصادقة أولاً. نقلها إلى Firestore هو
> المرحلة الطبيعية التالية.

### 🔥 إعداد Firebase (إلزامي قبل التشغيل)

**1) أنشئ المشروع:**
- اذهب إلى [console.firebase.google.com](https://console.firebase.google.com) وأنشئ مشروعًا جديدًا

**2) فعّل طرق تسجيل الدخول** (Authentication → Sign-in method):
- فعّل **Email/Password**
- فعّل **Google** (يعطيك تلقائيًا Web Client ID تحتاجه لاحقًا)
- فعّل **Facebook** (يطلب منك App ID و App Secret من Facebook for Developers — أدخلهما هنا، وانسخ "OAuth redirect URI" الذي يعرضه Firebase والصقه في إعدادات Facebook Login)

**3) أنشئ قاعدة بيانات Firestore** (Firestore Database → Create database):
- ابدأ بوضع **Production mode**، ثم اضبط القواعد (Rules) لتسمح لكل مستخدم بقراءة/تعديل وثيقته فقط:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /users/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```

**4) فعّل Firebase Storage** (Storage → Get started) بقواعد مماثلة:
  ```
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      match /avatars/{userId}.jpg {
        allow read: if true;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```

**5) اربط تطبيق Flutter بالمشروع** — من جذر المشروع بعد `flutter create`:
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure
  ```
  اختر مشروعك ومنصّاتك (Android/iOS)، وسيقوم تلقائيًا باستبدال
  `lib/firebase_options.dart` بالقيم الحقيقية، وإنزال
  `google-services.json` / `GoogleService-Info.plist` في المكان الصحيح.

**6) أكمل إعداد Google/Facebook الأصلي** كما هو موضّح في قسم "تسجيل الدخول
عبر Google وFacebook" أدناه (SHA-1، Info.plist، AndroidManifest...) — لا
يزال مطلوبًا لأن `flutterfire configure` يهيئ Firebase نفسه فقط، وليس
إعدادات OAuth الخاصة بكل مزوّد.

بدون الخطوة 5 تحديدًا، التطبيق سيعرض شاشة "Firebase Setup Needed" بدل
الانهيار — حتى تُكمل الإعداد.

## المرحلة السادسة (تسجيل الدخول الفعلي عبر Google وFacebook)

26. ✅ **Google Sign-In حقيقي** عبر حزمة `google_sign_in` — يعيد الاسم والبريد والصورة الحقيقية من حساب Google
27. ✅ **Facebook Login حقيقي** عبر حزمة `flutter_facebook_auth` — نفس الشيء من حساب Facebook
28. ✅ حالة تحميل (Spinner) داخل الزر نفسه أثناء عملية الدخول + رسالة خطأ أنيقة (SnackBar) عند الفشل أو رفض الأذونات
29. ✅ **Profile Screen** يعرض الآن الاسم/البريد/الصورة الحقيقية لمن سجّل عبر Google أو Facebook أو البريد (كلها تصبّ في `authProvider` موحّد)
30. ✅ **تسجيل الخروج** الحقيقي يستدعي `GoogleSignIn().signOut()` أو `FacebookAuth.instance.logOut()` حسب طريقة الدخول

> ⚠️ **هذا يوفّر تسجيل دخول حقيقي بحسابات Google/Facebook فعلية، لكن بدون
> Backend خاص بك بعد** — أي لا يوجد بعد تخزين/جلسة/توكن على خادمك
> الخاص. البيانات (الاسم/البريد/الصورة) تأتي مباشرة من Google/Facebook
> وتُحفظ فقط في ذاكرة التطبيق أثناء الجلسة الحالية (لا تُخزَّن بعد إعادة
> فتح التطبيق). ربطها بحساب دائم على خادمك هو الخطوة التالية بعد بناء
> الـ Backend.

### ⚙️ إعداد إلزامي قبل التشغيل (كلاهما مطلوب لتعمل الأزرار)

**1) Google Sign-In:**
- أنشئ مشروعًا في [Google Cloud Console](https://console.cloud.google.com) → فعّل "Google Sign-In API"
- **Android**: أنشئ OAuth Client ID من نوع Android، وسجّل SHA-1 fingerprint الخاص بجهازك (`keytool -list -v -keystore ~/.android/debug.keystore`) مع اسم الحزمة (`applicationId` في `android/app/build.gradle`)
- **iOS**: أنشئ OAuth Client ID من نوع iOS، ثم في `ios/Runner/Info.plist` أضف:
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>REVERSED_CLIENT_ID_من_GoogleService-Info.plist</string>
      </array>
    </dict>
  </array>
  ```

**2) Facebook Login:**
- أنشئ تطبيقًا في [Facebook for Developers](https://developers.facebook.com) واحصل على App ID و Client Token
- **Android** — في `android/app/src/main/res/values/strings.xml`:
  ```xml
  <string name="facebook_app_id">YOUR_APP_ID</string>
  <string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
  <string name="fb_login_protocol_scheme">fbYOUR_APP_ID</string>
  ```
  وفي `AndroidManifest.xml` داخل `<application>` أضف meta-data لـ `com.facebook.sdk.ApplicationId` و `com.facebook.sdk.ClientToken` تشير لهذه القيم (راجع توثيق `flutter_facebook_auth` للنص الكامل).
- **iOS** — في `Info.plist` أضف `FacebookAppID`, `FacebookClientToken`, `FacebookDisplayName`، وCFBundleURLSchemes بصيغة `fbYOUR_APP_ID` (نفس مبدأ Google أعلاه).

بدون هذا الإعداد الأصلي في لوحتي Google/Facebook، الأزرار ستُظهر رسالة
خطأ "فشل تسجيل الدخول" لأن الـ SDK لن يجد بيانات اعتماد صالحة — هذا
طبيعي ومتوقع محليًا حتى تُكمل الإعداد أعلاه.

## كيفية التشغيل

المشروع هنا يحتوي على `lib/` و `pubspec.yaml` و ملفات الترجمة فقط (بدون مجلدات `android/` و `ios/` الجاهزة، لأنها تُولَّد تلقائيًا بواسطة Flutter SDK نفسه على جهازك). الخطوات:

```bash
# 1) أنشئ مشروع Flutter فارغ بنفس الاسم في مجلد جديد
flutter create ahmad_rest_cafe
cd ahmad_rest_cafe

# 2) احذف مجلد lib الافتراضي واستبدله بالمجلد المرفق
rm -rf lib
# انسخ مجلد lib و pubspec.yaml و l10n.yaml وملفات lib/l10n المرفقة إلى هنا

# 3) ثبّت الاعتماديات (هذا يولّد أيضًا AppLocalizations من ملفات arb تلقائيًا)
flutter pub get

# 4) شغّل التطبيق
flutter run
```

> بعد `flutter pub get` سيقوم Flutter تلقائيًا بتوليد
> `lib/core/localization/generated/app_localizations.dart`
> من ملفات `lib/l10n/app_*.arb` بفضل `generate: true` في `pubspec.yaml`
> و`l10n.yaml`. لا تُعدّل هذا الملف المولّد يدويًا.

## ملاحظة مهمة عن اللغة الكردية

طلبت أن تُعامَل الكردية (Kurmanji) كلغة RTL مثل العربية. الكرمانجية عادة
تُكتب بالحروف اللاتينية وتُقرأ من اليسار لليمين (LTR) بشكل طبيعي، لكن
تنفيذ المشروع الحالي يجعلها RTL فعليًا بناءً على طلبك الصريح
(`AppLocales.rtlCodes = {'ar', 'ku'}` في
`lib/core/localization/app_locales.dart`). إن كنت تقصد فعليًا الكردية
السورانية (بالحروف العربية) فهذا هو الخيار الصحيح 100%. أما إذا كنت
تريد الكرمانجية بالحروف اللاتينية بشكل طبيعي (LTR)، أخبرني وسأغيّر سطرًا
واحدًا فقط في ذلك الملف.

## الخطوة التالية (بانتظار تأكيدك)

المراحل القادمة المقترحة:
- ربط صور حقيقية للأطباق (Firebase Storage) بدل الـ Placeholder
- تفعيل Light Mode (البنية الحالية تدعمه بدون إعادة هيكلة)
- شريط تتبع حالة الطلب (Order Tracking Timeline) بصريًا في Order Details
- لوحة تحكم أدمن بسيطة لإدارة القائمة (بدل الاعتماد على البذر التلقائي)
- تشديد قواعد Firestore لمجموعة `dishes` (كتابة بصلاحية أدمن فقط)

أخبرني بأي مرحلة تريد أن نبدأ بها أولًا، أو إذا كان هناك أي تعديل تريده
على المرحلتين الحاليتين قبل المتابعة.
