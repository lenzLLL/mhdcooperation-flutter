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
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedOperator;
  bool _isLoading = false;

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
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
    if (widget.amount > 0 && _selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un opérateur mobile.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final api = ApiClient();
    try {
      // Le serveur recalcule le montant depuis le catalogue : on n'envoie que
      // la sélection, jamais un prix.
      final dossier = await api.post('/api/dossiers', {
        'itemType': widget.type,
        if (widget.concoursId != null) 'concoursId': widget.concoursId,
        if (widget.serviceId != null) 'serviceId': widget.serviceId,
        'ville': widget.ville,
        'quartier': widget.quartier,
      });
      final dossierId = dossier['dossier']['id'] as String;

      if (widget.amount > 0) {
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
      }

      if (!mounted) return;
      Get.offAllNamed(AppRoutes.userDossiers);
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
    final isFree = widget.amount <= 0;
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
                                  isFree ? 'Gratuit' : '${widget.amount.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                              Expanded(child: _operatorCard('Orange', Colors.orange, Icons.signal_cellular_alt_rounded)),
                              const SizedBox(width: 12),
                              Expanded(child: _operatorCard('MTN', const Color(0xFFFFCC00), Icons.signal_cellular_alt_2_bar_rounded)),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _operatorCard(String name, Color color, IconData icon) {
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
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.grey[600],
              ),
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
