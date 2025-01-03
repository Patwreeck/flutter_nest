import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimerCard extends StatefulWidget {
  final String? user_id;

  const TimerCard({
    required this.user_id,
  });

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  String status = "Not Started";
  Duration duration = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    checkStatus();
    startRealtimeTimer();
  }

  void checkStatus() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dutyEntry = await FirebaseFirestore.instance
        .collection('duty_details')
        .where('user_id', isEqualTo: widget.user_id)
        .where('date', isEqualTo: today)
        .limit(1)
        .get();

    if (dutyEntry.docs.isNotEmpty) {
      final data = dutyEntry.docs.first.data();
      String? timeIn = data['time_in'];
      String? timeOut = data['time_out'];
      String? fetchedStatus = data['status'];

      if (mounted) {
        setState(() {
          status = fetchedStatus ?? "Not Started";

          if (timeIn != null && timeOut == null) {
            DateTime timeInParsed = DateFormat('h:mm a').parse(timeIn);
            duration = DateTime.now().difference(timeInParsed);
          } else if (timeIn != null && timeOut != null) {
            DateTime timeInParsed = DateFormat('h:mm a').parse(timeIn);
            DateTime timeOutParsed = DateFormat('h:mm a').parse(timeOut);
            duration = timeOutParsed.difference(timeInParsed);
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          status = "Not Started";
          duration = Duration.zero;
        });
      }
    }
  }

  void startStopTimer() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String nowTime = DateFormat('h:mm a').format(DateTime.now());

    final dutyEntry = await FirebaseFirestore.instance
        .collection('duty_details')
        .where('user_id', isEqualTo: widget.user_id)
        .where('date', isEqualTo: today)
        .limit(1)
        .get();

    if (status == "Clocked Out") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have already clocked out for today!")),
      );
      return;
    }

    if (dutyEntry.docs.isEmpty) {
      
      await FirebaseFirestore.instance.collection('duty_details').add({
        'date': today,
        'time_in': nowTime,
        'time_out': nowTime,
        'status': "Clocked In",
        'user_id': widget.user_id,
      });
      if (mounted) {
        setState(() {
          status = "Clocked In";
          duration = Duration.zero;
        });
      }
    } else {
      
      String docId = dutyEntry.docs.first.id;
      await FirebaseFirestore.instance
          .collection('duty_details')
          .doc(docId)
          .update({
        'time_out': nowTime,
        'status': "Clocked Out",
      });
      if (mounted) {
        setState(() {
          status = "Clocked Out";
        });
      }
    }
  }

  void startRealtimeTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (status == "Clocked In") {
        setState(() {
          duration += Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: 560,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black,
        color: Color(0xFFF2F2F2),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w500,
                  color: status == "Clocked In"
                      ? Color(0xFF60BE9F)
                      : Color(0xFF000000),
                ),
              ),
              Text(
                status == "Clocked In"
                    ? "You have clocked in"
                    : status == "Clocked Out"
                        ? "${DateFormat('MMMM d, y').format(DateTime.now())}"
                        : "You have not clocked in for today",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
              SizedBox(height: 16),
              if (status != "Clocked Out")
                ElevatedButton(
                  onPressed: startStopTimer,
                  child: Text(
                    status == "Clocked In" ? "Clock Out" : "Clock In",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == "Clocked In"
                        ? Color(0xFFBE3535)
                        : Color(0xFF60BE9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
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
      ),
    );
  }
}
