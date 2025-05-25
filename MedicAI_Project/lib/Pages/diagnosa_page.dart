  import 'package:flutter/material.dart';

class DiagnosisScreen extends StatefulWidget {
  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final List<String> symptoms = [
    "Demam",
    "Batuk",
    "Sesak Nafas",
    "Berkeringat",
    "Sakit Kepala",
    "Mual",
    "Kehilangan nafsu makan",
    "Sakit dibelakang mata",
    "Diare",
    "Detak jantung cepat",
    "Pusing"
  ];

  Map<String, bool> selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    for (var symptom in symptoms) {
      selectedSymptoms[symptom] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Icon(Icons.favorite, color: Colors.green),
                SizedBox(width: 8),
                Text("MedicAI Diagnose",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            SizedBox(height: 20),

            // Judul
            Text("Pilih Gejala",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),
            ...symptoms.map((symptom) => CheckboxListTile(
                  title: Text(symptom,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  value: selectedSymptoms[symptom],
                  onChanged: (value) {
                    setState(() {
                      selectedSymptoms[symptom] = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                )),

            // Dropdown untuk gejala lainnya
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Pencet untuk gejala lainnya",
                  border: UnderlineInputBorder(),
                ),
                items: [],
                onChanged: null, // Fungsi bisa ditambahkan nanti
              ),
            ),

            // Tombol Diagnosa
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aksi diagnosa
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Diagnosa",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
