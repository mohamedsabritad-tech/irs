import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  List<TransferPlayer> _players = [];
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
      final res = await ApiService.getTransferPlayers();
      if (res['ok'] == true && res['players'] != null) {
        final list = res['players'] as List;
        setState(() => _players = list
            .map((e) => TransferPlayer.fromJson(e as Map<String, dynamic>))
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

  void _addDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Transfer Player'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Game ID'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                await ApiService.addTransferPlayer(ctrl.text);
                _load();
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _promoteDialog(TransferPlayer p) {
    final n = TextEditingController();
    final t = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Promote / Edit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: n,
                decoration: const InputDecoration(labelText: 'Notes')),
            TextField(
                controller: t,
                decoration:
                    const InputDecoration(labelText: 'Furnace Tier (e.g. 10)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                await ApiService.promoteTransferPlayer({
                  'id': p.id,
                  if (n.text.isNotEmpty) 'notes': n.text,
                  if (t.text.isNotEmpty) 'furnaceTier': t.text,
                });
                _load();
              },
              child: const Text('Save')),
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
      appBar: AppBar(title: const Text('Transfer'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _addDialog),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _players.isEmpty
          ? const Center(child: Text('No transfer players'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _players.length,
              itemBuilder: (c, i) {
                final p = _players[i];
                final tier = p.furnaceTier;
                final progress = tier != null ? int.tryParse(tier) ?? 0 : 0;
                final ringColor = progress >= 10
                    ? AppTheme.orange
                    : progress >= 5
                        ? AppTheme.cyan
                        : AppTheme.indigo;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ringColor.withValues(alpha: 0.15),
                      child: Text('${p.level}',
                          style: TextStyle(
                              color: ringColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'K${p.kingdom} · Lv${p.level}${tier != null ? ' · FC$tier' : ''}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _promoteDialog(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await ApiService.deleteTransferPlayer(p.id);
                            _load();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
