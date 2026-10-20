import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/constants/services_catalog.dart';
import 'package:mhdcooperation/data/models/promo_code.dart';
import 'package:mhdcooperation/modules/admin_promos/controllers/admin_promos_controller.dart';

/// Portées proposées, identiques à PROMO_SCOPE_OPTIONS côté web.
final List<MapEntry<String, String>> promoScopeOptions = [
  const MapEntry('concours', 'Concours'),
  ...servicesCatalog.map((s) => MapEntry('service:${s.id}', s.name)),
];

String _two(int n) => n.toString().padLeft(2, '0');
String _fcfa(double v) =>
    '${v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ')} FCFA';
String _date(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

class AdminPromosView extends GetView<AdminPromosController> {
  const AdminPromosView({super.key});

  void _snack(String? error, String success) {
    Get.snackbar(
      error == null ? 'Succès' : 'Erreur',
      error ?? success,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error == null ? Colors.green[50] : Colors.red[50],
      colorText: error == null ? Colors.green[800] : Colors.red[800],
    );
  }

  void _openForm(BuildContext context, PromoCode? promo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PromoForm(promo: promo, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Codes promo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau code', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.promos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(child: Text(controller.error.value!, textAlign: TextAlign.center));
        }
        if (controller.promos.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Aucun code promo.\nCréez-en un pour offrir une remise au moment du paiement.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: controller.promos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                i == 0 ? _totals(controller.promos) : _promoCard(context, controller.promos[i - 1]),
          ),
        );
      }),
    );
  }

  /// Totaux de tous les codes : encaissé (brut, avant commission K-Pay), remises, dossiers.
  Widget _totals(List<PromoCode> promos) {
    final revenue = promos.fold<double>(0, (sum, p) => sum + p.revenue);
    final discounts = promos.fold<double>(0, (sum, p) => sum + p.discountTotal);
    final uses = promos.fold<int>(0, (sum, p) => sum + p.uses);
    Widget tile(String label, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        );
    return Row(
      children: [
        tile('Encaissé', _fcfa(revenue)),
        const SizedBox(width: 8),
        tile('Remises', _fcfa(discounts)),
        const SizedBox(width: 8),
        tile('Dossiers', '$uses'),
      ],
    );
  }

  Widget _promoCard(BuildContext context, PromoCode promo) {
    final (String label, Color color) = !promo.active
        ? ('Désactivé', Colors.grey)
        : promo.isExpired
            ? ('Expiré', Colors.red)
            : promo.isExhausted
                ? ('Épuisé', Colors.orange)
                : ('Actif', const Color(0xFF10B981));
    final scope = promo.scope.isEmpty
        ? 'Tous les dossiers'
        : promo.scope
            .map((k) => promoScopeOptions.firstWhere((o) => o.key == k, orElse: () => MapEntry(k, k)).value)
            .join(', ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(promo.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              const SizedBox(width: 8),
              Text('-${promo.percent} %', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (promo.description != null) ...[
            const SizedBox(height: 4),
            Text(promo.description!, style: TextStyle(color: Colors.grey[700])),
          ],
          const SizedBox(height: 6),
          Text(
            '${promo.uses}${promo.maxUses != null ? ' / ${promo.maxUses}' : ''} utilisation(s) · '
            '${promo.expiresAt != null ? 'expire le ${_date(promo.expiresAt!)}' : 'sans expiration'}'
            '${promo.oncePerUser ? ' · 1 fois par client' : ''}\n$scope',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Encaissé : ${_fcfa(promo.revenue)} · remises : ${_fcfa(promo.discountTotal)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => _openForm(context, promo), child: const Text('Modifier')),
              TextButton(
                onPressed: () async => _snack(
                  await controller.toggle(promo),
                  promo.active ? 'Code désactivé.' : 'Code réactivé.',
                ),
                child: Text(promo.active ? 'Désactiver' : 'Réactiver'),
              ),
              if (promo.uses == 0)
                TextButton(
                  onPressed: () async {
                    final ok = await Get.dialog<bool>(AlertDialog(
                      title: const Text('Supprimer ce code ?'),
                      content: Text('Le code ${promo.code} sera définitivement supprimé.'),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
                        TextButton(onPressed: () => Get.back(result: true), child: const Text('Supprimer')),
                      ],
                    ));
                    if (ok == true) _snack(await controller.remove(promo), 'Code supprimé.');
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Supprimer'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoForm extends StatefulWidget {
  final PromoCode? promo;
  final AdminPromosController controller;

  const _PromoForm({required this.promo, required this.controller});

  @override
  State<_PromoForm> createState() => _PromoFormState();
}

class _PromoFormState extends State<_PromoForm> {
  late final _code = TextEditingController(text: widget.promo?.code ?? '');
  late final _percent = TextEditingController(text: widget.promo?.percent.toString() ?? '');
  late final _description = TextEditingController(text: widget.promo?.description ?? '');
  late final _maxUses = TextEditingController(text: widget.promo?.maxUses?.toString() ?? '');
  late DateTime? _expiresAt = widget.promo?.expiresAt;
  late bool _oncePerUser = widget.promo?.oncePerUser ?? false;
  late bool _active = widget.promo?.active ?? true;
  late final Set<String> _scope = {...?widget.promo?.scope};
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _percent.dispose();
    _description.dispose();
    _maxUses.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final d = _expiresAt;
    final error = await widget.controller.save(widget.promo?.code, {
      'code': _code.text.trim().toUpperCase(),
      'percent': int.tryParse(_percent.text.trim()) ?? 0,
      'description': _description.text.trim(),
      'expiresAt': d == null ? null : '${d.year}-${_two(d.month)}-${_two(d.day)}',
      'maxUses': _maxUses.text.trim().isEmpty ? null : int.tryParse(_maxUses.text.trim()),
      'oncePerUser': _oncePerUser,
      'scope': _scope.toList(),
      'active': _active,
    });
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    final editing = widget.promo != null;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editing ? 'Modifier ${widget.promo!.code}' : 'Nouveau code promo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              enabled: !editing,
              textCapitalization: TextCapitalization.characters,
              decoration: _decoration('Code', hint: 'Ex. RENTREE10'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _percent,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Remise (%)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxUses,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Utilisations max', hint: 'Illimité'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _description, decoration: _decoration('Description interne (facultatif)')),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(_expiresAt == null ? 'Sans date d\'expiration' : 'Expire le ${_date(_expiresAt!)}'),
              trailing: _expiresAt == null
                  ? null
                  : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _expiresAt = null)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked != null) setState(() => _expiresAt = picked);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Une seule utilisation par client'),
              value: _oncePerUser,
              onChanged: (v) => setState(() => _oncePerUser = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Actif'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 4),
            const Text('Dossiers concernés (aucun coché = tous)', style: TextStyle(fontWeight: FontWeight.w600)),
            ...promoScopeOptions.map((o) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(o.value),
                  value: _scope.contains(o.key),
                  onChanged: (v) => setState(() => v == true ? _scope.add(o.key) : _scope.remove(o.key)),
                )),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
