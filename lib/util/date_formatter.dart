import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats a date string from yyyy-MM-dd to dd/MM/yyyy
  static String formatToDDMMYYYY(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    
    try {
      // Parse the date assuming it's in yyyy-MM-dd format
      final DateTime date = DateTime.parse(dateString);
      // Format it to dd/MM/yyyy
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }
  
  /// Formats a DateTime object to dd/MM/yyyy
  static String formatDateTimeToDDMMYYYY(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}