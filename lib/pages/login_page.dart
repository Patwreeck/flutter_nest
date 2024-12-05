import 'package:flutter/material.dart';
import 'register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  LoginPage({super.key});
  
  void loginUser(BuildContext context) async{
    try {
      if (emailController.text == '' || passwordController.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('May kulang ka!'))
      );
       return;
      }
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, 
        password:  passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pasok ka boy!'))
      );
    }
    catch (toinkError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wrong ka boy!')),
      );
    }
  }


@override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Nest_LogIn.png',
            width: 100,
            height: 100,
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email', 
              labelStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                color: Color(0xFFD2D2D2),
                width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
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
            labelStyle: const TextStyle(
            fontSize: 12,
            color:  Color(0xFF888888)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFFD2D2D2),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFFD2D2D2),
              width: 2,
              
            ),
            ),
            ),
            obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed:() => loginUser(context),
            child:  Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F2F2F),
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
            TextButton(onPressed:(){
              Navigator.push(context, MaterialPageRoute(builder:(context) => RegisterPage()));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: Container(
                  height: 1,
                  color: Color(0xFF888888),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                ),
                ),
                Text('or Register',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                ),
                ),
                Expanded(child: Container(
                  height: 1,
                  color: Color(0xFF888888),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                ),
                ),
              ],
            ),
          ),
        ],
      ), 
      )
    );
  }



}

