import 'package:shared_preferences/shared_preferences.dart';

class CreditsService {
  static const _key = 'ai_creator_credits';
  static const _unlimitedKey = 'ai_creator_unlimited';
  static const ownerCode = '20661065';

  static Future<bool> redeem(String code) async {
    if (code.trim() != ownerCode) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlimitedKey, true);
    return true;
  }

  static Future<bool> isUnlimited() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlimitedKey) ?? false;
  }

  static Future<int> getCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 100;
  }

  static Future<bool> spend([int amount = 1]) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_unlimitedKey) ?? false) return true;
    final current = prefs.getInt(_key) ?? 100;
    if (current < amount) return false;
    await prefs.setInt(_key, current - amount);
    return true;
  }
}
