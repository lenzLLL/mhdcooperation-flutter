import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/services/school_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class SchoolLevelSelector extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const SchoolLevelSelector({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<SchoolLevelSelector> createState() => _SchoolLevelSelectorState();
}

class _SchoolLevelSelectorState extends State<SchoolLevelSelector> {
  final _schoolService = SchoolService();

  List<School> _schools = [];
  bool _isLoading = true;

  School? _selectedSchool;
  String? _selectedNiveau;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _schoolService.getAllSchools();
      if (mounted) {
        setState(() {
          _schools = schools.where((s) => s.filieres.isNotEmpty).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _prix {
    if (_selectedSchool == null || _selectedNiveau == null) return 0;
    return _selectedSchool!.prixParNiveau[_selectedNiveau!] ?? 0;
  }

  bool get _canConfirm =>
      _selectedSchool != null && _selectedNiveau != null && _prix > 0;

  void _confirm() {
    Navigator.pop(context);
    Get.toNamed(
      AppRoutes.payment,
      arguments: {
        'type': 'service',
        'itemId': widget.serviceId,
        'itemTitle':
            '${widget.serviceName} — ${_selectedNiveau!} (${_selectedSchool!.name})',
        'amount': _prix,
        'serviceId': widget.serviceId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.serviceName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez votre école et le niveau souhaité',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_schools.isEmpty)
            const Center(
              child: Text(
                'Aucune école disponible pour ce service.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else ...[
            _buildLabel('École'),
            const SizedBox(height: 6),
            DropdownButtonFormField<School>(
              initialValue: _selectedSchool,
              isExpanded: true,
              decoration: _inputDecoration('Choisir une école'),
              items: _schools
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (s) => setState(() {
                _selectedSchool = s;
                _selectedNiveau = null;
              }),
            ),
            if (_selectedSchool != null) ...[
              const SizedBox(height: 16),
              _buildLabel('Niveau'),
              const SizedBox(height: 6),
              // Key forces rebuild (reset selection) when school changes
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedSchool?.id),
                initialValue: _selectedNiveau,
                isExpanded: true,
                decoration: _inputDecoration('Choisir un niveau'),
                items: _selectedSchool!.filieres
                    .map((n) => DropdownMenuItem(
                          value: n,
                          child: Text(n),
                        ))
                    .toList(),
                onChanged: (n) => setState(() => _selectedNiveau = n),
              ),
            ],
            if (_selectedNiveau != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant à payer',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _prix > 0
                          ? '${_prix.toStringAsFixed(0)} FCFA'
                          : 'Prix non défini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _prix > 0 ? Colors.indigo : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canConfirm ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continuer vers le paiement',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
