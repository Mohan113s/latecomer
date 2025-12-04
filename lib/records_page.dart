import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // For formatting timestamp
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class RecordCleanupInput {
  final Map rawData;
  final String uid;
  RecordCleanupInput({required this.rawData, required this.uid});
}

Map<String, dynamic> cleanRecordsInIsolate(RecordCleanupInput input) {
  final now = DateTime.now();
  final List<Map<String, dynamic>> validRecords = [];
  final List<String> expiredKeys = [];

  for (final entry in input.rawData.entries) {
    final key = entry.key;
    final data = Map<String, dynamic>.from(entry.value);
    final timestamp = DateTime.tryParse(data['timestamp'] ?? '');

    if (timestamp != null) {
      final diffInHours = now.difference(timestamp).inHours;
      if (diffInHours < 144) {
        data['key'] = key;
        validRecords.add(data);
      } else {
        expiredKeys.add(key);
      }
    }
  }

  return {
    'records': validRecords,
    'expiredKeys': expiredKeys,
  };
}

class _RecordsPageState extends State<RecordsPage> {
  final dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> userRecords = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await dbRef.child('Users/$uid/Records').get();

    if (snap.exists) {
      final rawMap = Map<String, dynamic>.from(snap.value as Map);
      final result = await compute(cleanRecordsInIsolate,
          RecordCleanupInput(rawData: rawMap, uid: uid));

      userRecords = List<Map<String, dynamic>>.from(result['records'] ?? []);

      for (final key in result['expiredKeys'] ?? []) {
        await dbRef.child('Users/$uid/Records/$key').remove();
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 157, 156, 156),
                Color.fromARGB(255, 252, 252, 252),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30, left: 24, bottom: 10),
                child: Text(
                  "📋 Your Records",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color.fromARGB(255, 13, 95, 175),
                  ),
                ),
              ),
              Expanded(
                child: loading
                    ? Center(
                        child: Lottie.asset(
                          'assets/load.json',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      )
                    : userRecords.isEmpty
                        ? const Center(
                            child: Text(
                              "No records found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            itemCount: userRecords.length,
                            itemBuilder: (context, index) {
                              final record = userRecords[index];
                              final dateTime = DateTime.tryParse(
                                      record['timestamp'] ?? '') ??
                                  DateTime.now();
                              final formattedDate =
                                  DateFormat('dd-MM-yyyy').format(dateTime);
                              final formattedTime =
                                  DateFormat('hh:mm a').format(dateTime);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "#${index + 1}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 22, 100, 170),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.person,
                                            color: Color.fromARGB(
                                                255, 16, 125, 215)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            record['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.lock,
                                            color: Color.fromARGB(
                                                255, 11, 139, 213)),
                                        const SizedBox(width: 8),
                                        Text("PIN: ${record['pin']}"),
                                      ],
                                    ),
                                    if (record['branch'] != null &&
                                        record['branch']
                                            .toString()
                                            .isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.school,
                                                color: Color.fromARGB(
                                                    255, 10, 131, 197)),
                                            const SizedBox(width: 8),
                                            Text(
                                                "Branch: ${record['branch']}"),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            color: Color.fromARGB(
                                                255, 51, 93, 238),
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 56, 56, 56),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.access_time,
                                            color: Color.fromARGB(
                                                255, 228, 84, 63),
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 56, 56, 56),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
