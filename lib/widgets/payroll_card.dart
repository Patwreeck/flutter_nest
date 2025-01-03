import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PayrollCard extends StatefulWidget {
  final String currentUserId;

  const PayrollCard({required this.currentUserId});

  @override
  State<PayrollCard> createState() => _PayrollCardState();
}

class _PayrollCardState extends State<PayrollCard> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  String calculateTotalTime(List<QueryDocumentSnapshot> docs) {
    int totalMinutes = 0;

    DateTime parseDateTime(String value) {
      if (value.isEmpty) {
        throw Exception("Empty date/time string provided.");
      }

      try {
        final time = DateFormat('h:mm a').parse(value);
        return DateTime(1970, 1, 1, time.hour, time.minute);
      } catch (e) {
        throw Exception("Invalid time format: $value. Expected format: 'h:mm a'.");
      }
    }
    

    for (var doc in docs) {
      debugPrint('Document ID: ${doc.id}');
      try {
        DateTime timeIn = parseDateTime(doc['time_in']);
        DateTime timeOut = parseDateTime(doc['time_out']);

        totalMinutes += timeOut.difference(timeIn).inMinutes;
        
      } catch (e) {
        print("Error parsing document ${doc.id}: $e");
      }
    }

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  Duration parseDuration(String time) {
  final parts = time.split(' ')[0].split(':');
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  return Duration(hours: hours, minutes: minutes);
}

double calculatePay(Map<String, dynamic> userData, String totalTimeString) {
  final hourlyRate = userData['hourly_rate'] ?? 0.00;
  final totalTime = parseDuration(totalTimeString);

  final totalHours = totalTime.inMinutes / 60.0;
  return (totalHours * hourlyRate).toDouble();
}

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    DateTime weekStart = now.subtract(Duration(days: weekday - 1));
    DateTime weekEnd = now.add(Duration(days: 7 - weekday));
    String formattedWeekStart = DateFormat('yyyy-MM-dd').format(weekStart);
    String formattedWeekEnd = DateFormat('yyyy-MM-dd').format(weekEnd);
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('duty_details')
              .where('user_id', isEqualTo: widget.currentUserId)
              .where('date', isGreaterThanOrEqualTo: formattedWeekStart)
              .where('date', isLessThanOrEqualTo: formattedWeekEnd)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text('Loading...'),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text('Error loading data'),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text('Payroll'),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text('Payroll'),
                ],
              ),
            );
          },
        ),
        SizedBox(
          height: 110,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black,
            color: Color(0xFFF2F2F2),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('duty_details')
                  .where('user_id', isEqualTo: widget.currentUserId)
                  .where('date', isGreaterThanOrEqualTo: formattedWeekStart)
                  .where('date', isLessThanOrEqualTo: formattedWeekEnd)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error loading data"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No data available"));
                }
                final totalTime = calculateTotalTime(snapshot.data!.docs);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Hours worked",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B3B3B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${totalTime} hrs',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F2E2E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Total this week",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B3B3B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserId)
                                  .snapshots(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }

                                    if (userSnapshot.hasError) {
                                      return Center(child: Text("Error loading data"));
                                    }

                                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                      return Center(child: Text("No data available"));
                                    }
                                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                    final totalPay = calculatePay(userData, totalTime);
                                    return Text(
                                      '₱${totalPay.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2F2E2E),
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ],
                        ),  
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
