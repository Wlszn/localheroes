import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'role_screen.dart';
import '../../Controllers/auth_controller.dart';
import '../../Models/user_model.dart';
import 'login_screen.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key, required this.selectedRole});

  final Role selectedRole;

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  //initialize auth so we can get the register methods
  final AuthController _authController = AuthController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  //Firebase auth requires password to be atleast 6 characters
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await _authController.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        role: widget.selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User Created: ${user?.name}')));

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      //if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String roleText = widget.selectedRole == Role.seeker ? 'Seeker' : 'Hero';
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Image.asset('assets/minilogo.png')],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        'Sign up as $roleText',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.person),
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            isLoading ? null : register();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5C7CFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Create Account'),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    selectedRole: widget.selectedRole,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Rolescreen()),
                          );
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.black54),
                        label: isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                          'Back to role selection',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
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
