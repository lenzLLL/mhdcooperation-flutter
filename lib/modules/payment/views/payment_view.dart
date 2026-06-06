import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/dossier_service.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class PaymentView extends StatefulWidget {
  final String type;
  final String itemId;
  final String itemTitle;
  final double amount;
  final String? serviceId;
  final String? concoursId;

  const PaymentView({
    super.key,
    required this.type,
    required this.itemId,
    required this.itemTitle,
    required this.amount,
    this.serviceId,
    this.concoursId,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedOperator;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final sessionService = Get.find<SessionService>();
    final phone = sessionService.currentUser.value?.phoneNumber;
    if (phone != null) {
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    final sessionService = Get.find<SessionService>();
    final currentUser = sessionService.currentUser.value;

    if (currentUser == null || !sessionService.isAuthenticated.value) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour continuer.'),
          ),
        );
      }
      Get.back();
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro de téléphone valide.'),
        ),
      );
      return;
    }

    if (widget.amount > 0 && _selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un opérateur mobile.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dossierService = Get.find<DossierService>();
      final status = 'en_cours';
      final gateway = widget.amount > 0 ? _selectedOperator! : 'Aucun';

      await dossierService.createDossier(
        userId: currentUser.id,
        userName: currentUser.name,
        userEmail: currentUser.email,
        userPhone: phone,
        serviceId: widget.serviceId,
        concoursId: widget.concoursId,
        amount: widget.amount,
        gateway: gateway,
        status: status,
        itemTitle: widget.itemTitle,
        itemType: widget.type,
        messages:
            'Paiement ${widget.type} via ${gateway == 'Aucun' ? 'gratuit' : gateway}.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.amount > 0
                ? 'Paiement réussi, votre dossier est créé et enregistré.'
                : 'Dossier créé avec succès.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Get.offAllNamed(AppRoutes.userDossiers);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemType = widget.type == 'concours' ? 'Concours' : 'Service';
    return Scaffold(
      appBar: AppBar(title: Text('Paiement $itemType')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemType: ${widget.itemTitle}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${widget.itemId}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.amount > 0
                            ? Colors.indigo.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Montant à payer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.amount > 0
                                    ? '${widget.amount.toStringAsFixed(0)} FCFA'
                                    : 'Aucun frais',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.amount > 0
                                      ? Colors.indigo
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            widget.amount > 0
                                ? Icons.payments
                                : Icons.insert_drive_file,
                            size: 42,
                            color: widget.amount > 0
                                ? Colors.indigo
                                : Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.amount > 0
                          ? 'Paiement sécurisé via mobile money. Après validation, votre dossier sera enregistré en Firestore.'
                          : 'Ce dossier est gratuit. Il sera créé immédiatement et accessible dans Mes documents.',
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Numéro de téléphone',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Entrez votre numéro mobile',
              ),
            ),
            if (widget.amount > 0) ...[
              const Text(
                'Opérateur mobile',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: ['Orange', 'MTN'].contains(_selectedOperator)
                    ? _selectedOperator
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Sélectionnez votre opérateur',
                ),
                items: const [
                  DropdownMenuItem(value: 'Orange', child: Text('Orange')),
                  DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                ],
                onChanged: (value) {
                  setState(() => _selectedOperator = value);
                },
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.amount > 0
                            ? 'Payer et créer mon dossier'
                            : 'Créer mon dossier',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
