import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SettingsPage(),
    );
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _emailController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final saved = await AppSettings.instance.getDefaultEmail();
    _emailController.text = saved ?? '';
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Dark Theme'),
            subtitle: const Text('Placeholder'),
            onTap: () {},
          ),

          const Divider(height: 24),
          const _SectionHeader('Account'),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Default Email'),
            subtitle: TextField(
              controller: _emailController,
              enabled: _loaded, //dont edit before load
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'name@mail.com',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                AppSettings.instance.setDefaultEmail(value.trim());
              },
            ),
          ),

          const Divider(height: 24),
          const _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App info'),
            subtitle: const Text('one Touch Documentation'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _keyDefaultEmail = 'default_email';

  Future<String?> getDefaultEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultEmail);
  }

  Future<void> setDefaultEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultEmail, email);
  }
}
