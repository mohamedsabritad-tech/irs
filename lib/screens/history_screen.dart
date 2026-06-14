import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RedeemLog> _logs = [];
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
      final res = await ApiService.getRedeemHistory(limit: 200);
      if (res['ok'] == true && res['logs'] != null) {
        final list = res['logs'] as List;
        setState(() => _logs = list
            .map((e) => RedeemLog.fromJson(e as Map<String, dynamic>))
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
        title: const Text('Redeem History'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _logs.isEmpty
          ? const Center(child: Text('No history'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _logs.length,
              itemBuilder: (c, i) {
                final l = _logs[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (l.status == 'success' ? Colors.green : Colors.red)
                          .withValues(alpha: 0.15),
                      child: Icon(
                        l.status == 'success' ? Icons.check : Icons.close,
                        color: l.status == 'success' ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text('${l.gameId} → ${l.code}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (l.message != null && l.message!.isNotEmpty)
                          Text(l.message!, style: const TextStyle(color: AppTheme.textMuted)),
                        if (l.createdAt != null)
                          Text(l.createdAt!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
