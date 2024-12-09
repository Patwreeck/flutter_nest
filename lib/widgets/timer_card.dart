import 'package:flutter/material.dart';

class TimerCard extends StatefulWidget {
  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  String status = "Not Started";
  Duration duration = Duration.zero;

  late final Stopwatch stopwatch;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
  }

  void startStopTimer() {
    if (status == "Clocked In" || status == "Clocked Out") {
      stopwatch.stop();
      setState(() {
        status = "Clocked Out";
      });
    } else {
      stopwatch.start();
      updateTime();
      setState(() {
        status = "Clocked In";
      });
    }
  }

  void updateTime() {
    if (stopwatch.isRunning) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          duration = stopwatch.elapsed;
        });
        updateTime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      SizedBox(width: 8),
                      Text(
                        'hrs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    status == "Clocked In"
                        ? "You have clocked in at 8:45am"
                        : status == "Clocked Out"
                            ? "You have clocked out"
                            : "You have not clocked in for today",
                    style: TextStyle(
                      fontSize: 12,
                      color: status == "Clocked In"
                          ? Color(0xFF60BE9F)
                          : (status == "Clocked Out"
                              ? Color(0xFFBE3535)
                              : Color(0xFF888888)),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (status != "Clocked Out") ...[
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
