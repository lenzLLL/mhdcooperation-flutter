import 'package:flutter/material.dart';

enum DossierStatus {
  enCours('en_cours', 'En cours'),
  valide('valide', 'Validé'),
  incomplet('incomplet', 'Incomplet'),
  rejete('rejete', 'Rejeté'),
  pending('pending', 'En attente'),
  paid('paid', 'Payé');

  const DossierStatus(this.value, this.label);

  final String value;
  final String label;

  Color get color {
    switch (this) {
      case DossierStatus.valide:
      case DossierStatus.paid:
        return const Color(0xFF10B981);
      case DossierStatus.enCours:
        return Colors.blue;
      case DossierStatus.incomplet:
        return Colors.orange;
      case DossierStatus.rejete:
        return Colors.red;
      case DossierStatus.pending:
        return Colors.amber;
    }
  }

  static DossierStatus fromString(String? value) {
    return DossierStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => DossierStatus.enCours,
    );
  }
}
