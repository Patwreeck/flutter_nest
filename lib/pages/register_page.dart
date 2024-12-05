        
 import 'package:flutter/material.dart';
 import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';



 class RegisterPage extends StatelessWidget{
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationPasswordController = TextEditingController();
   
void registerUser(BuildContext context) async{
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text, 
      password: passwordController.text);
     
     await userCredential.user?.updateDisplayName(fullNameController.text);

     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Register Complete! Bingo!')),
     );

     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
  } catch(error){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${error.toString()}')
      ),
    );
      


  }

}


  RegisterPage({super.key});
 
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF000000)
            ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: fullNameController,
              decoration:  InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Color(0xFFD2D2D2),
                      ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Color(0xFFD2D2D2),
                      width: 2,
                    ),
                  ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration:  InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFD2D2D2),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFD2D2D2),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration:  InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFD2D2D2),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFD2D2D2),
                    width: 2,
                  ),
                ),
                ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmationPasswordController,
              decoration:  InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFD2D2D2),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Color(0xFFD2D2D2),
                    width: 2,
                  ),
                ),
                ),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => registerUser(context),
              child:  Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2F2F2F),
                foregroundColor: Colors.white,
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 45,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 }

