import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lan1111/screens/login_screen.dart';
import '../../screens/notes_page.dart';
import 'package:test_lan1111/services/api_service_in.dart';

class NotePage_inp extends StatefulWidget {
  const NotePage_inp({Key? key}) : super(key: key);

  @override
  State<NotePage_inp> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage_inp> {
  TextEditingController noteController = TextEditingController();
  String errorMessage = '';
  String? jwtToken;
  final ApiServicein apiServicein = ApiServicein();

  @override
  void initState() {
    super.initState();
    _loadJWT();
  }

  _loadJWT() async {
    final prefs = await SharedPreferences.getInstance();
    jwtToken = prefs.getString('jwtToken');
    print(jwtToken);
    setState(() {});
  }

  void submitNote() async {
    String noteText = noteController.text;
    if (noteText.isEmpty) {
      setState(() {
        errorMessage = "Vui lòng nhập nội dung trước khi lưu.";
      });
      return;
    }

    if (jwtToken == null) {
      setState(() {
        errorMessage = "Bạn chưa đăng nhập. Vui lòng đăng nhập trước.";
      });
      return;
    }

    try {
      var response = await apiServicein.submitNote(
        note: noteText,
        jwtToken: jwtToken!,
      );

      if (response.statusCode == 200) {
        setState(() {
          errorMessage = "Dữ liệu đã được gửi thành công";
        });
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NotesPage()),
        );
      } else {
        setState(() {
          errorMessage = "Gửi dữ liệu thất bại: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi khi gửi dữ liệu: $e";
      });
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Loginscreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Sử dụng AppBar thông thường
        title: Text('Ghi chú'),
        backgroundColor: Colors.yellow[500],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotesPage()),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 14)),
            Expanded( // Đảm bảo TextField chiếm phần lớn không gian
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Enter note here',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            ElevatedButton( // Đặt nút "Lưu ghi chú" bên dưới TextField
              onPressed: submitNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
              ),
              child: Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}
