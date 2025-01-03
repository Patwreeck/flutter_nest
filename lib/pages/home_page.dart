import 'package:flutter/material.dart';
import 'package:flutter_nest_ojt/widgets/date_list.dart';
import 'package:flutter_nest_ojt/widgets/header.dart';
import 'package:flutter_nest_ojt/widgets/payroll_card.dart';
import 'package:flutter_nest_ojt/widgets/timer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
Future<String?> fetchFullName() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if(currentUser != null){
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

      if(userDoc.exists){
        return userDoc['full_name'] as String?;
      }
    }

    return null;
  }
  catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Walay naka log in')),
      );
      return  null;
  }
}

Future<String?> fetchUserId() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if(currentUser != null){
        return currentUser.uid;
    }

    return null;
  }
  catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Walay Naka login')),
      );
      return  null;
  }
}


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String?>(
                future: fetchFullName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return HeaderWidget(name: "Loading...");
                  } else if (snapshot.hasError) {
                    return HeaderWidget(name: "Error loading name");
                  } else {
                    return HeaderWidget(name: snapshot.data ?? "No Name Found");
                  }
                },
              ),
              SizedBox(height: 20),
              FutureBuilder<String?>(
                future: fetchUserId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading user ID"));
                  } else {
                    return TimerCard(user_id: snapshot.data ?? "No User");
                  }
                },
              ),
              SizedBox(height: 20),
              FutureBuilder<String?>(
                future: fetchUserId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading user ID"));
                  } else {
                    return PayrollCard(currentUserId: snapshot.data ?? "No User");
                  }
                },
              ),
              SizedBox(height: 20),
              FutureBuilder<String?>(
                future: fetchUserId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading user ID"));
                  } else {
                    return DateListWidget(currentUserId: snapshot.data ?? "No User");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}