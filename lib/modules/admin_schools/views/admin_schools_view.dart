import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import '../controllers/admin_schools_controller.dart';
import 'dart:io';

class AdminSchoolsView extends GetView<AdminSchoolsController> {
  const AdminSchoolsView({super.key});

  bool get _isSadmin {
    final user = Get.find<SessionService>().currentUser.value;
    return user?.role.toUpperCase() == 'SADMIN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Écoles'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: controller.loadSchools,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une école...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: controller.searchSchools,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _showAddSchoolDialog(context),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.schools.length,
                itemBuilder: (context, index) {
                  final school = controller.schools[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: school.logoUrl != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: school.logoUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.school, size: 50),
                              ),
                            )
                          : const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.school),
                            ),
                      title: Text(school.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${school.address ?? ''} • ${school.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (school.filieres.isNotEmpty)
                            Text(
                              school.filieres.join(' • '),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.indigo,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Modifier'),
                            onTap: () =>
                                _showEditSchoolDialog(context, school),
                          ),
                          if (_isSadmin)
                            PopupMenuItem(
                              child: const Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () =>
                                  _confirmDelete(context, school.id),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showAddSchoolDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    File? selectedLogoFile;
    String? selectedLogoUrl;
    final isLoading = false.obs;
    final isUploadingLogo = false.obs;
    final selectedFilieres = <String>[].obs;
    final prixControllers = <String, TextEditingController>{};

    for (final n in School.niveauxDisponibles) {
      prixControllers[n] = TextEditingController();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter une école'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration:
                        const InputDecoration(labelText: 'Catégorie *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Description *'),
                    maxLines: 3,
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFilieresSection(
                    selectedFilieres: selectedFilieres,
                    prixControllers: prixControllers,
                    setState: setState,
                  ),
                  const SizedBox(height: 16),
                  _buildLogoSection(
                    selectedLogoFile: selectedLogoFile,
                    selectedLogoUrl: selectedLogoUrl,
                    isUploadingLogo: isUploadingLogo,
                    onLogoSelected: (file, url) {
                      setState(() {
                        selectedLogoFile = file;
                        selectedLogoUrl = url;
                      });
                    },
                    onLogoClear: () {
                      setState(() {
                        selectedLogoFile = null;
                        selectedLogoUrl = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            Obx(
              () => TextButton(
                onPressed: isLoading.value || isUploadingLogo.value
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          isLoading.value = true;
                          final prix = _buildPrixMap(
                            selectedFilieres,
                            prixControllers,
                          );
                          await controller.addSchool(
                            name: nameController.text,
                            description: descriptionController.text,
                            category: categoryController.text,
                            address: addressController.text,
                            logoUrl: selectedLogoUrl,
                            filieres: selectedFilieres.toList(),
                            prixParNiveau: prix,
                          );
                          isLoading.value = false;
                          Navigator.pop(context);
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSchoolDialog(BuildContext context, School school) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: school.name);
    final addressController = TextEditingController(text: school.address);
    final descriptionController =
        TextEditingController(text: school.description);
    final categoryController = TextEditingController(text: school.category);
    File? selectedLogoFile;
    String? selectedLogoUrl = school.logoUrl;
    bool clearLogo = false;
    final isLoading = false.obs;
    final isUploadingLogo = false.obs;
    final selectedFilieres = <String>[...school.filieres].obs;
    final prixControllers = <String, TextEditingController>{};

    for (final n in School.niveauxDisponibles) {
      final existing = school.prixParNiveau[n];
      prixControllers[n] = TextEditingController(
        text: existing != null && existing > 0
            ? existing.toStringAsFixed(0)
            : '',
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'école'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration:
                        const InputDecoration(labelText: 'Catégorie *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Description *'),
                    maxLines: 3,
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFilieresSection(
                    selectedFilieres: selectedFilieres,
                    prixControllers: prixControllers,
                    setState: setState,
                  ),
                  const SizedBox(height: 16),
                  _buildLogoSection(
                    selectedLogoFile: selectedLogoFile,
                    selectedLogoUrl: selectedLogoUrl,
                    isUploadingLogo: isUploadingLogo,
                    onLogoSelected: (file, url) {
                      setState(() {
                        selectedLogoFile = file;
                        selectedLogoUrl = url;
                        clearLogo = false;
                      });
                    },
                    onLogoClear: () {
                      setState(() {
                        selectedLogoFile = null;
                        selectedLogoUrl = null;
                        clearLogo = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            Obx(
              () => TextButton(
                onPressed: isLoading.value || isUploadingLogo.value
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          isLoading.value = true;
                          final prix = _buildPrixMap(
                            selectedFilieres,
                            prixControllers,
                          );
                          await controller.updateSchool(
                            id: school.id,
                            name: nameController.text,
                            description: descriptionController.text,
                            category: categoryController.text,
                            address: addressController.text,
                            logoUrl: selectedLogoUrl,
                            logoFile: selectedLogoFile,
                            clearLogo: clearLogo,
                            filieres: selectedFilieres.toList(),
                            prixParNiveau: prix,
                          );
                          isLoading.value = false;
                          Navigator.pop(context);
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Modifier'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilieresSection({
    required RxList<String> selectedFilieres,
    required Map<String, TextEditingController> prixControllers,
    required StateSetter setState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filières proposées',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        ...School.niveauxDisponibles.map((niveau) {
          final checked = selectedFilieres.contains(niveau);
          return Column(
            children: [
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(niveau),
                value: checked,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedFilieres.add(niveau);
                    } else {
                      selectedFilieres.remove(niveau);
                      prixControllers[niveau]?.clear();
                    }
                  });
                },
              ),
              if (checked)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: TextFormField(
                    controller: prixControllers[niveau],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Prix $niveau (FCFA)',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixText: 'FCFA',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (double.tryParse(v) == null) return 'Nombre invalide';
                      return null;
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLogoSection({
    required File? selectedLogoFile,
    required String? selectedLogoUrl,
    required RxBool isUploadingLogo,
    required void Function(File, String) onLogoSelected,
    required VoidCallback onLogoClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedLogoUrl != null)
          Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: selectedLogoFile != null
                    ? Image.file(selectedLogoFile, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: selectedLogoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.red),
                      ),
              ),
              TextButton.icon(
                onPressed: onLogoClear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer le logo'),
              ),
            ],
          ),
        Obx(
          () => ElevatedButton.icon(
            onPressed: isUploadingLogo.value
                ? null
                : () async {
                    final result =
                        await FilePicker.pickFiles(type: FileType.image);
                    if (result != null) {
                      final file = File(result.files.single.path!);
                      isUploadingLogo.value = true;
                      try {
                        final url = await controller.uploadLogoFile(file);
                        onLogoSelected(file, url);
                      } catch (_) {
                        Get.snackbar(
                          'Erreur',
                          'Impossible de télécharger le logo.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } finally {
                        isUploadingLogo.value = false;
                      }
                    }
                  },
            icon: const Icon(Icons.image),
            label: Text(
              selectedLogoUrl == null ? 'Sélectionner logo' : 'Changer logo',
            ),
          ),
        ),
        Obx(
          () => isUploadingLogo.value
              ? const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Map<String, double> _buildPrixMap(
    List<String> filieres,
    Map<String, TextEditingController> controllers,
  ) {
    final map = <String, double>{};
    for (final f in filieres) {
      final val = double.tryParse(controllers[f]?.text.trim() ?? '');
      if (val != null && val > 0) map[f] = val;
    }
    return map;
  }

  void _confirmDelete(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette école ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteSchool(schoolId);
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
