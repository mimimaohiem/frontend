import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'login_screen.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({Key? key}) : super(key: key);

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = ''; // Biến để lưu thông báo lỗi
  void signup(String username, password) async {
    setState(() {
      errorMessage = ''; // Xóa thông báo lỗi cũ mỗi khi thử đăng nhập mới
    });
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please fill all fields";
      });
      return;
    }



    try {
      Response response = await post(
        Uri.parse("http://10.0.2.2:8888/signup"),
        body: jsonEncode({'username': username, 'password': password}), // Mã hóa body thành JSON
        headers: {'Content-Type': 'application/json'}, // Đặt Content-Type là application/json
      );
      if (response.statusCode == 201) {
        var data = jsonDecode(response.body.toString());
        print(data);
        print("Account Created Successfully");
        setState(() {
          errorMessage = "Account Created Successfully";
        });
      }else if  (response.statusCode == 409) {
        print("User already exists");
        setState(() {
          errorMessage = "User already exists";
        });
      }else {
        print("Operation Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sign Up"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Image(
              image: NetworkImage(
                  "https://cdni.iconscout.com/illustration/premium/thumb/user-account-sign-up-4489360-3723267.png"),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "Email"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: "Password"),
              ),
            ),
            Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 14)), // Hiển thị thông báo lỗi
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: () {
                  signup(emailController.text.toString(),
                      passwordController.text.toString());
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.amber),
                  child: const Center(
                    child: Text(
                      "Sign Up",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Already have an Account?"),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Loginscreen()));
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
