import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool allowNotifications = true;
  double muteDuration = 0; // in hours

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notification Settings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Allow Notifications Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Allow Notifications",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Switch(
                      value: allowNotifications,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          muteDuration = (value as double).clamp(0.0, 24.0);
                        });
                      }),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Mute Notifications Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mute Notifications (hours)",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Slider(
                    value: muteDuration,
                    min: 0,
                    max: 24,
                    divisions: 24,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    label: "${muteDuration.toInt()} hrs",
                    onChanged: (value) {
                      setState(() {
                        muteDuration = value;
                      });
                      // Implement mute logic (e.g., store in Firebase/local storage)
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
