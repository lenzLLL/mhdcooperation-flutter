import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/promo_code.dart';
import 'package:mhdcooperation/data/services/api_client.dart';

/// Codes promo : tout passe par l'API web, qui valide, journalise (audit) et
/// reste la seule à écrire en base — mêmes règles que la console web.
class AdminPromosController extends GetxController {
  final _api = ApiClient();
  final promos = <PromoCode>[].obs;
  final isLoading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final res = await _api.get('/api/admin/promos');
      promos.value = (res['promos'] as List<dynamic>)
          .map((e) => PromoCode.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      error.value = e.message;
    } catch (_) {
      error.value = 'Impossible de charger les codes promo.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Crée (editingCode == null) ou modifie un code. Renvoie un message d'erreur, ou null.
  Future<String?> save(String? editingCode, Map<String, dynamic> body) async {
    try {
      if (editingCode == null) {
        await _api.post('/api/admin/promos', body);
      } else {
        await _api.patch('/api/admin/promos/${Uri.encodeComponent(editingCode)}', body);
      }
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Une erreur est survenue.';
    }
  }

  Future<String?> toggle(PromoCode promo) =>
      save(promo.code, {'active': !promo.active});

  Future<String?> remove(PromoCode promo) async {
    try {
      await _api.delete('/api/admin/promos/${Uri.encodeComponent(promo.code)}');
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Une erreur est survenue.';
    }
  }
}
