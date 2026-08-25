import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const KSInfraApp());
}

class KSInfraApp extends StatelessWidget {
  const KSInfraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KS Infra Interiors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0072FF),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0072FF)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime? punchInTime;
  DateTime? punchOutTime;
  String location = "GPS Pending";
  double regularHours = 0.0;
  double otHours = 0.0;
  double latePenalty = 0.0;
  double advanceBalance = 0.0;
  double reimbursement = 0.0;

  final List<Map<String, dynamic>> bills = [];

  Future<void> _punchIn() async {
    if (_siteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Site Name first!')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    DateTime now = DateTime.now();
    DateTime lateTime = DateTime(now.year, now.month, now.day, 9, 30); // 9:30 AM Buffer

    double penalty = (now.isAfter(lateTime)) ? 50.0 : 0.0;

    setState(() {
      punchInTime = now;
      punchOutTime = null;
      latePenalty = penalty;
      location = "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
    });
  }

  void _punchOut() {
    if (punchInTime == null) return;
    DateTime now = DateTime.now();
    double totalHours = now.difference(punchInTime!).inMinutes / 60.0;

    setState(() {
      punchOutTime = now;
      if (totalHours <= 8.0) {
        regularHours = totalHours;
        otHours = 0.0;
      } else {
        regularHours = 8.0;
        otHours = totalHours - 8.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KS Infra Interiors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0072FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF0072FF), child: Icon(Icons.person, color: Colors.white)),
                title: const Text('Employee: #KS-101'),
                subtitle: Text('Status: Active | GPS: $location'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _siteController,
                      decoration: const InputDecoration(labelText: 'Site Name / Client Project', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: punchInTime == null ? _punchIn : null,
                            child: Text(punchInTime == null ? 'Punch In (9:00 AM)' : DateFormat('hh:mm a').format(punchInTime!), style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: (punchInTime != null && punchOutTime == null) ? _punchOut : null,
                            child: Text(punchOutTime == null ? 'Punch Out' : DateFormat('hh:mm a').format(punchOutTime!), style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    if (latePenalty > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Late Penalty Applied: ₹$latePenalty', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    if (regularHours > 0 || otHours > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Regular: ${regularHours.toStringAsFixed(1)}h | OT: ${otHours.toStringAsFixed(1)}h', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
