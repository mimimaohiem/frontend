import 'package:flutter/material.dart';
import 'package:test_lan1111/models/note.dart';
import 'package:test_lan1111/services/api_service.dart';  // Ensure you have this import if ApiService is used
import 'notes_page.dart'; // Make sure to import the NotesPage here

class NoteDetailPage extends StatelessWidget {
  final Note note;
  final ApiServicein apiServicein = ApiServicein(); // Assuming you have an ApiService class

  NoteDetailPage({required this.note});

  void _deleteNote(BuildContext context) async {
    bool deleted = await apiServicein.deleteNote(note.id!); // Assuming deleteNote method exists and works appropriately
    if (deleted) {
      // Replace the current route with the NotesPage
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NotesPage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to delete the note")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final processedData = note.processedData?.first ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết giao dịch'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteNote(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Ghi chú: ${note.note}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Món đồ:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(processedData['Món đồ'] ?? ''),
            ),
            ListTile(
              title: Text('Số tiền:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${processedData['Số tiền'] ?? ''} VND'),
              trailing: Icon(Icons.attach_money),
            ),
            ListTile(
              title: Text('Loại phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(processedData['Loại phương thức thanh toán'] ?? ''),
            ),
            ListTile(
              title: Text('Loại sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(processedData['Loại sản phẩm'] ?? ''),
            ),
            ListTile(
              title: Text('Nơi mua:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(processedData['Nơi mua'] ?? ''),
            ),
            ListTile(
              title: Text('Phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(processedData['Phương thức thanh toán'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
