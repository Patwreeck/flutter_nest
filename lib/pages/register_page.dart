import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationPasswordController = TextEditingController();
  Map<String, String> errors = {};

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmationPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidName(String name) {
    return name.length >= 3;
  }

  void validateRegister() {
    setState(() {
      errors.clear();
      String email = emailController.text.trim();
      String fullname = fullNameController.text;
      String password = passwordController.text.trim();
      String confirmPassword = confirmationPasswordController.text.trim();

      // Email Validation
      if (email.isEmpty) {
        errors['emailError'] = "Please fill in the Email.";
      } else if (!isValidEmail(email)) {
        errors['emailError'] = "Please provide a valid Email.";
      }

      // Fullname Validation
      if (fullname.isEmpty) {
        errors['fullnameError'] = "Please fill in the Name.";
      } else if (!isValidName(fullname)) {
        errors['fullnameError'] = "Name must have at least 3 characters.";
      }

      // Password Validation
      final hasUppercase = RegExp(r'[A-Z]');
      final hasLowercase = RegExp(r'[a-z]');
      final hasDigit = RegExp(r'\d');
      final hasSpecialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
      final hasMinLength = password.length >= 6;
      List<String> passwordErrors = []; 

      if (password.isEmpty) {
        errors['passwordError'] = "Password cannot be empty.";
      } else {
        if (!hasMinLength) {
          passwordErrors.add("Password should be at least 6 characters.");
        }
        if (!hasUppercase.hasMatch(password)) {
          passwordErrors.add("Password should have at least 1 uppercase letter.");
        }
        if (!hasLowercase.hasMatch(password)) {
          passwordErrors.add("Password should have at least 1 lowercase letter.");
        }
        if (!hasDigit.hasMatch(password)) {
          passwordErrors.add("Password should have at least 1 number.");
        }
        if (!hasSpecialCharacter.hasMatch(password)) {
          passwordErrors.add("Password should have at least 1 symbol.");
        }
      }

      if (passwordErrors.isNotEmpty) {
        errors['passwordError'] = passwordErrors.join("\n");
      }

      // Confirm Password Validation
      if(confirmPassword.isEmpty) {
        errors['confirmPasswordError'] = "Confirm Password cannot be empty.";
      } else if (password != confirmPassword) {
        errors['confirmPasswordError'] = "Passwords do not match.";
      }
    });
  }

  void registerUser(BuildContext context) async {
    validateRegister();
    if (errors.isEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'full_name': fullNameController.text,
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'hourly_rate': 60.54,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Complete! Welcome!')),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

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
              style: TextStyle(fontSize: 22, color: Color(0xFF000000)),
            ),
            SizedBox(height: 20),
            buildTextField(
              controller: fullNameController,
              labelText: 'Full Name',
              errorKey: 'fullnameError',
            ),
            SizedBox(height: 10),
            buildTextField(
              controller: emailController,
              labelText: 'Email',
              errorKey: 'emailError',
            ),
            SizedBox(height: 10),
            buildTextField(
              controller: passwordController,
              labelText: 'Password',
              errorKey: 'passwordError',
              obscureText: true,
            ),
            SizedBox(height: 10),
            buildTextField(
              controller: confirmationPasswordController,
              labelText: 'Confirm Password',
              errorKey: 'confirmPasswordError',
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => registerUser(context),
              child: Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2F2F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 45, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String errorKey,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: errors.containsKey(errorKey) ? Colors.red : Color(0xFFD2D2D2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: errors.containsKey(errorKey) ? Colors.red : Color(0xFFD2D2D2),
                width: 2,
              ),
            ),
          ),
          obscureText: obscureText,
        ),
        if (errors.containsKey(errorKey))
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              errors[errorKey]!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          )   
      ],
    );
  }
}
