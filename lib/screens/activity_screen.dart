import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<ActivityEntry> _entries = [];
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
      final res = await ApiService.getActivity();
      if (res['ok'] == true && res['data'] != null) {
        final list = res['data'] as List;
        setState(() => _entries = list
            .map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _entries.isEmpty
          ? const Center(child: Text('No activity'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _entries.length,
              itemBuilder: (c, i) {
                final e = _entries[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.indigo.withValues(alpha: 0.15),
                      child: const Icon(Icons.history, color: AppTheme.indigo, size: 20),
                    ),
                    title: Text(e.action ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (e.details != null && e.details!.isNotEmpty)
                          Text(e.details!, style: const TextStyle(color: AppTheme.textMuted)),
                        if (e.createdAt != null)
                          Text(e.createdAt!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
