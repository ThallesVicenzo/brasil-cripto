import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage.dart';

class SecureStorageImpl implements SecureStorage {
  late final FlutterSecureStorage _storage;

  SecureStorageImpl() {
    _storage = const FlutterSecureStorage();
  }

  @override
  Future<void> write({required String key, required String value}) async {
    if (key.isNotEmpty && value.isNotEmpty) {
      await _storage.write(
        key: key,
        value: value,
      );
    }
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> eraseAll() async {
    await _storage.deleteAll();
  }
}
