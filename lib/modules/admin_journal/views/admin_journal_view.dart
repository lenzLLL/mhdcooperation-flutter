import 'package:flutter/material.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/data/services/api_client.dart';

class _AuditEntry {
  final String actorName;
  final String action;
  final String summary;
  final DateTime? createdAt;

  _AuditEntry.fromJson(Map<String, dynamic> json)
      : actorName = json['actorName']?.toString() ?? 'Inconnu',
        action = json['action']?.toString() ?? '',
        summary = json['summary']?.toString() ?? '',
        createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal();
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Journal d'audit (qui a fait quoi), réservé au super-admin : mêmes données
/// que la console web, lues via l'API qui vérifie le rôle.
class AdminJournalView extends StatefulWidget {
  const AdminJournalView({super.key});

  @override
  State<AdminJournalView> createState() => _AdminJournalViewState();
}

class _AdminJournalViewState extends State<AdminJournalView> {
  List<_AuditEntry>? _entries;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get('/api/admin/journal');
      final list = (res['entries'] as List<dynamic>)
          .map((e) => _AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _entries = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de charger le journal.');
    }
  }

  IconData _icon(String action) {
    if (action.startsWith('withdrawal')) return Icons.account_balance_wallet_rounded;
    if (action.startsWith('promo')) return Icons.local_offer_rounded;
    if (action.startsWith('user')) return Icons.person_rounded;
    if (action.startsWith('document') || action.startsWith('dossier')) return Icons.folder_rounded;
    if (action.startsWith('school')) return Icons.school_rounded;
    if (action.startsWith('concours')) return Icons.menu_book_rounded;
    return Icons.history_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final entries = _entries
        ?.where((e) => q.isEmpty || e.actorName.toLowerCase().contains(q) || e.summary.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Journal d'audit")),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              ),
            )
          : entries == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un admin ou une action',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: entries.isEmpty
                            ? ListView(children: const [
                                Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text('Aucune action enregistrée.', textAlign: TextAlign.center),
                                ),
                              ])
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: entries.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final e = entries[i];
                                  final d = e.createdAt;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(_icon(e.action), color: AppColors.primary),
                                    title: Text(e.summary, style: const TextStyle(fontSize: 14)),
                                    subtitle: Text(
                                      '${e.actorName}'
                                      '${d == null ? '' : ' · ${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}'}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
