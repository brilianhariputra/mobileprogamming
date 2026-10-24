import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserFormPage extends StatefulWidget {
  final UserModel? user; // null = create, ada isi = edit
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserService();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  bool _loading = false;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user?.firstName ?? '');
    _lastName = TextEditingController(text: widget.user?.lastName ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final input = UserModel(
      id: widget.user?.id,
      email: _email.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      avatar: widget.user?.avatar ?? '',
    );

    try {
      final result = _isEdit
          ? await _service.updateUser(input)
          : await _service.createUser(input);
      if (!mounted) return;
      Navigator.pop(context, result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terjadi kesalahan tidak terduga.'),
            backgroundColor: Colors.red),
      );
    }
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit User' : 'Tambah User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(
                    labelText: 'First name', border: OutlineInputBorder()),
                validator: (v) => _required(v, 'First name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(
                    labelText: 'Last name', border: OutlineInputBorder()),
                validator: (v) => _required(v, 'Last name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) {
                  final err = _required(v, 'Email');
                  if (err != null) return err;
                  if (!v!.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEdit ? 'Simpan Perubahan' : 'Buat User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}