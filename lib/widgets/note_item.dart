import 'package:flutter/material.dart';
import 'package:test_lan1111/models/note.dart';
import 'package:test_lan1111/screens/NoteDetailPage.dart';
import 'package:test_lan1111/utils/calculation_utils.dart';

class NoteItem extends StatelessWidget {
  final Note note;

  NoteItem({required this.note});

  String _getImageUrl(String productType) {
    return 'assets/images/$productType.png';
  }

  String capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  @override
  Widget build(BuildContext context) {
    String itemName = capitalize(note.processedData?.first['Món đồ'] ?? 'Không có món đồ');
    String itemPlace = capitalize(note.processedData?.first['Nơi mua'] ?? 'Không có nơi mua');
    String productType = note.processedData?.first['Loại sản phẩm']?.toLowerCase() ?? 'default';
    String imageUrl = _getImageUrl(productType);

    return ListTile(
      leading: Image.asset(
        imageUrl,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_not_supported);
        },
      ),
      title: Text(
        itemName,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemPlace,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            CalculationUtils.formatTimestamp(note.timestamp),
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        '${note.processedData?.first['Số tiền'] ?? ''} VNĐ',
        style: TextStyle(fontSize: 17, color: Colors.green),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailPage(note: note),
          ),
        );
      },
    );
  }
}
