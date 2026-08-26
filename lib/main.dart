import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ==================== 1. LOGIN & ONBOARDING ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool isRegistered = false;

  void _handleLogin() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number')),
      );
      return;
    }

    // Admin login shortcut for testing
    if (_phoneController.text == '9999999999') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
      return;
    }

    if (!isRegistered) {
      setState(() {
        isRegistered = true;
      });
    } else {
      if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill name and email for onboarding documents')),
        );
        return;
      }
      // Proceed to Employee Dashboard after document upload simulation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmployeeDashboard(
            employeeName: _nameController.text,
            employeePhone: _phoneController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_center, size: 64, color: Color(0xFF0072FF)),
                  const SizedBox(height: 16),
                  const Text(
                    'KS Infra Interiors',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text('Staff & Site Management Portal', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (isRegistered) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email ID',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Document (Aadhaar/PAN) Uploaded Successfully! Pending Admin Approval.')),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload KYC Documents (ID/PAN)'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0072FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isRegistered ? 'Complete Onboarding & Enter' : 'Continue with Phone'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin Login: Use 9999999999',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 2. EMPLOYEE DASHBOARD ====================
class EmployeeDashboard extends StatefulWidget {
  final String employeeName;
  final String employeePhone;

  const EmployeeDashboard({super.key, required this.employeeName, required this.employeePhone});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool isCheckedIn = false;
  DateTime? checkInTime;
  String siteName = '';
  final _siteController = TextEditingController();
  
  double advanceBalance = 5000.0;
  double totalIncome = 25000.0;
  double reimbursement = 1200.0;
  double penaltyAmount = 0.0;
  double otHours = 0.0;

  final List<Map<String, dynamic>> history = [];

  void _performCheckIn() {
    if (_siteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Site Name')),
      );
      return;
    }

    setState(() {
      isCheckedIn = true;
      checkInTime = DateTime.now();
      siteName = _siteController.text;

      // Rule: Arrival 9:00 AM, Buffer till 9:30 AM. After 9:30 AM -> ₹50 penalty
      final hour = checkInTime!.hour;
      final minute = checkInTime!.minute;
      if (hour > 9 || (hour == 9 && minute > 30)) {
        penaltyAmount += 50.0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Late arrival! ₹50 penalty applied automatically.')),
        );
      }
    });
  }

  void _performCheckOut() {
    if (checkInTime == null) return;
    final checkOutTime = DateTime.now();
    final duration = checkOutTime.difference(checkInTime!);
    
    // 8 Hours standard shift. Anything beyond 8 hours is OT
    double workedHours = duration.inMinutes / 60.0;
    if (workedHours > 8.0) {
      otHours += (workedHours - 8.0);
    }

    setState(() {
      isCheckedIn = false;
      history.insert(0, {
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'site': siteName,
        'checkIn': DateFormat('hh:mm a').format(checkInTime!),
        'checkOut': DateFormat('hh:mm a').format(checkOutTime),
        'ot': (workedHours > 8 ? workedHours - 8 : 0).toStringAsFixed(1),
      });
      siteName = '';
      _siteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checked Out Successfully. Attendance recorded!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.employeeName}'),
        backgroundColor: const Color(0xFF0072FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial & Ledger Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Financial & Ledger Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Income', '₹$totalIncome', Colors.green),
                        _buildStatItem('Advance', '₹$advanceBalance', Colors.orange),
                        _buildStatItem('Reimburse', '₹$reimbursement', Colors.blue),
                        _buildStatItem('Penalty', '₹$penaltyAmount', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Calculated OT Hours: ${otHours.toStringAsFixed(1)} hrs', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Check-in / Check-out Widget
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Site Attendance & GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    if (!isCheckedIn) ...[
                      TextField(
                        controller: _siteController,
                        decoration: InputDecoration(
                          labelText: 'Enter Site Name',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _performCheckIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Check In (GPS Verified)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ] else ...[
                      Text('Active Site: $siteName', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Text('GPS Location: Lat 28.4595, Long 77.0266 (Faridabad)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _performCheckOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Check Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Material & Payment Receipt Upload
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Material & Payment Receipt uploaded successfully. Sent to Admin for approval!')),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Upload Material Bill / Payment Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Past Attendance History
            const Text('Past Attendance History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            history.isEmpty
                ? const Text('No history available yet.', style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Card(
                        child: ListTile(
                          title: Text('Site: ${item['site']} (${item['date']})'),
                          subtitle: Text('In: ${item['checkIn']} | Out: ${item['checkOut']} | OT: ${item['ot']} hrs'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }
}

// ==================== 3. ADMIN DASHBOARD ====================
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal - KS Infra Interiors'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Employee Management & Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Text('RK')),
              title: const Text('Rahul Kumar (Electrician)'),
              subtitle: const Text('Documents: Aadhaar/PAN Uploaded\nStatus: Pending Onboarding Approval'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Employee On Approved List!')),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pending Receipts & Material Bills Approval', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt, color: Colors.purple),
              title: const Text('Material Bill #104 - ₹4,500'),
              subtitle: const Text('Uploaded by: Rahul Kumar\nSite: Sector 29 Interior'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt Approved and Added to Ledger!')),
                ),
                child: const Text('Approve'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
