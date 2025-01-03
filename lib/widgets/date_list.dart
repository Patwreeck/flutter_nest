import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateListWidget extends StatefulWidget {
  final String currentUserId;

  const DateListWidget({required this.currentUserId});

  @override
  State<DateListWidget> createState() => _DateListWidgetState();
}

class _DateListWidgetState extends State<DateListWidget> {
  late DateTime weekStart;
  late DateTime weekEnd;
  String formattedWeekStart = "";
  String formattedWeekEnd = "";
  late String currentWeekLabel;

  @override
  void initState() {
    super.initState();
    initializeWeekDates();
  }

  void initializeWeekDates() {
    DateTime now = DateTime.now();
    int weekday = now.weekday;

    weekStart = now.subtract(Duration(days: weekday - 1));
    weekEnd = now.add(Duration(days: 7 - weekday));
    formattedWeekStart = DateFormat('yyyy-MM-dd').format(weekStart);
    formattedWeekEnd = DateFormat('yyyy-MM-dd').format(weekEnd);

    currentWeekLabel =
        "${DateFormat('MMMM d').format(weekStart)} - ${DateFormat('MMMM d, y').format(weekEnd)}";
  }

  String formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  String calculateRenderedTime(DateTime timeIn, DateTime timeOut) {
    final duration = timeOut.difference(timeIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} hrs";
  }

  DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        if (RegExp(r'^\w+ \d{1,2}, \d{4}$').hasMatch(value)) {
          return DateFormat('yyyy-MM-dd').parse(value);
        } else if (RegExp(r'^\d{1,2}:\d{2} (AM|PM)$').hasMatch(value)) {
          final time = DateFormat('h:mm a').parse(value);
          return DateTime(1970, 1, 1, time.hour, time.minute);
        }
      }
    } catch (e) {
      debugPrint("Invalid date/time format: $value. Error: $e");
    }

    return null;
  }

  bool isTodayOrBefore(DateTime date) {
    DateTime now = DateTime.now();
    return date.isBefore(now) || date.isAtSameMomentAs(now);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                'Timesheet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                currentWeekLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('duty_details')
                    .where('user_id', isEqualTo: widget.currentUserId)
                    .where('date', isGreaterThanOrEqualTo: formattedWeekStart)
                    .where('date', isLessThanOrEqualTo: formattedWeekEnd)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading data"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No data available for this week"));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final dayOfWeek = weekEnd.subtract(Duration(days: index));

                      if (!isTodayOrBefore(dayOfWeek)) {
                        return SizedBox.shrink();
                      }

                      QueryDocumentSnapshot<Object?>? entry;
                      final normalizedDayOfWeek = DateTime(dayOfWeek.year, dayOfWeek.month, dayOfWeek.day);

                       for (var doc in docs ) {
                          final entryDate = DateFormat('yyyy-MM-dd').parse(doc['date']);
                          final normalizedEntryDate = DateTime(entryDate.year, entryDate.month, entryDate.day);
                          
                          if (normalizedEntryDate.isAtSameMomentAs(normalizedDayOfWeek)) {
                            entry = doc;
                            break;
                          }
                        }
                      
                      final formattedDate = DateFormat('MMMM d, y').format(dayOfWeek);
                      final timeIn = entry != null ? parseDateTime(entry['time_in']) : null;
                      final timeOut = entry != null ? parseDateTime(entry['time_out']) : null;
                      final renderedTime = (timeIn != null && timeOut != null)
                          ? calculateRenderedTime(timeIn, timeOut)
                          : "--:-- hrs";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF3B3B3B),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  if (timeIn != null && timeOut != null)
                                    Text(
                                      "${formatTime(timeIn)} - ${formatTime(timeOut)}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                  if (timeIn == null && timeOut == null)
                                    Text(
                                      "No Entry ",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  renderedTime,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
