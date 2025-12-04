import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final nameCtrl = TextEditingController();
  final pinCtrl = TextEditingController();
  final branchCtrl = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref();
  bool _loading = false;

  Future<void> submitForm() async {
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final formName = nameCtrl.text.trim().toLowerCase();
    final formPin = pinCtrl.text.trim();

    if (formName.isEmpty || formPin.isEmpty) {
      setState(() => _loading = false);
      showPopup("Please fill all fields", isSuccess: false);
      return;
    }

    final snapshot = await dbRef.child('Users/$uid').get();
    if (!snapshot.exists) {
      setState(() => _loading = false);
      showPopup("Profile not found.", isSuccess: false);
      return;
    }

    final profile = Map<String, dynamic>.from(snapshot.value as Map);
    final profileName = profile['name'].toString().toLowerCase();
    final profilePin = profile['pin'].toString();

    final nameMatch = profileName.split(" ").any((part) => part == formName);
    final pinMatch = formPin == profilePin;

    if (!nameMatch || !pinMatch) {
      setState(() => _loading = false);
      showPopup("Name or PIN doesn't match", isSuccess: false);
      return;
    }

    final now = DateTime.now().toIso8601String();
    final recordRef = dbRef.child('Users/$uid/Records').push();

    await recordRef.set({
      'name': nameCtrl.text.trim(),
      'pin': formPin,
      'branch': branchCtrl.text.trim(),
      'timestamp': now,
    });

    nameCtrl.clear();
    pinCtrl.clear();
    branchCtrl.clear();

    setState(() => _loading = false);
    showPopup("✅ Record Submitted Successfully!", isSuccess: true);
  }

  void showPopup(String message, {required bool isSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  size: 60,
                  color: isSuccess ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 16, 125, 215),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensures pure white background
      body: SafeArea(
        child: _loading
            ? Center(
                child: Lottie.asset(
                  'assets/load.json',
                  width: 120,
                  height: 120,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color.fromARGB(255, 22, 129, 216),
                      child: Icon(Icons.assignment, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Form Page",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 15, 130, 224),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: pinCtrl,
                            decoration: const InputDecoration(
                              labelText: 'PIN',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: branchCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Branch',
                              prefixIcon: Icon(Icons.school),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : submitForm,
                              style: ElevatedButton.styleFrom(
                                elevation: 6,
                                backgroundColor:
                                    const Color.fromARGB(255, 16, 125, 215),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Submit', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
