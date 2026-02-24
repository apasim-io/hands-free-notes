import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _emailController = TextEditingController();

  // these are defaults used when no preference has been set
  bool _autoScrollEnabled = false;
  int _autoScrollDelayMs = 2000;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedEmail = await AppSettings.instance.getDefaultEmail();
    final savedAutoScroll = await AppSettings.instance.getAutoScrollEnabled();
    final savedDelay =
        await AppSettings.instance.getAutoScrollDelayMs(defaultValue: 2000);

    _emailController.text = savedEmail ?? '';
    _autoScrollEnabled = savedAutoScroll;
    _autoScrollDelayMs = savedDelay;
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
          SwitchListTile(
            title: const Text('Auto scroll notes'),
            subtitle: Text(
              'Automatically continue to next section after completing the current section',
            ),
            value: _autoScrollEnabled,
            onChanged: _loaded
                ? (value) async {
                    setState(() => _autoScrollEnabled = value);
                    await AppSettings.instance.setAutoScrollEnabled(value);
                  }
                : null,
          ),
          ListTile(
            enabled: _loaded,
            leading: const Icon(Icons.timer),
            title: const Text('Auto scroll delay (ms)'),
            subtitle: Slider(
              value: _autoScrollDelayMs.toDouble(),
              min: 500,
              max: 5000,
              divisions: 9,
              label: '${_autoScrollDelayMs}ms',
              onChanged: (value) {
                setState(() => _autoScrollDelayMs = value.round());
              },
              onChangeEnd: (value) async {
                await AppSettings.instance
                    .setAutoScrollDelayMs(value.round());
              },
            ),
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
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _keyDefaultEmail = 'default_email';
  static const _keyAutoScrollEnabled = 'auto_scroll_enabled';
  static const _keyAutoScrollDelayMs = 'auto_scroll_delay_ms';

  Future<String?> getDefaultEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultEmail);
  }

  Future<void> setDefaultEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultEmail, email);
  }

  Future<bool> getAutoScrollEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoScrollEnabled) ?? false;
  }

  Future<void> setAutoScrollEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoScrollEnabled, enabled);
  }

  Future<int> getAutoScrollDelayMs({int defaultValue = 2000}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAutoScrollDelayMs) ?? defaultValue;
  }

  Future<void> setAutoScrollDelayMs(int milliseconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoScrollDelayMs, milliseconds);
  }
}
