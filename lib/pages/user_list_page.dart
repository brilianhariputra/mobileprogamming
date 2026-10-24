import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import 'user_form_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _service = UserService();
  List<UserModel> _users = [];
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() async {
    _users = await _service.getUsers();
  }

  void _reload() => setState(() => _future = _load());

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  Future<void> _openForm([UserModel? user]) async {
    final result = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
    );
    if (result == null || !mounted) return;

    setState(() {
      if (user == null) {
        _users.insert(0, result);
      } else {
        final i = _users.indexWhere((u) => u.id == user.id);
        if (i != -1) _users[i] = result;
      }
    });
    _snack(user == null
        ? 'User "${result.fullName}" berhasil dibuat'
        : 'User "${result.fullName}" berhasil diperbarui');
  }

  Future<void> _delete(UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus user?'),
        content: Text('${user.fullName} akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true || user.id == null) return;

    try {
      await _service.deleteUser(user.id!);
      if (!mounted) return;
      setState(() => _users.removeWhere((u) => u.id == user.id));
      _snack('User "${user.fullName}" berhasil dihapus');
    } on ApiException catch (e) {
      if (!mounted) return;
      _snack(e.message, error: true);
    }
  }

  Widget _avatar(UserModel u) {
    if (u.avatar.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(u.avatar));
    }
    return CircleAvatar(
        child: Text(u.firstName.isEmpty ? '?' : u.firstName[0].toUpperCase()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            final msg = err is ApiException
                ? err.message
                : 'Terjadi kesalahan tidak terduga.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(msg, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _reload, child: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }
          if (_users.isEmpty) {
            return const Center(child: Text('Belum ada data user.'));
          }
          return ListView.separated(
            itemCount: _users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final u = _users[i];
              return ListTile(
                leading: _avatar(u),
                title: Text(u.fullName),
                subtitle: Text(u.email),
                onTap: () => _openForm(u),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(u),
                ),
              );
            },
          );
        },
      ),
    );
  }
}