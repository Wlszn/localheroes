import 'package:flutter/material.dart';
import '../hero/hero_main_screen.dart';
import 'role_screen.dart';
import '../../Controllers/auth_controller.dart';
import '../../Models/user_model.dart';
import 'register_screen.dart';
import '../seeker/seeker_main_screen.dart';

//Screen that handles the login form

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.selectedRole});

  final Role selectedRole;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //initialize auth so we can get the login methods
  final AuthController _authController = AuthController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await _authController.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Logged in: ${user.user?.email}')),
      );

      _emailController.clear();
      _passwordController.clear();

      if (widget.selectedRole == Role.seeker) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SeekerMainScreen()),
        );
      } else if (widget.selectedRole == Role.hero) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HeroMainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
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
                        'Welcome Back',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Text('Sign in as $roleText'),
                      SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => Forgotpassword()));
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5C7CFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Sign in'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Registerscreen(
                                    selectedRole: widget.selectedRole,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Signup',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Rolescreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                        ),
                        label: isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                'Back to role selection',
                                style: TextStyle(color: Colors.black54),
                              ),
                      ),
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
