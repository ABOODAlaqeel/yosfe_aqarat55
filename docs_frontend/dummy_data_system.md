# نظام البيانات الوهمية (Dummy Data System)

بناءً على طلب العميل، يجب فصل البيانات الوهمية بشكل كامل عن ملفات بناء الواجهات (`UI Screens`). ستوضع جميع البيانات الافتراضية للتجربة في مرحلة _الجزء الأول_ داخل ملف مخصص: **`lib/data/dummy_data.dart`**.

## 1. نموذج كلاسات البيانات (Data Models Definitions)

للحفاظ على نظافة الكود وتسهيل استبدال البيانات لاحقاً بتلك الحقيقية، ستبنى الـ Models التالية في مجلد `lib/models/`:

- `Building`: لتمثيل العمارات.
- `Apartment`: لتمثيل الشقق داخل العمارة.
- `Tenant`: لتمثيل المستأجر مع الإشارة للشقة المرتبط بها.
- `Payment`: لتمثيل سجل الإيجارات والمدفوعات لكل مستأجر.

## 2. هيكلة ملف `dummy_data.dart` المخصصة

الملف `lib/data/dummy_data.dart` سيحتوي على **(List)** لكل كائن، والتي سيتعامل معها التطبيق كأنها قاعدة البييانات الخاصة به وتستخدم **للعرض فقط** في الـ UI:

```dart
// مثال توضيحي لما سيتم تطبيقه فعلياً في ملف dummy_data.dart
import '../models/building_model.dart';
import '../models/apartment_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';

class DummyData {
  // 1. قائمة العمارات
  static List<Building> buildings = [
    Building(id: 1, name: 'عمارة الياسمين', floorsCount: 4, apartmentsCount: 8),
    Building(id: 2, name: 'برج السلام', floorsCount: 10, apartmentsCount: 40),
  ];

  // 2. قائمة الشقق
  static List<Apartment> apartments = [
    Apartment(id: 1, buildingId: 1, nameOrNumber: 'شقة 1', floorNumber: 1, isRented: true),
    Apartment(id: 2, buildingId: 1, nameOrNumber: 'شقة 2', floorNumber: 1, isRented: false),
    // ...
  ];

  // 3. قائمة المستأجرين
  static List<Tenant> tenants = [
    Tenant(id: 101, apartmentId: 1, name: 'محمد عبدالله', phone: '777000111', rentAmount: 60000, startDate: '01/01/2026'),
  ];

  // 4. قائمة المدفوعات (الإيجار)
  static List<Payment> payments = [
    Payment(id: 1001, tenantId: 101, amount: 60000, paymentDate: '01/02/2026', rentMonth: 'فبراير'),
  ];
}
```

## 3. آلية جلب البيانات في ملفات الـ UI

- الشاشات لن تحتوي على الـ Lists.
- الشاشة ستقوم بعمل: `ListView.builder(itemCount: DummyData.buildings.length, ...)` لاستدعاء العمارات.
- عندما ننتقل لبرمجة الباك اند في مرحلة لاحقة، يتم استبدال `DummyData` بـ دوال الـ `DatabaseHelper` التي تتواصل مع SQLite بدون الحاجة لتعديل تركيبة الواجهة نفسها بشكل جذري.
