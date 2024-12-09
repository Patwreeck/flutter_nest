import 'package:flutter/material.dart';
import 'package:flutter_nest_ojt/widgets/date_list.dart';
import 'package:flutter_nest_ojt/widgets/header.dart';
import 'package:flutter_nest_ojt/widgets/timer_card.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(name: 'Patrick'),
              SizedBox(height: 20),
              TimerCard(),
              SizedBox(height: 20),
              DateListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}