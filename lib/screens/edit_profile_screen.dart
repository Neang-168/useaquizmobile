import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final Student student;
  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.student.name);
  late final _emailController = TextEditingController(text: widget.student.email);
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AppRepository.instance.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t save changes: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text('Your details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Faculty, major, and academic year are set by the university and can\'t be changed here.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Text('Full Name', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 18),
              Text('Email', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'you@usea.edu.kh',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
