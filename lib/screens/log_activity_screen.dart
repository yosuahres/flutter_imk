import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_imk/db/firestore.dart';

class LogActivityScreen extends StatefulWidget {
  final String category;
  const LogActivityScreen({super.key, required this.category});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final co2e = double.tryParse(_valueController.text.trim());
      if (co2e == null) throw Exception("Invalid CO2e value");

      await _firestoreService.addUserFootprintLog(
        userId: user.uid,
        activityTitle: _titleController.text.trim(),
        co2eKg: co2e,
        category: widget.category,
        date: DateTime.now(),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String label;
    String hint;
    switch (widget.category.toLowerCase()) {
      case 'transport':
        label = "Distance (km)";
        hint = "e.g. 10";
        break;
      case 'home energy':
        label = "Energy Used (kWh)";
        hint = "e.g. 5";
        break;
      case 'food':
        label = "Food CO₂e (kg)";
        hint = "e.g. 1.2";
        break;
      case 'waste':
        label = "Waste CO₂e (kg)";
        hint = "e.g. 0.5";
        break;
      default:
        label = "CO₂e (kg)";
        hint = "e.g. 1.0";
    }

    return Scaffold(
      appBar: AppBar(title: Text('Log ${widget.category}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Activity Title",
                  hintText: "e.g. Car ride, Rice meal, etc.",
                ),
                validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Required";
                  if (double.tryParse(v.trim()) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}