import 'package:shared_preferences/shared_preferences.dart';

class WalletPreferences {
  static const balanceVisibilityKey = 'wallet_balance_visible';

  const WalletPreferences();

  Future<bool> loadBalanceVisibility() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(balanceVisibilityKey) ?? true;
  }

  Future<void> saveBalanceVisibility(bool isVisible) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(balanceVisibilityKey, isVisible);
  }
}
