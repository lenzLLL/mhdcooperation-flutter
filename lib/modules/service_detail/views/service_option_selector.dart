import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/models/services.dart';
import 'package:mhdcooperation/data/services/school_service.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

const _villesCameroun = [
  'Bafoussam',
  'Bamenda',
  'Bertoua',
  'Buea',
  'Douala',
  'Ebolowa',
  'Garoua',
  'Kumba',
  'Limbé',
  'Maroua',
  'Ngaoundéré',
  'Nkongsamba',
  'Yaoundé',
];

class ServiceOptionSelector extends StatefulWidget {
  final Services service;

  const ServiceOptionSelector({super.key, required this.service});

  @override
  State<ServiceOptionSelector> createState() => _ServiceOptionSelectorState();
}

class _ServiceOptionSelectorState extends State<ServiceOptionSelector> {
  final _quartierController = TextEditingController();
  int _step = 0;
  String? _selectedVille;
  ServiceSubOption? _selectedSubOption;

  List<School> _allSchools = [];
  bool _isLoadingSchools = true;
  School? _selectedSchool;
  String? _selectedNiveau;
  String? _selectedTypeInscription;

  bool get _isBts {
    final n = widget.service.name.toLowerCase();
    return n.contains('bts') ||
        n.contains('licence') ||
        n.contains('bachelor') ||
        n.contains('master') ||
        n.contains('hnd');
  }

  bool get _isCniPasseport {
    final n = widget.service.name.toLowerCase();
    return n.contains('passeport') || n.contains('cni');
  }

  bool get _isPolice => widget.service.name.toLowerCase().contains('police');

  bool get _isInscription {
    final n = widget.service.name.toLowerCase();
    return n.contains('inscription') || n.contains('préinscription') || n.contains('preinscription');
  }

  bool get _isRapportStage =>
      widget.service.name.toLowerCase().contains('rapport');

  List<ServiceSubOption> get _subOptions {
    if (widget.service.subOptions?.isNotEmpty == true) {
      return widget.service.subOptions!;
    }
    if (_isCniPasseport) {
      return const [
        ServiceSubOption(id: 'cni', label: 'CNI', price: 5000),
        ServiceSubOption(id: 'passeport', label: 'Passeport', price: 15000),
      ];
    }
    if (_isPolice) {
      return const [
        ServiceSubOption(id: 'simple', label: 'Certificat de police simple', price: 5000),
        ServiceSubOption(
            id: 'minrex',
            label: 'Certificat de police + légalisation au Minrex',
            price: 25000),
      ];
    }
    return [];
  }

  List<School> get _filteredSchools => _allSchools
      .where((s) =>
          s.filieres.isNotEmpty &&
          (s.city == null || s.city!.isEmpty || s.city == _selectedVille))
      .toList();

  List<School> get _filteredInscriptionSchools => _allSchools
      .where((s) =>
          ((s.prixInscription != null && s.prixInscription! > 0) ||
              (s.prixPreinscription != null && s.prixPreinscription! > 0)) &&
          (s.city == null || s.city!.isEmpty || s.city == _selectedVille))
      .toList();

  List<School> get _filteredRapportSchools => _allSchools
      .where((s) =>
          s.prixRapportParNiveau.isNotEmpty &&
          (s.city == null || s.city!.isEmpty || s.city == _selectedVille))
      .toList();

  double get _btsPrix =>
      (_selectedSchool != null && _selectedNiveau != null)
          ? (_selectedSchool!.prixParNiveau[_selectedNiveau!] ?? 0.0)
          : 0.0;

  bool get _canConfirmBts =>
      _selectedSchool != null && _selectedNiveau != null && _btsPrix > 0;

  double get _inscriptionPrix {
    if (_selectedSchool == null || _selectedTypeInscription == null) return 0.0;
    if (_selectedTypeInscription == 'inscription') {
      return _selectedSchool!.prixInscription ?? 0.0;
    }
    return _selectedSchool!.prixPreinscription ?? 0.0;
  }

  bool get _canConfirmInscription =>
      _selectedSchool != null &&
      _selectedTypeInscription != null &&
      _inscriptionPrix > 0;

  double get _rapportPrix =>
      (_selectedSchool != null && _selectedNiveau != null)
          ? (_selectedSchool!.prixRapportParNiveau[_selectedNiveau!] ?? 0.0)
          : 0.0;

  bool get _canConfirmRapport =>
      _selectedSchool != null && _selectedNiveau != null && _rapportPrix > 0;

  @override
  void initState() {
    super.initState();
    final session = Get.find<SessionService>();
    final city = session.currentUser.value?.city;
    _selectedVille = _villesCameroun.contains(city) ? city : null;
    if (_isBts || _isInscription || _isRapportStage) _loadSchools();
  }

  Future<void> _loadSchools() async {
    try {
      _allSchools = await SchoolService().getAllSchools();
    } catch (_) {}
    if (mounted) setState(() => _isLoadingSchools = false);
  }

  @override
  void dispose() {
    _quartierController.dispose();
    super.dispose();
  }

  void _goToStep1() {
    if (_selectedVille == null) return;
    if (!_isBts && !_isCniPasseport && !_isPolice && !_isInscription && !_isRapportStage && _subOptions.isEmpty) {
      _navigateToPayment(
        itemTitle: widget.service.name,
        amount: widget.service.basePrice ?? 15000.0,
        selection: const {'kind': 'base'},
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _navigateToPayment({
    required String itemTitle,
    required double amount,
    required Map<String, dynamic> selection,
  }) {
    Navigator.pop(context);
    Get.toNamed(AppRoutes.payment, arguments: {
      'type': 'service',
      'itemId': widget.service.id,
      'itemTitle': itemTitle,
      'amount': amount,
      'serviceId': widget.service.id,
      'ville': _selectedVille,
      'quartier': _quartierController.text.trim(),
      'selection': selection,
    });
  }

  void _confirmSubOption() {
    if (_selectedSubOption == null) return;
    _navigateToPayment(
      itemTitle: '${widget.service.name} — ${_selectedSubOption!.label}',
      amount: _selectedSubOption!.price,
      selection: {'kind': 'suboption', 'subOptionId': _selectedSubOption!.id},
    );
  }

  void _confirmRapport() {
    if (!_canConfirmRapport) return;
    final docs = _selectedSchool!.docsRapportParNiveau[_selectedNiveau!] ?? [];
    Navigator.pop(context);
    Get.toNamed(AppRoutes.payment, arguments: {
      'type': 'service',
      'itemId': widget.service.id,
      'itemTitle': 'Rapport de stage — $_selectedNiveau (${_selectedSchool!.name})',
      'amount': _rapportPrix,
      'serviceId': widget.service.id,
      'ville': _selectedVille,
      'quartier': _quartierController.text.trim(),
      'selection': {'kind': 'rapport', 'schoolId': _selectedSchool!.id, 'niveau': _selectedNiveau!},
      if (docs.isNotEmpty) 'requiredDocuments': docs,
    });
  }

  void _confirmInscription() {
    if (!_canConfirmInscription) return;
    final typeLabel = _selectedTypeInscription == 'inscription'
        ? 'Inscription'
        : 'Préinscription';
    _navigateToPayment(
      itemTitle: '$typeLabel universitaire — ${_selectedSchool!.name}',
      amount: _inscriptionPrix,
      selection: {
        'kind': 'inscription',
        'schoolId': _selectedSchool!.id,
        'type': _selectedTypeInscription!,
      },
    );
  }

  void _confirmBts() {
    if (!_canConfirmBts) return;
    _navigateToPayment(
      itemTitle:
          '${widget.service.name} — $_selectedNiveau (${_selectedSchool!.name})',
      amount: _btsPrix,
      selection: {'kind': 'bts', 'schoolId': _selectedSchool!.id, 'niveau': _selectedNiveau!},
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
      child: SingleChildScrollView(
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
              widget.service.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _step == 0
                  ? 'Indiquez votre localisation actuelle'
                  : _isBts
                      ? 'Sélectionnez votre école et le niveau souhaité'
                      : _isInscription
                          ? 'Sélectionnez votre école et le type de dossier'
                          : _isRapportStage
                              ? 'Sélectionnez votre école et le niveau'
                              : 'Sélectionnez votre option',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (_step == 0) _buildStep0() else _buildStep1(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Ville actuelle'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedVille,
          isExpanded: true,
          decoration: _inputDecoration('Choisir votre ville actuelle'),
          items: _villesCameroun
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) => setState(() {
            _selectedVille = v;
            _selectedSchool = null;
            _selectedNiveau = null;
          }),
        ),
        const SizedBox(height: 16),
        _label('Quartier'),
        const SizedBox(height: 6),
        TextField(
          controller: _quartierController,
          decoration: _inputDecoration('Saisissez votre quartier'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),
        _primaryButton('Continuer', _selectedVille != null ? _goToStep1 : null),
      ],
    );
  }

  Widget _buildStep1() {
    if (_isBts) return _buildBtsStep();
    if (_isRapportStage) return _buildRapportStep();
    if (_isInscription) return _buildInscriptionStep();
    final options = _subOptions;
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _step = 0;
              _selectedSubOption = null;
            }),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Changer de ville'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...options.map(_optionCard),
        const SizedBox(height: 24),
        _primaryButton(
          'Continuer vers le paiement',
          _selectedSubOption != null ? _confirmSubOption : null,
        ),
      ],
    );
  }

  Widget _buildInscriptionStep() {
    if (_isLoadingSchools) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final schools = _filteredInscriptionSchools;
    if (schools.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aucune école disponible à ${_selectedVille ?? 'cette ville'}.\nContactez-nous pour plus d\'informations.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _step = 0),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Changer de ville'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _step = 0;
              _selectedSchool = null;
              _selectedTypeInscription = null;
            }),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Changer de ville'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _label('École — ${_selectedVille ?? ''}'),
        const SizedBox(height: 6),
        DropdownButtonFormField<School>(
          initialValue: _selectedSchool,
          isExpanded: true,
          decoration: _inputDecoration('Choisir une école'),
          items: schools
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (s) => setState(() {
            _selectedSchool = s;
            _selectedTypeInscription = null;
          }),
        ),
        if (_selectedSchool != null) ...[
          const SizedBox(height: 16),
          _label('Type de dossier'),
          const SizedBox(height: 6),
          ...[
            if ((_selectedSchool!.prixInscription ?? 0) > 0)
              _inscriptionTypeCard('inscription', 'Inscription',
                  _selectedSchool!.prixInscription!),
            if ((_selectedSchool!.prixPreinscription ?? 0) > 0)
              _inscriptionTypeCard('preinscription', 'Préinscription',
                  _selectedSchool!.prixPreinscription!),
          ],
        ],
        if (_selectedTypeInscription != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Montant à payer',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _inscriptionPrix > 0
                      ? '${_inscriptionPrix.toStringAsFixed(0)} FCFA'
                      : 'Prix non défini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _inscriptionPrix > 0 ? Colors.indigo : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _primaryButton(
          'Continuer vers le paiement',
          _canConfirmInscription ? _confirmInscription : null,
        ),
      ],
    );
  }

  Widget _inscriptionTypeCard(String typeId, String label, double price) {
    final selected = _selectedTypeInscription == typeId;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeInscription = typeId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE8EFF8),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${price.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.secondary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildRapportStep() {
    if (_isLoadingSchools) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final schools = _filteredRapportSchools;
    if (schools.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aucune école disponible à ${_selectedVille ?? 'cette ville'}.\nContactez-nous pour plus d\'informations.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _step = 0;
              _selectedSchool = null;
              _selectedNiveau = null;
            }),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Changer de ville'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _step = 0;
              _selectedSchool = null;
              _selectedNiveau = null;
            }),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Changer de ville'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _label('École — ${_selectedVille ?? ''}'),
        const SizedBox(height: 6),
        DropdownButtonFormField<School>(
          initialValue: _selectedSchool,
          isExpanded: true,
          decoration: _inputDecoration('Choisir une école'),
          items: schools
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (s) => setState(() {
            _selectedSchool = s;
            _selectedNiveau = null;
          }),
        ),
        if (_selectedSchool != null) ...[
          const SizedBox(height: 16),
          _label('Niveau'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedSchool?.id),
            initialValue: _selectedNiveau,
            isExpanded: true,
            decoration: _inputDecoration('Choisir un niveau'),
            items: _selectedSchool!.prixRapportParNiveau.keys
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (n) => setState(() => _selectedNiveau = n),
          ),
        ],
        if (_selectedNiveau != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Montant à payer',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _rapportPrix > 0
                      ? '${_rapportPrix.toStringAsFixed(0)} FCFA'
                      : 'Prix non défini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _rapportPrix > 0 ? Colors.indigo : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _primaryButton(
          'Continuer vers le paiement',
          _canConfirmRapport ? _confirmRapport : null,
        ),
      ],
    );
  }

  Widget _buildBtsStep() {
    if (_isLoadingSchools) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final schools = _filteredSchools;
    if (schools.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aucune école disponible à ${_selectedVille ?? 'cette ville'}.\nContactez-nous pour plus d\'informations.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _step = 0),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Changer de ville'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('École — ${_selectedVille ?? ''}'),
        const SizedBox(height: 6),
        DropdownButtonFormField<School>(
          initialValue: _selectedSchool,
          isExpanded: true,
          decoration: _inputDecoration('Choisir une école'),
          items: schools
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (s) => setState(() {
            _selectedSchool = s;
            _selectedNiveau = null;
          }),
        ),
        if (_selectedSchool != null) ...[
          const SizedBox(height: 16),
          _label('Niveau'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedSchool?.id),
            initialValue: _selectedNiveau,
            isExpanded: true,
            decoration: _inputDecoration('Choisir un niveau'),
            items: _selectedSchool!.filieres
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (n) => setState(() => _selectedNiveau = n),
          ),
        ],
        if (_selectedNiveau != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Montant à payer',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _btsPrix > 0
                      ? '${_btsPrix.toStringAsFixed(0)} FCFA'
                      : 'Prix non défini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _btsPrix > 0 ? Colors.indigo : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _primaryButton(
          'Continuer vers le paiement',
          _canConfirmBts ? _confirmBts : null,
        ),
      ],
    );
  }

  Widget _optionCard(ServiceSubOption opt) {
    final selected = _selectedSubOption?.id == opt.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubOption = opt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE8EFF8),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${opt.price.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.secondary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppColors.brandGradient
              : const LinearGradient(
                  colors: [Color(0xFFCCCCCC), Color(0xFFCCCCCC)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
