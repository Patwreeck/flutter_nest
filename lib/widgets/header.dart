import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String name;

  const HeaderWidget({
    required this.name,
  });

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
                  "Hi, $name",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Today is the day",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/profile_pic.avif'),
          
          ),
        ],
      ),
    );
  }
}