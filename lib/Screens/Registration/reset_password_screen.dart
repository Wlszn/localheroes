import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  String message = '';

  Future<void> resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      setState(() {
        message = "Reset link sent. Check your email.";
      });
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     "Reset Password",
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: Color(0xFF5C7CFF),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 30,
                    vertical: 30,
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Image.asset('assets/minilogo.png')],
                      ),

                      SizedBox(height: 20),

                      Text(
                        "Reset Password",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),

                      SizedBox(height: 30),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      SizedBox(
                        width: 190,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: resetPassword,
                          icon: Icon(Icons.email_sharp, size: 20),
                          iconAlignment: IconAlignment.end,
                          label: Text(
                            "Send Reset Link",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.black87,
                        ),
                        label: Text(
                          "Back to Login",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      Text(message),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
