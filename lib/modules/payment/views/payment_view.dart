import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/services/api_client.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class PaymentView extends StatefulWidget {
  final String type;
  final String itemId;
  final String itemTitle;
  final double amount;
  final String? serviceId;
  final String? concoursId;
  final String? ville;
  final String? quartier;
  final List<String> requiredDocuments;
  // Ce que le serveur doit recevoir pour recalculer le MÊME prix que celui
  // affiché ici (voir ServiceSelection côté web) — sans ça, le serveur
  // retombe sur son prix de base par défaut, indépendant de ce qui a été
  // choisi. `amount` ci-dessus ne sert qu'à l'affichage.
  final Map<String, dynamic>? selection;
  /// Dossier déjà créé (reprise d'un paiement depuis le détail du dossier) :
  /// `amount` est alors son prix d'origine, avant tout code promo.
  final String? dossierId;
  /// Code promo déjà appliqué à ce dossier (par exemple depuis le site).
  final String? promoCode;
  final int? promoPercent;

  const PaymentView({
    super.key,
    required this.type,
    required this.itemId,
    required this.itemTitle,
    required this.amount,
    this.serviceId,
    this.concoursId,
    this.ville,
    this.quartier,
    this.requiredDocuments = const [],
    this.selection,
    this.dossierId,
    this.promoCode,
    this.promoPercent,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedOperator;
  bool _isLoading = false;
  // Le dossier créé au premier essai est conservé : si le paiement échoue
  // (mauvais numéro, solde insuffisant) et que l'utilisateur retente, on ne
  // recrée pas un second dossier pour le même achat.
  String? _dossierId;

  // Code promo : vérifié par le serveur pour l'affichage, puis appliqué au
  // dossier au moment de payer — c'est alors le serveur qui fixe le prix.
  final TextEditingController _promoController = TextEditingController();
  String? _promoCode;
  int? _promoPercent;
  // Code actuellement enregistré sur le dossier côté serveur.
  String? _serverPromoCode;
  String? _promoError;
  bool _checkingPromo = false;

  /// Même règle que discountedAmount côté web : sous 100 FCFA (minimum de
  /// l'opérateur) le dossier devient gratuit.
  double get _payable {
    if (_promoPercent == null) return widget.amount;
    final value = (widget.amount * (100 - _promoPercent!) / 100).roundToDouble();
    return value < 100 ? 0 : value;
  }

  void _autoDetectOperator(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // Cameroon prefixes: MTN = 67x, 68x ; Orange = 65x, 66x, 69x
    final local = digits.startsWith('237') ? digits.substring(3) : digits;
    if (local.startsWith('67') || local.startsWith('68')) {
      if (_selectedOperator != 'MTN') setState(() => _selectedOperator = 'MTN');
    } else if (local.startsWith('65') || local.startsWith('66') || local.startsWith('69')) {
      if (_selectedOperator != 'Orange') setState(() => _selectedOperator = 'Orange');
    }
  }

  @override
  void initState() {
    super.initState();
    final sessionService = Get.find<SessionService>();
    final phone = sessionService.currentUser.value?.phoneNumber;
    if (phone != null) _phoneController.text = phone;
    _dossierId = widget.dossierId;
    _promoCode = widget.promoCode;
    _promoPercent = widget.promoPercent;
    _serverPromoCode = widget.promoCode;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.length < 3) return;
    if (!Get.find<SessionService>().isAuthenticated.value) {
      setState(() => _promoError = 'Connectez-vous pour utiliser un code promo.');
      return;
    }
    setState(() {
      _checkingPromo = true;
      _promoError = null;
    });
    try {
      final res = await ApiClient().post('/api/promos/verifier', {
        'code': code,
        'itemType': widget.type,
        if (widget.serviceId != null) 'serviceId': widget.serviceId,
      });
      if (!mounted) return;
      setState(() {
        _promoCode = res['code'] as String;
        _promoPercent = (res['percent'] as num).toInt();
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _promoError = e.message);
    } catch (_) {
      if (mounted) setState(() => _promoError = 'Impossible de vérifier le code.');
    } finally {
      if (mounted) setState(() => _checkingPromo = false);
    }
  }

  Future<void> _submitPayment() async {
    final sessionService = Get.find<SessionService>();
    if (!sessionService.isAuthenticated.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour continuer.')),
      );
      Get.back();
      return;
    }

    final phone = _phoneController.text.trim();
    // Vérification locale sommaire avant tout appel réseau ; le serveur reste
    // l'autorité (validateCameroonPhone), qui accepte une fourchette large
    // plutôt qu'un format strict pour ne jamais bloquer à tort un vrai client.
    if (_payable > 0 && phone.replaceAll(RegExp(r'\D'), '').length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un numéro de téléphone valide.')),
      );
      return;
    }
    if (_payable > 0 && _selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un opérateur mobile.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final api = ApiClient();
    try {
      // Le serveur recalcule le montant depuis le catalogue : on n'envoie que
      // la sélection, jamais un prix. Si un essai précédent a déjà créé le
      // dossier (le paiement seul a échoué), on le réutilise au lieu d'en
      // créer un second pour le même achat.
      String dossierId;
      if (_dossierId != null) {
        dossierId = _dossierId!;
      } else {
        final dossier = await api.post('/api/dossiers', {
          'itemType': widget.type,
          if (widget.concoursId != null) 'concoursId': widget.concoursId,
          if (widget.serviceId != null) 'serviceId': widget.serviceId,
          if (widget.selection != null) 'selection': widget.selection,
          'ville': widget.ville,
          'quartier': widget.quartier,
        });
        dossierId = dossier['dossier']['id'] as String;
      }
      _dossierId = dossierId;

      // Le serveur applique (ou retire) le code et recalcule le prix ; un code
      // devenu invalide lève une erreur affichée et rien n'est payé.
      if (_promoCode != _serverPromoCode) {
        if (_promoCode != null) {
          await api.post('/api/dossiers/$dossierId/promo', {'code': _promoCode});
        } else {
          await api.delete('/api/dossiers/$dossierId/promo');
        }
        _serverPromoCode = _promoCode;
      }

      if (widget.amount > 0) {
        // Le montant affiché a pu être modifié par l'admin depuis l'ouverture
        // de l'écran. On relit le dossier avant de déclencher le débit : si le
        // prix a changé, on n'engage rien et on prévient l'utilisateur.
        final fresh = await api.get('/api/dossiers/$dossierId');
        final freshAmount = (fresh['dossier']?['amount'] as num?)?.toDouble();
        if (freshAmount != null && freshAmount != _payable) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Le montant de ce dossier est désormais de '
                '${freshAmount.toStringAsFixed(0)} FCFA. Vérifiez puis relancez le paiement.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
          Get.offAllNamed(AppRoutes.userDossiers);
          Get.toNamed(AppRoutes.dossierDetail, arguments: {'dossierId': dossierId});
          return;
        }

        if (_payable > 0) {
          final operator = _selectedOperator == 'MTN' ? 'MTN_MOMO_CMR' : 'ORANGE_CMR';
          await api.post('/api/dossiers/$dossierId/paiement', {
            'operator': operator,
            'phoneNumber': phone,
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Validez la demande de paiement sur votre téléphone.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code promo appliqué : votre dossier est gratuit.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (!mounted) return;
      // Aller au détail du dossier plutôt qu'à la liste : c'est là que le
      // statut se met à jour et que les pièces à fournir s'ouvrent une fois le
      // paiement confirmé.
      Get.offAllNamed(AppRoutes.userDossiers);
      Get.toNamed(AppRoutes.dossierDetail, arguments: {'dossierId': dossierId});
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rien à payer : dossier gratuit d'origine, ou grâce au code promo.
    final payable = _payable;
    final isFree = payable <= 0;
    final itemType = widget.type == 'concours' ? 'Concours' : 'Service';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            'Paiement $itemType',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Amount display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isFree ? Icons.check_circle_outline_rounded : Icons.payments_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.itemTitle,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Montant à payer',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                                ),
                                Text(
                                  isFree ? 'Gratuit' : '${payable.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                if (_promoCode != null)
                                  Text(
                                    '${widget.amount.toStringAsFixed(0)} FCFA · code $_promoCode (-$_promoPercent %)',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (isFree ? const Color(0xFF10B981) : AppColors.secondary).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: (isFree ? const Color(0xFF10B981) : AppColors.secondary).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: isFree ? const Color(0xFF10B981) : AppColors.secondary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isFree
                                ? 'Ce dossier est gratuit. Il sera créé immédiatement et accessible dans Mes documents.'
                                : 'Renseignez votre numéro et sélectionnez votre opérateur. Notre équipe traitera votre paiement et activera votre dossier dans les plus brefs délais.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isFree ? const Color(0xFF10B981) : AppColors.secondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone field
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Numéro de téléphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          cursorColor: AppColors.primary,
                          onChanged: _autoDetectOperator,
                          decoration: InputDecoration(
                            hintText: 'Ex: +237 6XX XXX XXX',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.secondary, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EFF8))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EFF8), width: 1.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isFree) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Opérateur mobile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _operatorCard('Orange', 'Orange Money', Colors.orange, Icons.signal_cellular_alt_rounded)),
                              const SizedBox(width: 12),
                              Expanded(child: _operatorCard('MTN', 'Mobile Money', const Color(0xFFFFCC00), Icons.signal_cellular_alt_2_bar_rounded)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (widget.amount > 0) ...[
                    const SizedBox(height: 16),
                    _buildPromoCard(),
                  ],

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _isLoading
                            ? const LinearGradient(colors: [Color(0xFFCCCCCC), Color(0xFFCCCCCC)])
                            : AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isLoading
                            ? null
                            : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : Text(
                                isFree ? 'Créer mon dossier' : 'Soumettre ma demande',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Code promo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          if (_promoCode != null)
            Row(
              children: [
                const Icon(Icons.local_offer_rounded, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_promoCode appliqué : -$_promoPercent %',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() {
                            _promoCode = null;
                            _promoPercent = null;
                            _promoController.clear();
                          }),
                  child: const Text('Retirer'),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Ex. RENTREE10',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.local_offer_outlined, color: AppColors.secondary, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EFF8))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EFF8), width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _checkingPromo || _isLoading ? null : _applyPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _checkingPromo
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Appliquer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          if (_promoError != null) ...[
            const SizedBox(height: 8),
            Text(_promoError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  /// [name] identifie l'opérateur ; [wallet] est le nom du portefeuille affiché
  /// (Orange Money pour Orange, Mobile Money pour MTN MoMo).
  Widget _operatorCard(String name, String wallet, Color color, IconData icon) {
    final selected = _selectedOperator == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedOperator = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFE8EFF8),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey[400], size: 28),
            const SizedBox(height: 6),
            Text(
              wallet,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.grey[600],
              ),
            ),
            Text(
              name,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle_rounded, color: color, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
