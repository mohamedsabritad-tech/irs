import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Alliance> _alliances = [];
  List<Account> _playerRecords = [];
  List<ActivityEntry> _activity = [];
  bool _loadingAlliances = true;
  bool _loadingRecords = true;
  bool _loadingActivity = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    await Future.wait([_loadAlliances(), _loadRecords(), _loadActivity()]);
  }

  Future<void> _loadAlliances() async {
    try {
      final res = await ApiService.getAlliances();
      if (res['ok'] == true && res['data'] != null) {
        final list = res['data'] as List;
        setState(() => _alliances = list
            .map((e) => Alliance.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (_) {}
    setState(() => _loadingAlliances = false);
  }

  Future<void> _loadRecords() async {
    try {
      final res = await ApiService.getPlayerRecords();
      if (res['ok'] == true && res['data'] != null) {
        final list = res['data'] as List;
        setState(() => _playerRecords = list
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (_) {}
    setState(() => _loadingRecords = false);
  }

  Future<void> _loadActivity() async {
    try {
      final res = await ApiService.getActivity();
      if (res['ok'] == true && res['data'] != null) {
        final list = res['data'] as List;
        setState(() => _activity = list
            .map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } catch (_) {}
    setState(() => _loadingActivity = false);
  }

  void _addAllianceDialog() {
    final t = TextEditingController();
    final n = TextEditingController();
    final m = TextEditingController();
    final k = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Alliance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: t,
                  decoration: const InputDecoration(labelText: 'Tag')),
              TextField(
                  controller: n,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: m,
                  decoration:
                      const InputDecoration(labelText: 'Member Count')),
              TextField(
                  controller: k,
                  decoration: const InputDecoration(labelText: 'Kingdom')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                await ApiService.saveAlliance({
                  'tag': t.text,
                  'name': n.text,
                  'memberCount': m.text,
                  'kingdom': k.text,
                });
                _loadAlliances();
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Alliances'),
            Tab(text: 'Player Records'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildAlliances(),
          _buildRecords(),
          _buildActivity(),
        ],
      ),
    );
  }

  Widget _buildAlliances() {
    if (_loadingAlliances) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'alliance',
        onPressed: _addAllianceDialog,
        child: const Icon(Icons.add),
      ),
      body: _alliances.isEmpty
          ? const Center(child: Text('No alliances'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _alliances.length,
              itemBuilder: (c, i) {
                final a = _alliances[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.indigo.withValues(alpha: 0.15),
                      child: Text('[${a.tag}]',
                          style: const TextStyle(
                              color: AppTheme.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                    title: Text(a.name ?? a.tag,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'K${a.kingdom ?? '?'} · ${a.memberCount ?? '?'} members',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await ApiService.deleteAlliance(a.tag);
                        _loadAlliances();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRecords() {
    if (_loadingRecords) return const Center(child: CircularProgressIndicator());
    return _playerRecords.isEmpty
        ? const Center(child: Text('No player records'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _playerRecords.length,
            itemBuilder: (c, i) {
              final a = _playerRecords[i];
              final tier = a.furnaceTier;
              final ringColor = tier != null && (int.tryParse(tier) ?? 0) >= 10
                  ? AppTheme.orange
                  : (int.tryParse(tier ?? '0') ?? 0) >= 5
                      ? AppTheme.cyan
                      : AppTheme.indigo;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ringColor.withValues(alpha: 0.15),
                    child: Text('${a.level}',
                        style: TextStyle(
                            color: ringColor, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(a.nickname,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'K${a.kingdom} · Lv${a.level}${tier != null ? ' · FC$tier' : ''}',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildActivity() {
    if (_loadingActivity) return const Center(child: CircularProgressIndicator());
    return _activity.isEmpty
        ? const Center(child: Text('No activity'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _activity.length,
            itemBuilder: (c, i) {
              final e = _activity[i];
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
          );
  }
}
