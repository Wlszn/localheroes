import 'package:flutter/material.dart';
import 'role_screen.dart';
import '../Controllers/auth.dart';
import '../Models/user_model.dart';
import 'register_screen.dart';

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

  Future<void> login() async{
    setState(()  {
      isLoading = true;
    });

      try{
        final user = await _authController.loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),

        );
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Logged in: ${user.user?.email}')));
      }
      catch(e){
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally{
        setState(() {
          isLoading = false;
        });
      }
  }


  @override
  Widget build(BuildContext context) {
    String roleText = widget.selectedRole == Role.seeker ? 'Seeker' : 'Hero';
    return  Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
              child:    Card(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/minilogo.png')
                          ]
                      ),
                      SizedBox(height: 20,),
                      Text('Welcome Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,)),
                      Text('Sign in as $roleText'),
                      SizedBox(height: 20,),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => Forgotpassword()));
                          }, child: Text('Forgot Password?', style: TextStyle(color: Colors.blue[800]),))
                        ],
                      ),
                      ElevatedButton(onPressed: (){
                       isLoading ? null : login();
                      }, child: Text('Sign in'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don\'t have an account?'),
                          TextButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Registerscreen(selectedRole: widget.selectedRole,)));
                          }, child: Text('Signup', style: TextStyle(color: Colors.blue[800]),))
                        ],
                      ),
                          TextButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Rolescreen()));
                          }, child: isLoading ?
                          const CircularProgressIndicator()
                          : const Text('<- Back to role selection',))
                    ],
                  ),
                ),
              ),
            ),
        ]
        )
      )
    );
  }
}
