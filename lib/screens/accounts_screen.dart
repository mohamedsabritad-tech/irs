import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getAccounts();
      if (res['ok'] == true && res['accounts'] != null) {
        final list = res['accounts'] as List;
        setState(() => _accounts = list
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList());
      } else {
        setState(() => _error = res['error'] as String? ?? 'Load failed');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await ApiService.deleteAccount(id);
    _load();
  }

  void _addDialog() {
    final f1 = TextEditingController();
    final f2 = TextEditingController();
    final f3 = TextEditingController();
    final f4 = TextEditingController();
    final f5 = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: f1,
                  decoration: const InputDecoration(labelText: 'Game ID')),
              TextField(
                  controller: f2,
                  decoration: const InputDecoration(labelText: 'Nickname')),
              TextField(
                  controller: f3,
                  decoration: const InputDecoration(labelText: 'Level')),
              TextField(
                  controller: f4,
                  decoration: const InputDecoration(labelText: 'Kingdom')),
              TextField(
                  controller: f5,
                  decoration: const InputDecoration(labelText: 'Alliance Tag (opt)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                await ApiService.addAccount({
                  'gameId': f1.text,
                  'nickname': f2.text,
                  'level': f3.text,
                  'kingdom': f4.text,
                  'allianceTag': f5.text,
                });
                _load();
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _batchAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Batch Add (JSON array)'),
        content: TextField(
          controller: ctrl,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '[{"gameId":"123","nickname":"x","level":"30","kingdom":"k100"}]',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                try {
                  final parsed = jsonDecode(ctrl.text);
                  await ApiService.batchAddAccounts({'accounts': parsed});
                  _load();
                } catch (_) {}
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _addDialog),
        IconButton(icon: const Icon(Icons.playlist_add), onPressed: _batchAddDialog),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _accounts.isEmpty
          ? const Center(child: Text('No accounts yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _accounts.length,
              itemBuilder: (c, i) {
                final a = _accounts[i];
                final tier = a.furnaceTier;
                final progress = tier != null ? int.tryParse(tier) ?? 1 : 0;
                final ringColor = progress >= 10
                    ? AppTheme.orange
                    : progress >= 5
                        ? AppTheme.cyan
                        : AppTheme.indigo;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ringColor.withValues(alpha: 0.15),
                      child: Text('${a.level}',
                          style: TextStyle(color: ringColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(a.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'K${a.kingdom} · Lv${a.level}${a.allianceTag != null && a.allianceTag!.isNotEmpty ? ' · [${a.allianceTag}]' : ''}${tier != null ? ' · FC$tier' : ''}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _delete(a.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
