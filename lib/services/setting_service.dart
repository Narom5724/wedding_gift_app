class SettingService {
  Future<Map<String, dynamic>> loadSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return {'language': 'en', 'theme': 'light', 'currency': 'USD'};
  }
}
