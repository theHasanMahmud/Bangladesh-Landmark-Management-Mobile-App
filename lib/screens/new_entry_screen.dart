import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../utils/image_utils.dart';

class NewEntryScreen extends StatefulWidget {
  final Landmark? landmark;
  final bool embedded;
  const NewEntryScreen({super.key, this.landmark, this.embedded = false});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _latCtl = TextEditingController();
  final _lonCtl = TextEditingController();
  File? _imageFile;
  String? _webImagePath;
  bool _submitting = false;
  bool _locating = false;

  final ApiService _api = ApiService();
  final DbService _db = DbService();
  Landmark? get _initial => widget.landmark;

  @override
  void initState() {
    super.initState();
    if (_initial != null) {
      _titleCtl.text = _initial!.title;
      _latCtl.text = _initial!.lat.toString();
      _lonCtl.text = _initial!.lon.toString();
    } else {
      _prefillCurrentLocation(silent: true);
    }
  }

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
      if (kIsWeb) {
        setState(() {
          _webImagePath = x.path;
          _imageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Web preview set. Uploads work best on mobile builds.')));
      } else {
        final resized = await ImageUtils.resizeToFile(File(x.path), 800, 600);
        setState(() => _imageFile = resized);
      }
    }
  }

  Future<void> _prefillCurrentLocation({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable location services to autofill coordinates')));
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        _latCtl.text = position.latitude.toStringAsFixed(6);
        _lonCtl.text = position.longitude.toStringAsFixed(6);
      });
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coordinates updated from GPS')));
      }
    } catch (e) {
      if (!silent && mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(title: const Text('Location error'), content: Text(e.toString()), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  String? _validateCoordinate(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final parsed = double.tryParse(v);
    if (parsed == null) return 'Invalid number';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final lat = double.tryParse(_latCtl.text) ?? 0.0;
    final lon = double.tryParse(_lonCtl.text) ?? 0.0;
    final landmark = Landmark(id: _initial?.id, title: _titleCtl.text, lat: lat, lon: lon, imageUrl: _initial?.imageUrl);
    try {
      if (_initial != null && _initial!.id != null) {
        final ok = await _api.update(landmark, imageFile: kIsWeb ? null : _imageFile);
        if (ok) {
          if (_db.supported) {
            await _db.insert(landmark);
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
          Navigator.of(context).pop();
        } else {
          throw Exception('Update failed');
        }
      } else {
        final id = await _api.create(landmark, imageFile: kIsWeb ? null : _imageFile);
        final created = Landmark(id: id, title: landmark.title, lat: landmark.lat, lon: landmark.lon, imageUrl: null);
        if (_db.supported) {
          await _db.insert(created);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Created')));
        _formKey.currentState?.reset();
        setState(() {
          _imageFile = null;
          _webImagePath = null;
        });
      }
    } catch (e) {
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(_initial == null ? 'New Landmark' : 'Edit Landmark')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextFormField(controller: _latCtl, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: _validateCoordinate),
              TextFormField(controller: _lonCtl, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: _validateCoordinate),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _locating ? null : () => _prefillCurrentLocation(),
                      icon: _locating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
                      label: const Text('Use current location'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 180, fit: BoxFit.cover)
              else if (_webImagePath != null)
                Image.network(_webImagePath!, height: 180, fit: BoxFit.cover)
              else
                const SizedBox(height: 180, child: Center(child: Text('No image'))),
              if (kIsWeb)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Images are previewed in browser but uploaded on mobile builds.', style: TextStyle(color: Colors.orange)),
                ),
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
