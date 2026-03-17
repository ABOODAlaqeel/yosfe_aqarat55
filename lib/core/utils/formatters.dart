import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount) {
    // Format to yemeni rial or any generic format
    final formatter = NumberFormat.currency(
      locale: 'ar_YE',
      symbol: 'ريال',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }
}
