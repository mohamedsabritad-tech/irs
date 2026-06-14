import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/models.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  List<GiftCode> _codes = [];
  List<RedeemLog> _history = [];
  bool _loadingCodes = true;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.wait([_loadCodes(), _loadHistory()]);
  }

  Future<void> _loadCodes() async {
    try {
      final res = await ApiService.getRedeemCodes();
      if (res['ok'] == true && res['data'] != null) {
        final list = res['data'] as List;
        setState(() => _codes = list
            .map((e) => GiftCode.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (_) {}
    setState(() => _loadingCodes = false);
  }

  Future<void> _loadHistory() async {
    try {
      final res = await ApiService.getRedeemHistory();
      if (res['ok'] == true && res['data'] != null) {
        final list = res['data'] as List;
        setState(() => _history = list
            .map((e) => RedeemLog.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (_) {}
    setState(() => _loadingHistory = false);
  }

  void _redeemDialog() {
    final gCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Redeem Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: gCtrl,
                decoration: const InputDecoration(labelText: 'Game ID(s) — comma separated')),
            TextField(
                controller: aCtrl,
                decoration: const InputDecoration(labelText: 'Gift Code')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                await ApiService.redeemCodes({
                  'gameIds': gCtrl.text.split(',').map((e) => e.trim()).toList(),
                  'code': aCtrl.text.trim(),
                });
                _loadHistory();
              },
              child: const Text('Redeem')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Redeem'),
          actions: [
            IconButton(icon: const Icon(Icons.redeem), onPressed: _redeemDialog),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Codes'), Tab(text: 'History')],
          ),
        ),
        body: TabBarView(
          children: [
            _loadingCodes
                ? const Center(child: CircularProgressIndicator())
                : _codes.isEmpty
                    ? const Center(child: Text('No gift codes'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _codes.length,
                        itemBuilder: (c, i) => Card(
                          child: ListTile(
                            title: Text(_codes[i].code,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              _codes[i].description ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: _codes[i].isActive == '1'
                                ? const Chip(label: Text('Active'), backgroundColor: Colors.green)
                                : const Chip(label: Text('Inactive')),
                          ),
                        ),
                      ),
            _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? const Center(child: Text('No redeem history'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _history.length,
                        itemBuilder: (c, i) {
                          final h = _history[i];
                          return Card(
                            child: ListTile(
                              title: Text('${h.gameId} → ${h.code}'),
                              subtitle: Text(h.message ?? '',
                                  style: const TextStyle(color: Colors.grey)),
                              trailing: Text(
                                h.status == 'success' ? 'OK' : 'FAIL',
                                style: TextStyle(
                                  color: h.status == 'success' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
