import 'package:get/get.dart';

import '../models/user_model.dart';
import 'storage_service.dart';

class SessionService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isAuthenticated = false.obs;

  Future<SessionService> init() async {
    await hydrate();
    return this;
  }

  Future<void> hydrate() async {
    isAuthenticated.value = await _storage.isAuthenticated();

    final cachedUser = await _storage.getCurrentUser();
    currentUser.value = cachedUser != null
        ? UserModel.fromJson(cachedUser)
        : null;
    // currentChurchId.value = _storage.getCurrentChurchId();
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.saveToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(refreshToken);
    }
    isAuthenticated.value = true;
  }

  Future<void> setCurrentUser(UserModel user) async {
    currentUser.value = user;
    await _storage.saveUserId(user.id);
    await _storage.saveCurrentUser(user.toJson());
    isAuthenticated.value = await _storage.isAuthenticated();
  }

  Future<void> clearSession() async {
    currentUser.value = null;
    isAuthenticated.value = false;
    await _storage.clearAll();
  }
}
