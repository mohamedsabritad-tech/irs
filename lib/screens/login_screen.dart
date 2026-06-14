import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _isSignup = false;
  bool _showUrl = false;

  @override
  void initState() {
    super.initState();
    _urlCtrl.text = Preferences.apiUrl;
  }

  Future<void> _submit() async {
    Preferences.apiUrl = _urlCtrl.text.trim().replaceAll(RegExp(r'/+$'), '');
    setState(() { _loading = true; _error = null; });
    try {
      final res = _isSignup
          ? await ApiService.signup(_userCtrl.text.trim(), _passCtrl.text)
          : await ApiService.login(_userCtrl.text.trim(), _passCtrl.text,
              _codeCtrl.text.trim());
      if (res['ok'] == true) {
        Preferences.token = res['token'] as String?;
        Preferences.username = res['username'] as String?;
        Preferences.role = res['role'] as String?;
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = res['error'] as String? ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _codeCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showUrl ? Icons.link_off : Icons.link),
            onPressed: () => setState(() => _showUrl = !_showUrl),
            tooltip: 'Server URL',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, color: Color(0xFF6366F1), size: 64),
              const SizedBox(height: 8),
              Text('Nexus WoS',
                  style: Theme.of(context).textTheme.headlineMedium),
              Text('War of Shadows Manager',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8A94A6))),
              const SizedBox(height: 32),
              if (_showUrl) ...[
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'https://nexus-wos.wasmer.app',
                    prefixIcon: Icon(Icons.dns),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                    labelText: 'Username', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              ),
              if (!_isSignup) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                      labelText: '2FA Code (optional)',
                      prefixIcon: Icon(Icons.security)),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.copy, color: Colors.white54, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isSignup ? 'Sign Up' : 'Login'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isSignup = !_isSignup),
                child: Text(_isSignup
                    ? 'Already have an account? Login'
                    : 'New here? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
