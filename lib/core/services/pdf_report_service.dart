import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/building_model.dart';
import '../../models/tenant_model.dart';
import '../../models/apartment_model.dart';
import '../utils/formatters.dart';

class PdfReportService {
  static Future<void> printBuildingsReport(List<Building> buildings) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
      header: (context) {
        return pw.Column(children: [
          pw.Text('تقرير العمارات',
              style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold)),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),
        ]);
      },
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: ['اسم العمارة', 'عدد الطوابق', 'عدد الشقق', 'دورة الإيجار'],
          data: buildings
              .map((b) => [
                    b.name,
                    b.floorsCount.toString(),
                    b.apartmentsCount.toString(),
                    b.rentCycle,
                  ])
              .toList(),
          headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold),
          cellAlignment: pw.Alignment.center,
        ),
      ],
    ));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> printTenantsReport(
      List<Tenant> tenants, List<Apartment> apartments) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
      header: (context) {
        return pw.Column(children: [
          pw.Text('تقرير المستأجرين',
              style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold)),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),
        ]);
      },
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: [
            'اسم المستأجر',
            'رقم الهاتف',
            'الشقة',
            'مبلغ الإيجار',
            'تاريخ البدء'
          ],
          data: tenants.map((t) {
            final apt = apartments.firstWhere((a) => a.id == t.apartmentId,
                orElse: () => Apartment(
                    id: 0,
                    buildingId: 0,
                    nameOrNumber: 'غير محدد',
                    floorNumber: 0,
                    isRented: false));
            return [
              t.name,
              t.phone ?? 'لا يوجد',
              apt.nameOrNumber,
              AppFormatters.formatCurrency(t.rentAmount),
              t.startDate != null ? t.startDate!.split('T')[0] : 'غير مسجل',
            ];
          }).toList(),
          headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold),
          cellAlignment: pw.Alignment.center,
        ),
      ],
    ));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
