import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter_nest_ojt/pages/login_page.dart';

class HeaderWidget extends StatefulWidget {
  final String? name;

  const HeaderWidget({
    required this.name,
  });

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String? profilePictureUrl;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final List<Map<String, String>> teamMembers = [
    {
      'name': 'Neil Patrick Milan',
      'profilePicture': 'assets/images/team_member_1.jpg',
    },
    {
      'name': 'Angelo Albania',
      'profilePicture': 'assets/images/team_member_2.jpg',
    },
    {
      'name': 'Mohammad Ibrahim ',
      'profilePicture': 'assets/images/team_member_3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.photoURL != null) {
        setState(() {
          profilePictureUrl = user!.photoURL;
        });
      }
    } catch (e) {
      print("Error loading profile picture: $e");
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("User not signed in");

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg');

        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();

        await user.updatePhotoURL(downloadUrl);

        setState(() {
          profilePictureUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile picture updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error changing profile picture: $e")),
        );
      }
    }
  }

  void _showTeamModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          child: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "The Team",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = teamMembers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(member['profilePicture']!), 
                        ),
                        title: Text(member['name']!),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, ${widget.name}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (userSnapshot.hasError) {
                      return Center(child: Text("Error loading data"));
                    }

                    if (!userSnapshot.hasData ||
                        !userSnapshot.data!.exists) {
                      return Center(child: Text("No data available"));
                    }
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final hourlyRate = userData['hourly_rate'] ?? 0;
                    return Text(
                      'Hourly Rate: ₱${hourlyRate}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF888888),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(1000, 80, 10, 0),
                items: [
                  PopupMenuItem<String>(
                    value: 'profile_picture',
                    child: Text('Change Picture'),
                  ),
                  PopupMenuItem<String>(
                    value: 'team',
                    child: Text('Team'),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Sign Out'),
                  ),
                ],
              );

              if (result == 'logout') {
                _signOut(context);
              } else if (result == 'profile_picture') {
                _changeProfilePicture();
              } else if (result == 'team') {
                _showTeamModal();
              }
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: profilePictureUrl != null
                  ? NetworkImage(profilePictureUrl!)
                  : AssetImage('assets/images/profile_pic.avif')
                      as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }
}
