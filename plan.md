# خطة Spec-Kit لتطبيق Flutter: **رقيم**

> تطبيق مصحف تفاعلي احترافي بتصميم ديني راقٍ، يعتمد أساسًا على `quran_library: ^4.0.1`، مع تخصيص كامل للشاشات وتجربة القراءة والختمة والتفسير والمشاركة والحفظ.

---

## 1. الغرض من الخطة

هذه الخطة مصممة للاستخدام المباشر مع GitHub Spec Kit وفق أسلوب **Spec-Driven Development**:

1. كتابة المواصفة باستخدام `/speckit.specify`.
2. تحويل المواصفة إلى خطة تقنية باستخدام `/speckit.plan`.
3. توليد المهام باستخدام `/speckit.tasks`.
4. تحليل التعارضات باستخدام `/speckit.analyze`.
5. تنفيذ المشروع باستخدام `/speckit.implement`.

---

## 2. تعريف المنتج

### اسم التطبيق

**رقيم**

### الرؤية

تقديم تجربة مصحف رقمية تفاعلية، هادئة، فاخرة، ودينية الطابع، تركز على:

- قراءة القرآن الكريم بواجهة شبيهة بالمصحف.
- تفاعل كامل مع الآيات والكلمات.
- الاستماع للقراء.
- التفسير والترجمة.
- مشاركة الآيات كصور جميلة.
- العلامات المرجعية وآخر قراءة.
- نظام ختمة ذكي يوزع الورد اليومي بدقة.
- دعم تعدد اللغات.
- تجربة UI/UX احترافية وسهلة لكبار السن والشباب.

---

## 3. الاعتماد الأساسي

### الحزمة الأساسية

```yaml
dependencies:
  quran_library: ^4.0.1
```

### دور المكتبة

تستخدم `quran_library` كمحرك أساسي لعرض المصحف وبيانات القرآن وخصائص القراءة المتوفرة فيها، مع بناء طبقة تطبيق مخصصة بالكامل فوقها:

- شاشات مخصصة.
- Theme مخصص.
- Navigation مخصص.
- طبقة حفظ بيانات.
- نظام ختمة.
- نظام مشاركة الآية.
- نظام ملاحظات وعلامات.
- تجربة صوت وتفسير متقدمة.

---

## 4. الهوية البصرية

### لوحة الألوان المعتمدة

| Element | Hex Code | Usage |
|---|---:|---|
| Primary Color | `0xFFB49464` | Main buttons, active icons, and primary branding |
| Background | `0xFFF5F0E5` | Main scaffold and page backgrounds |
| Surface/Card | `0xFFEFE6D5` | Lists, cards, and container backgrounds |
| Primary Text | `0xFF3E2723` | Headlines, Surah names, and bold titles |
| Secondary Text | `0xFF7D6E5D` | Subtitles, Tafsir text, and descriptions |
| Accent Gold | `0xFFD4B982` | Selection states and progress bars |
| Soft White | `0xFFFAF8F2` | Reading screens and modal bottom sheets |

### مبادئ التصميم

- تصميم إسلامي هادئ بدون ازدحام.
- زخارف خفيفة جدًا في الهيدر والفواصل.
- تركيز كامل على النص القرآني.
- أزرار واضحة وكبيرة.
- دعم RTL بشكل كامل.
- الوضع الليلي الديني:
  - خلفية بنية داكنة.
  - نص ذهبي فاتح.
  - تقليل الإضاءة أثناء القراءة الليلية.
- قابلية قراءة عالية:
  - ضبط حجم الخط.
  - ضبط تباعد الأسطر.
  - وضع قراءة مريح.
  - منع العناصر المشتتة أثناء القراءة.

---

## 5. الشخصيات المستهدفة

### القارئ اليومي

يريد فتح التطبيق والعودة فورًا إلى آخر موضع قراءة، ومعرفة ورد اليوم.

### طالب العلم

يريد تفسير، ترجمة، بحث، حفظ ملاحظات، مقارنة معاني، والانتقال بين الآيات بسرعة.

### مستخدم الختمة

يريد إنشاء ختمة بزمن محدد، ومتابعة التقدم اليومي بدقة.

### المستمع

يريد اختيار قارئ، تشغيل التلاوة، التكرار، والتحكم في سرعة أو نطاق الاستماع.

---

## 6. نطاق الإصدار الأول MVP

### يجب أن يحتوي الإصدار الأول على

- شاشة onboarding بسيطة.
- الشاشة الرئيسية.
- شاشة المصحف.
- اختيار السورة والجزء والحزب والصفحة.
- آخر قراءة.
- العلامات المرجعية.
- تحديد الآية.
- قائمة إجراءات الآية.
- التفسير.
- الترجمة.
- مشاركة الآية كنص وصورة.
- اختيار قارئ.
- تشغيل صوت الآيات.
- نظام ختمة أساسي ومتقدم.
- إشعارات التذكير بالورد.
- إعدادات القراءة.
- دعم عربي/إنجليزي مبدئي.
- تخزين محلي offline-first.

### يؤجل لما بعد MVP

- مزامنة سحابية.
- حساب مستخدم.
- مشاركة اجتماعية داخلية.
- إحصائيات متقدمة جدًا.
- مسابقات أو مجتمع.

---

## 7. هيكل التطبيق

```text
lib/
  app/
    raqeem_app.dart
    router/
    theme/
    localization/
  core/
    constants/
    errors/
    extensions/
    utils/
    services/
  features/
    home/
    quran_reader/
    ayah_actions/
    tafsir/
    audio/
    bookmarks/
    last_read/
    khatma/
    share_ayah/
    search/
    settings/
    onboarding/
  data/
    local/
    repositories/
    models/
  shared/
    widgets/
    components/
    animations/
```

---

## 8. التقنية المقترحة

### State Management

استخدم أحد الخيارين:

#### الخيار المفضل

```yaml
flutter_riverpod
```

مناسب لتنظيم الحالة وفصل المنطق عن الواجهة.

#### بديل

```yaml
bloc
```

إذا كان الفريق يفضل نمط events/states.

### التخزين المحلي

```yaml
hive
hive_flutter
```

يستخدم لحفظ:

- آخر قراءة.
- العلامات المرجعية.
- إعدادات المستخدم.
- الخط وحجم النص.
- بيانات الختمة.
- تقدم الورد.
- القارئ المختار.
- اللغة المختارة.

### الإشعارات

```yaml
flutter_local_notifications
timezone
```

للتذكير اليومي بالورد.

### المشاركة كصورة

```yaml
screenshot
share_plus
path_provider
```

لإنشاء صورة آية مخصصة ومشاركتها.

### الصوت

حسب ما تدعمه `quran_library`، وإن احتاج التطبيق طبقة صوت مستقلة:

```yaml
just_audio
audio_session
```

### التدويل

```yaml
flutter_localizations
intl
```

---

## 9. أوامر Spec-Kit المقترحة

### 9.1 إنشاء المواصفة

```text
/speckit.specify
Build a Flutter application named "Raqeem" / "رقيم".

The app is a premium interactive Quran application with a calm Islamic UI/UX. It must use quran_library: ^4.0.1 as the primary Quran rendering and Quran feature foundation, but all application screens, navigation, theme, state management, khatma system, bookmarks, sharing, settings, and user experience must be custom-built.

The design must use these exact colors:
Primary Color: 0xFFB49464
Background: 0xFFF5F0E5
Surface/Card: 0xFFEFE6D5
Primary Text: 0xFF3E2723
Secondary Text: 0xFF7D6E5D
Accent Gold: 0xFFD4B982
Soft White: 0xFFFAF8F2

The app must include:
- Home dashboard.
- Quran reading screen.
- Surah, Juz, Hizb, Rub, and page navigation.
- Last reading.
- Bookmarks.
- Ayah selection.
- Word-by-word reading support when available from the Quran data layer.
- Tafsir and translation.
- Reciter selection.
- Ayah audio playback.
- Repeat ayah/range playback.
- Share ayah as image and text.
- Khatma planner.
- Daily wird calculation.
- Reminder time.
- Daily progress tracking.
- Interactive progress bars.
- Multilanguage support.
- Offline-first local persistence.
- Professional Islamic UI/UX.
```

### 9.2 إنشاء الخطة التقنية

```text
/speckit.plan
Use Flutter as the application framework.

Use quran_library: ^4.0.1 as the core Quran package.

Use Riverpod for state management.
Use Hive for local persistence.
Use flutter_local_notifications and timezone for daily wird reminders.
Use screenshot and share_plus for sharing ayah as an image.
Use just_audio only if quran_library does not fully cover the required audio playback behavior.
Use intl and Flutter localization for Arabic and English.

Architecture:
- Feature-first clean architecture.
- UI, state, repository, and local data source layers per feature.
- Offline-first design.
- Strong separation between quran_library integration and custom application logic.
- No business logic inside widgets.
- All user settings stored locally.
- All Khatma calculations must be deterministic, testable, and covered by unit tests.

UI:
- Use the provided color palette exactly.
- Full RTL support.
- Premium Islamic theme.
- Responsive layout for different phone sizes.
- Accessible text sizing.
- Smooth transitions and subtle animations.
```

### 9.3 توليد المهام

```text
/speckit.tasks
Break the implementation into small tasks grouped by feature:
1. project setup
2. theme and design system
3. quran_library integration
4. home dashboard
5. Quran reader
6. ayah actions
7. tafsir and translation
8. audio and reciter selection
9. bookmarks and last reading
10. khatma planner
11. notifications
12. share ayah as image
13. search
14. settings
15. localization
16. tests
17. release readiness
```

---

## 10. الشاشات المطلوبة

### 10.1 شاشة البداية Splash

#### الهدف

عرض هوية رقيم بشكل راقٍ.

#### العناصر

- شعار رقيم.
- خلفية `Background`.
- زخرفة إسلامية خفيفة.
- تحميل إعدادات المستخدم.
- تهيئة `quran_library`.
- الانتقال لآخر حالة:
  - onboarding إذا أول استخدام.
  - home إذا مستخدم سابق.

---

### 10.2 شاشة Onboarding

#### الشرائح

1. اقرأ القرآن بتجربة هادئة.
2. استمع وتدبر الآيات.
3. أنشئ ختمتك اليومية.
4. احفظ مواضعك وشارك الآيات.

#### الإجراءات

- اختيار اللغة.
- اختيار الوضع:
  - فاتح.
  - داكن.
  - حسب النظام.
- زر "ابدأ رحلتك".

---

### 10.3 الشاشة الرئيسية Home

#### الهدف

تكون لوحة قيادة روحانية يومية.

#### العناصر

- تحية حسب الوقت.
- بطاقة آخر قراءة:
  - السورة.
  - الآية.
  - الصفحة.
  - زر متابعة.
- بطاقة ورد اليوم:
  - اسم الختمة النشطة.
  - من أين إلى أين.
  - نسبة الإنجاز.
  - زر إكمال الورد.
- اختصارات:
  - المصحف.
  - السور.
  - الأجزاء.
  - البحث.
  - العلامات.
  - الختمة.
  - الإعدادات.
- آية اليوم اختيارية.
- شريط تقدم الختمة.

---

### 10.4 شاشة المصحف Reader

#### الهدف

قراءة مصحف احترافية ومريحة.

#### المتطلبات

- استخدام `quran_library` لعرض صفحات المصحف.
- تخصيص الهيدر والفوتر.
- دعم التنقل بين الصفحات.
- إخفاء عناصر التحكم عند القراءة.
- ظهور عناصر التحكم عند النقر.
- حفظ آخر قراءة تلقائيًا.
- دعم:
  - السورة.
  - الصفحة.
  - الجزء.
  - الحزب.
  - الربع.
- تحديد الآية بالضغط المطول أو النقر.
- تمييز الآية بلون `Accent Gold`.
- Bottom sheet لإجراءات الآية.

#### إجراءات الآية

- تشغيل من هذه الآية.
- تكرار الآية.
- عرض التفسير.
- عرض الترجمة.
- إضافة علامة مرجعية.
- إضافة ملاحظة.
- نسخ الآية.
- مشاركة نص.
- مشاركة صورة.
- تحديد بداية ورد.
- تحديد نهاية ورد.

---

### 10.5 شاشة اختيار السورة

#### العناصر

- بحث سريع.
- قائمة السور.
- رقم السورة.
- مكية/مدنية.
- عدد الآيات.
- آخر موضع داخل السورة.
- تصميم بطاقات بلون `Surface/Card`.

---

### 10.6 شاشة الأجزاء والأحزاب

#### العناصر

- قائمة الأجزاء 1 إلى 30.
- كل جزء يعرض:
  - بداية الجزء.
  - السورة/الآية.
  - حالة القراءة.
- قائمة الأحزاب 1 إلى 60.
- قائمة الأرباع 1 إلى 240.
- إمكانية بدء القراءة من أي نطاق.

---

### 10.7 شاشة التفسير

#### المتطلبات

- عرض الآية المختارة.
- عرض التفسير.
- دعم اختيار مصدر تفسير إذا توفر.
- دعم اللغة.
- زر تكبير الخط.
- زر مشاركة التفسير.
- تصميم مريح بخلفية `Soft White`.

---

### 10.8 شاشة الصوت والقراء

#### العناصر

- اختيار القارئ.
- حفظ القارئ الافتراضي.
- تشغيل/إيقاف.
- التالي/السابق.
- تكرار:
  - آية واحدة.
  - نطاق آيات.
  - صفحة.
  - سورة.
  - ورد اليوم.
- عرض الآية الحالية أثناء التشغيل.
- إبقاء الشاشة متزامنة مع الصوت.

---

### 10.9 شاشة العلامات المرجعية

#### أنواع العلامات

- علامة قراءة.
- علامة حفظ.
- علامة تدبر.
- علامة مراجعة.
- علامة مخصصة.

#### الحقول

- السورة.
- الآية.
- الصفحة.
- تاريخ الإضافة.
- ملاحظة اختيارية.
- لون العلامة.

#### الإجراءات

- فتح الموضع.
- تعديل الملاحظة.
- حذف العلامة.
- فرز حسب التاريخ أو السورة.

---

### 10.10 شاشة آخر قراءة

#### المتطلبات

- حفظ تلقائي بعد الانتقال أو الخروج.
- عرض آخر 5 مواضع قراءة.
- زر متابعة.
- دعم تعدد المصاحف/الروايات إذا أضافتها المكتبة مستقبلًا.

---

### 10.11 شاشة الختمة Khatma

#### الهدف

نظام ذكي لإنشاء ومتابعة الختمات.

#### إنشاء ختمة جديدة

المدخلات:

- اسم الختمة.
- نطاق الختمة:
  - من جزء إلى جزء.
  - أو من سورة/آية إلى سورة/آية.
  - أو كامل المصحف.
- تاريخ البداية.
- تاريخ النهاية أو عدد الأيام.
- وقت التذكير اليومي.
- أيام القراءة:
  - كل يوم.
  - أيام محددة.
- وحدة التوزيع:
  - تلقائي.
  - أجزاء.
  - أحزاب.
  - أرباع.
  - صفحات.
  - آيات.

#### حساب الورد اليومي

يعتمد الحساب الأساسي على تحويل النطاق إلى وحدات صغيرة قابلة للتوزيع.

الأولوية المقترحة:

1. الصفحة.
2. الربع.
3. الحزب.
4. الجزء.
5. الآية عند الحاجة للدقة.

#### المعادلة

```text
total_units = units_between(start, end)
active_days = reading_days_between(start_date, end_date, selected_weekdays)
daily_base = total_units / active_days
```

#### توزيع الباقي

```text
base = floor(total_units / active_days)
remainder = total_units % active_days

For day i:
  daily_units = base + 1 if i < remainder else base
  otherwise daily_units = base
```

#### مثال

إذا اختار المستخدم:

- من الجزء 1 إلى الجزء 30.
- خلال 30 يومًا.

النظام يقترح:

- جزء يوميًا.

إذا اختار:

- كامل المصحف خلال 15 يومًا.

النظام يقترح:

- جزأين يوميًا.

إذا اختار:

- كامل المصحف خلال 10 أيام.

النظام يقترح:

- 3 أجزاء يوميًا.

إذا كان الحساب لا يقسم بدقة، يوزع النظام الزيادة على الأيام الأولى أو حسب طريقة متوازنة.

---

## 11. تفاصيل شاشة الورد اليومي

### العناصر

- عنوان: ورد اليوم.
- نطاق اليوم:
  - من سورة/آية/صفحة.
  - إلى سورة/آية/صفحة.
- شريط تقدم:
  - 0% إلى 100%.
- معلومات:
  - الصفحات المطلوبة.
  - الأرباع المطلوبة.
  - الأجزاء المكافئة.
  - الوقت التقريبي.
- زر:
  - بدء الورد.
  - متابعة.
  - إكمال الورد.
- حالة:
  - لم يبدأ.
  - قيد القراءة.
  - مكتمل.
  - فائت.
- عند الإكمال:
  - رسالة تهنئة.
  - تحديث تقدم الختمة.
  - فتح ورد اليوم التالي.

---

## 12. منطق الختمة

### الكيانات

```dart
class KhatmaPlan {
  final String id;
  final String name;
  final QuranRange range;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay reminderTime;
  final List<int> activeWeekdays;
  final KhatmaDistributionMode distributionMode;
  final double progress;
  final bool isActive;
}
```

```dart
class DailyWird {
  final String id;
  final String khatmaId;
  final DateTime date;
  final QuranRange range;
  final int totalPages;
  final int completedPages;
  final bool isCompleted;
}
```

```dart
class QuranRange {
  final QuranPosition start;
  final QuranPosition end;
}
```

```dart
class QuranPosition {
  final int surah;
  final int ayah;
  final int page;
  final int juz;
  final int hizb;
  final int rub;
}
```

---

## 13. قواعد تجربة المستخدم للختمة

- لا يسمح بنطاق نهاية قبل البداية.
- لا يسمح بمدة صفرية.
- إذا كان الورد اليومي كبيرًا جدًا، يظهر تحذير لطيف.
- يمكن تعديل الختمة.
- عند تعديل الختمة يعاد توزيع الأيام غير المكتملة فقط.
- الأيام المكتملة لا تتغير إلا بتأكيد.
- إذا فات يوم:
  - خيار ترحيل الورد.
  - خيار إعادة توزيع المتبقي.
  - خيار إبقاء الفائت.
- يمكن إيقاف ختمة مؤقتًا.
- يمكن إنشاء أكثر من ختمة، لكن ختمة واحدة فقط تكون نشطة افتراضيًا في الصفحة الرئيسية.

---

## 14. المشاركة كصورة

### تصميم صورة الآية

#### العناصر

- خلفية `Soft White` أو تدرج هادئ.
- زخرفة علوية خفيفة.
- نص الآية بخط واضح.
- اسم السورة ورقم الآية.
- اسم التطبيق "رقيم".
- خيار إظهار/إخفاء التفسير.
- خيار إظهار/إخفاء الترجمة.
- مقاسات:
  - Story 9:16.
  - Square 1:1.
  - Post 4:5.

### خطوات المشاركة

1. المستخدم يختار آية.
2. يضغط مشاركة كصورة.
3. يظهر محرر بسيط.
4. يختار النمط والمقاس.
5. يتم توليد الصورة.
6. يتم فتح مشاركة النظام.

---

## 15. البحث

### المتطلبات

- بحث في أسماء السور.
- بحث في الآيات إذا توفرت البيانات.
- بحث في العلامات والملاحظات.
- نتائج منظمة:
  - آيات.
  - سور.
  - علامات.
  - تفسير.

---

## 16. الإعدادات

### إعدادات القراءة

- حجم الخط.
- نوع الخط إذا متاح.
- تباعد الأسطر.
- إبقاء الشاشة مضاءة.
- إخفاء/إظهار الترجمة.
- إخفاء/إظهار التفسير المختصر.
- الوضع الليلي.
- لون التحديد.

### إعدادات الصوت

- القارئ الافتراضي.
- التكرار.
- التشغيل التلقائي للآية التالية.

### إعدادات الختمة

- وقت التذكير الافتراضي.
- طريقة توزيع الورد.
- بداية اليوم:
  - بعد الفجر.
  - بعد منتصف الليل.

### إعدادات اللغة

- العربية.
- الإنجليزية.
- قابلية إضافة لغات أخرى.

---

## 17. التصميم التقني للميزات

### طبقة التكامل مع quran_library

أنشئ خدمة وسيطة بدل استخدام المكتبة مباشرة داخل كل الشاشات:

```dart
abstract class QuranService {
  Future<void> initialize();
  QuranPageData getPage(int page);
  QuranPosition getPositionByPage(int page);
  List<AyahData> getAyahsByRange(QuranRange range);
  Future<void> playAyah(int surah, int ayah, String reciterId);
}
```

الفائدة:

- سهولة تغيير المكتبة مستقبلاً.
- عزل API الخاص بالمكتبة.
- تسهيل الاختبارات.
- بناء منطق الختمة فوق واجهة ثابتة.

---

## 18. قواعد الجودة

### الأداء

- فتح التطبيق خلال أقل وقت ممكن.
- عدم تحميل كل الموارد الثقيلة مرة واحدة.
- Lazy loading للبيانات والصوت.
- Cache للصفحات والبيانات المستخدمة بكثرة.
- منع إعادة بناء شاشة المصحف بدون داعٍ.

### الوصولية

- دعم تكبير الخط.
- ألوان متباينة.
- أزرار لا تقل عن 44px.
- دعم قارئ الشاشة قدر الإمكان.
- عناوين واضحة.

### الاعتمادية

- كل بيانات المستخدم تحفظ محليًا فورًا.
- لا يضيع تقدم الختمة عند إغلاق التطبيق.
- لا يضيع آخر موضع قراءة.
- معالجة انقطاع الإنترنت عند الصوت أو التحميل.

---

## 19. الاختبارات المطلوبة

### Unit Tests

- حساب الورد اليومي.
- توزيع الباقي.
- التحقق من نطاق الختمة.
- حفظ واسترجاع آخر قراءة.
- حفظ واسترجاع العلامات.
- حساب نسبة التقدم.
- إعادة توزيع الفائت.

### Widget Tests

- الشاشة الرئيسية.
- شاشة الختمة.
- Bottom sheet الآية.
- شاشة الإعدادات.
- شاشة العلامات.

### Integration Tests

- إنشاء ختمة.
- بدء ورد.
- إكمال ورد.
- إضافة علامة.
- العودة لآخر قراءة.
- مشاركة آية كصورة.

---

## 20. معايير القبول

### المصحف

- يمكن للمستخدم فتح المصحف والانتقال بين الصفحات بسلاسة.
- يتم حفظ آخر موضع قراءة تلقائيًا.
- يمكن تحديد آية وفتح إجراءاتها.
- يمكن عرض التفسير والترجمة.
- يمكن مشاركة الآية كنص وصورة.

### الصوت

- يمكن اختيار قارئ.
- يمكن تشغيل آية.
- يمكن تكرار آية أو نطاق.
- يتم إبراز الآية الحالية أثناء التشغيل.

### العلامات

- يمكن إضافة علامة مرجعية.
- يمكن فتح العلامة لاحقًا.
- يمكن حذف أو تعديل العلامة.
- تحفظ العلامات محليًا.

### الختمة

- يمكن إنشاء ختمة من جزء إلى جزء.
- يمكن تحديد مدة الختمة.
- يمكن تحديد وقت التذكير.
- يتم توليد ورد يومي تلقائيًا.
- يعرض التطبيق تقدم الورد والختمة.
- يمكن إكمال ورد اليوم.
- يعاد حساب التقدم بدقة.

### التصميم

- يستخدم التطبيق الألوان المحددة فقط كأساس.
- يدعم RTL.
- يظهر بمظهر ديني احترافي.
- لا توجد شاشات افتراضية غير مخصصة.
- كل الشاشات متسقة بصريًا.

---

## 21. أولويات التنفيذ

### المرحلة 1: Foundation

- إنشاء مشروع Flutter.
- إعداد Spec-Kit.
- إضافة الحزم.
- إعداد الثيم.
- إعداد التوجيه.
- إعداد التخزين المحلي.
- إعداد localization.

### المرحلة 2: Quran Core

- دمج `quran_library`.
- شاشة المصحف.
- التنقل بين الصفحات.
- تحديد الآية.
- آخر قراءة.

### المرحلة 3: Ayah Features

- Bottom sheet للآية.
- التفسير.
- الترجمة.
- النسخ.
- المشاركة النصية.
- المشاركة كصورة.

### المرحلة 4: Bookmarks

- إضافة علامة.
- قائمة العلامات.
- فتح موضع العلامة.
- ملاحظات العلامة.

### المرحلة 5: Audio

- اختيار قارئ.
- تشغيل الآية.
- التكرار.
- مزامنة الصوت مع القراءة.

### المرحلة 6: Khatma

- إنشاء ختمة.
- حساب الورد.
- شاشة ورد اليوم.
- إكمال ورد.
- شريط تقدم.
- إعادة توزيع الفائت.

### المرحلة 7: Notifications

- تذكير يومي.
- ربط التذكير بالختمة.
- إعداد وقت التذكير.

### المرحلة 8: Polish

- تحسين UI/UX.
- Animations.
- Accessibility.
- Testing.
- تحسين الأداء.
- تجهيز الإصدار.

---

## 22. قواعد صارمة للمطور أو وكيل الذكاء الاصطناعي

- لا تستخدم شاشات جاهزة من المكتبة بدون تخصيص الشكل العام للتطبيق.
- لا تضع business logic داخل widgets.
- لا تستخدم ألوان خارج لوحة الألوان إلا للخطأ/النجاح وبدرجات هادئة.
- لا تحفظ بيانات المستخدم في الذاكرة فقط.
- لا تجعل الختمة تعتمد على النص فقط؛ يجب أن تعتمد على مواضع دقيقة.
- لا تنفذ المشاركة كصورة بشكل عشوائي؛ يجب أن تكون بتصميم راقٍ.
- لا تجعل التطبيق يحتاج إنترنت للقراءة الأساسية.
- لا تكسر دعم RTL.
- لا تجعل المستخدم يضيع داخل الشاشات؛ اجعل العودة للمصحف وآخر قراءة سهلة دائمًا.

---

## 23. Definition of Done

يعتبر التطبيق جاهزًا عندما:

- كل ميزات MVP تعمل.
- الاختبارات الأساسية ناجحة.
- لا توجد شاشة بدون تصميم مخصص.
- الختمة تعمل بدقة.
- آخر قراءة والعلامات محفوظة.
- المشاركة كصورة تعمل.
- التطبيق يدعم العربية والإنجليزية.
- الأداء جيد على أجهزة متوسطة.
- واجهة القراءة مريحة ولا تحتوي مشتتات.
- تم توثيق طريقة تشغيل المشروع.
- تم توثيق قيود `quran_library` وأي حلول بديلة.

---

## 24. README مختصر للمشروع

```md
# رقيم

رقيم هو تطبيق Flutter لمصحف تفاعلي احترافي، يعتمد على quran_library ويقدم تجربة قراءة وتدبر وختمة يومية بتصميم إسلامي فاخر.

## Features

- مصحف تفاعلي
- آخر قراءة
- علامات مرجعية
- تفسير وترجمة
- اختيار قارئ
- تشغيل وتكرار التلاوة
- مشاركة الآية كصورة
- نظام ختمة ذكي
- ورد يومي تلقائي
- تذكيرات يومية
- دعم العربية والإنجليزية
- Offline-first

## Tech Stack

- Flutter
- quran_library
- Riverpod
- Hive
- flutter_local_notifications
- screenshot
- share_plus
- intl

## Design Colors

Primary: 0xFFB49464
Background: 0xFFF5F0E5
Surface: 0xFFEFE6D5
Primary Text: 0xFF3E2723
Secondary Text: 0xFF7D6E5D
Accent Gold: 0xFFD4B982
Soft White: 0xFFFAF8F2
```

---

