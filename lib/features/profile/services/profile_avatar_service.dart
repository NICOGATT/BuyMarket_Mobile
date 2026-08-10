import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatarService extends ChangeNotifier {
  String? _userId;
  Uint8List? _photoBytes;

  Uint8List? get photoBytes => _photoBytes;

  bool isLoadedFor(String userId) => _userId == userId;

  Future<void> load(String userId) async {
    if (_userId == userId) return;

    final prefs = await SharedPreferences.getInstance();
    final encodedPhoto = prefs.getString(_storageKey(userId));
    Uint8List? photo;
    if (encodedPhoto != null) {
      try {
        photo = base64Decode(encodedPhoto);
      } catch (_) {
        await prefs.remove(_storageKey(userId));
      }
    }

    _userId = userId;
    _photoBytes = photo;
    notifyListeners();
  }

  Future<void> save(String userId, Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(userId), base64Encode(bytes));
    _userId = userId;
    _photoBytes = bytes;
    notifyListeners();
  }

  Future<void> remove(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(userId));
    _userId = userId;
    _photoBytes = null;
    notifyListeners();
  }

  String _storageKey(String userId) => 'profile_avatar_$userId';
}

final profileAvatarService = ProfileAvatarService();
