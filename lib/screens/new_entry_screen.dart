import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../utils/image_utils.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _latCtl = TextEditingController();
  final _lonCtl = TextEditingController();
  File? _imageFile;
  bool _submitting = false;

  final ApiService _api = ApiService();
  final DbService _db = DbService();

  @override
  void dispose() {
    _titleCtl.dispose();
    _latCtl.dispose();
    _lonCtl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final x = await p.pickImage(source: ImageSource.gallery);
    if (x != null) {
      final resized = await ImageUtils.resizeToFile(File(x.path), 800, 600);
      setState(() => _imageFile = resized);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final landmark = Landmark(title: _titleCtl.text, lat: double.parse(_latCtl.text), lon: double.parse(_lonCtl.text));
    try {
      final id = await _api.create(landmark, imageFile: _imageFile);
      final created = Landmark(id: id, title: landmark.title, lat: landmark.lat, lon: landmark.lon, imageUrl: null);
      await _db.insert(created);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Created')));
      _formKey.currentState?.reset();
      setState(() => _imageFile = null);
    } catch (e) {
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Landmark')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextFormField(controller: _latCtl, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextFormField(controller: _lonCtl, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _imageFile != null ? Image.file(_imageFile!, height: 180, fit: BoxFit.cover) : const SizedBox(height: 180, child: Center(child: Text('No image'))),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Select Image')))]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _submitting ? null : _submit, child: _submitting ? const CircularProgressIndicator() : const Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
