# بنية قاعدة البيانات (Database Schema - SQLite)

سيتم استخدام `sqflite` كقاعدة بيانات محلية لتخزين جميع بيانات التطبيق "إدارة العقارات".
هذه الوثيقة تحتوي على الجداول الأساسية، الحقول المطلوبة، والعلاقات بين الجداول (Foreign Keys).

## 1. جدول العمارات (Buildings `buildings`)

- **`id`** (INTEGER PRIMARY KEY AUTOINCREMENT): المعرف الفريد للعمارة.
- **`name`** (TEXT NOT NULL): اسم العمارة (أو رقمها إن لم يكن لها اسم).
- **`floors_count`** (INTEGER NOT NULL): عدد الطوابق الكلي في العمارة.
- **`apartments_count`** (INTEGER NOT NULL): إجمالي عدد الشقق.
- **`rent_cycle`** (TEXT DEFAULT 'شهري'): نظام الإيجار (شهري / سنوي).
- **`auto_name_apartments`** (INTEGER DEFAULT 1): حالة الترقيم التلقائي للشقق (1 نعم / 0 لا).
- **`created_at`** (TEXT): تاريخ إضافتها للتطبيق.

## 2. جدول الشقق (Apartments `apartments`)

- **`id`** (INTEGER PRIMARY KEY AUTOINCREMENT): المعرف الفريد للشقة.
- **`building_id`** (INTEGER NOT NULL): معرف العمارة التي تنتمي إليها هذه الشقة (Foreign Key -> `buildings.id`).
- **`name_or_number`** (TEXT NOT NULL): اسم الشقة المخصص، أو الترقيم التلقائي المولد.
- **`floor_number`** (INTEGER NOT NULL): الطابق الذي توجد به هذه الشقة.
- **`is_rented`** (INTEGER DEFAULT 0): حالة الشقة: (0 للفارغة / 1 للمؤجرة).

## 3. جدول المستأجرين (Tenants `tenants`)

- **`id`** (INTEGER PRIMARY KEY AUTOINCREMENT): المعرف الافتراضي للمستأجر.
- **`apartment_id`** (INTEGER NOT NULL): الشقة التي استأجرها (Foreign Key -> `apartments.id`). يتم تعيينه عند الإضافة.
- **`name`** (TEXT NOT NULL): الاسم الكامل للمستأجر.
- **`phone`** (TEXT): رقم التواصل (اختياري لكن مفضل).
- **`rent_amount`** (REAL NOT NULL): مبلغ الإيجار المتفق عليه.
- **`contract_image_path`** (TEXT): مسار الصورة الملتقطة لعقد الإيجار والمحفوظة في الجهاز محلياً.
- **`start_date`** (TEXT): تاريخ بداية العقد.
- **`notes`** (TEXT): ملاحظات عامة حول المستأجر أو شروط التأجير (اختياري).

## 4. جدول دفع الإيجارات (Payments `payments`)

- **`id`** (INTEGER PRIMARY KEY AUTOINCREMENT): رقم إيصال أو عملية الدفع.
- **`tenant_id`** (INTEGER NOT NULL): معرف المستأجر الذي قام بالدفع (Foreign Key -> `tenants.id`).
- **`amount`** (REAL NOT NULL): المبلغ المدفوع تحديداً في هذه العملية.
- **`payment_date`** (TEXT NOT NULL): تاريخ عملية الدفع الفعلي.
- **`rent_month`** (TEXT NOT NULL): الشهر المُسجل الذي تم دفع الإيجار عنه (مثل: "مارس 2026" أو من "يناير 2026 إلى مارس 2026" في حال الدفع لعدة أشهر متصلة).
- **`payment_method`** (TEXT DEFAULT 'نقدي'): طريقة الدفع (نقدي / تحويل بنكي / شيك).
- **`notes`** (TEXT): أي ملاحظات إضافية على عملية الدفع.

## ملاحظات حول العلاقات (Relationships)

- العمارة الواحدة تحتوي على **عدة شقق** (One-to-Many).
- الشقة يتم تأجيرها لـ **مستأجر واحد** في نفس الوقت (One-to-One نشط).
- المستأجر الواحد يملك **سجل لعدة مدفوعات إيجار** عبر الأشهر (One-to-Many).
