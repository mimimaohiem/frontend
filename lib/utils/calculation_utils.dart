import 'package:test_lan1111/models/note.dart';
import 'package:intl/intl.dart';

class CalculationUtils {
  static Map<String, dynamic> calculateTotals(List<Note> notes) {
    int totalIncome = 0;
    int totalExpense = 0;

    for (var note in notes) {
      if (note.processedData != null) {
        for (var data in note.processedData!) {
          if (data['Loại phương thức thanh toán'] == 'thu') {
            totalIncome += (data['Số tiền'] as num).toInt();
          } else if (data['Loại phương thức thanh toán'] == 'chi') {
            totalExpense += (data['Số tiền'] as num).toInt();
          }
        }
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }

  static String formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return 'Không có thời gian';
    }

    DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
    DateTime dateTime = inputFormat.parse(timestamp);

    DateFormat outputFormat = DateFormat('EEEE, dd/MM/yyyy');
    return outputFormat.format(dateTime);
  }
}
