import 'package:flutter/material.dart';

class DateListWidget extends StatefulWidget {
  @override
  State<DateListWidget> createState() => _DateListWidgetState();
}

class _DateListWidgetState extends State<DateListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text('Timesheet'),
                Spacer(),
                Text('Total: ')
              ],
            ),
          ),
          SizedBox(
            height: 330,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black,
              color: Color(0xFFF2F2F2),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
  }
}
