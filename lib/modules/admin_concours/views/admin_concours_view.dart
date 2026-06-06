import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/constants/villes_cameroun.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import '../controllers/admin_concours_controller.dart';
import 'dart:io';

class AdminConcoursView extends GetView<AdminConcoursController> {
  const AdminConcoursView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Concours'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: controller.loadConcours,
                  child: const Text('Réessayer'),
                )
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
                        hintText: 'Rechercher un concours...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: controller.searchConcours,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _showAddConcoursDialog(context),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.concoursItems.length,
                itemBuilder: (context, index) {
                  final concours = controller.concoursItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: concours.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: concours.photoUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            )
                          : const Icon(Icons.menu_book, color: Colors.blue),
                      title: Text(concours.title),
                      subtitle: Text(
                        '${concours.schoolName ?? 'École'} • ${concours.status}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          final role = Get.find<SessionService>()
                              .currentUser
                              .value
                              ?.role
                              .toUpperCase();
                          return [
                            PopupMenuItem(
                              child: const Text('Modifier'),
                              onTap: () =>
                                  _showEditConcoursDialog(context, concours),
                            ),
                            if (role == 'SADMIN')
                              PopupMenuItem(
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () =>
                                    _confirmDelete(context, concours.id),
                              ),
                          ];
                        },
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

  void _showAddConcoursDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedSchoolId;
    String? selectedVille;
    DateTime? startDate;
    DateTime? endDate;
    DateTime? applicationDeadline;
    final feesController = TextEditingController();
    final ageLimitController = TextEditingController();
    final sessionCategoryController = TextEditingController();
    final isLoading = false.obs;
    final schools = <School>[].obs;
    final isLoadingSchools = true.obs;
    File? photoFile;
    File? docFile;
    File? pdfFile;

    // Load schools
    controller.getSchools().then((loadedSchools) {
      schools.assignAll(loadedSchools);
      isLoadingSchools.value = false;
    }).catchError((e) {
      print('Error loading schools: $e');
      isLoadingSchools.value = false;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un concours'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titre *'),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description *'),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => isLoadingSchools.value
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          value: selectedSchoolId,
                          decoration: const InputDecoration(labelText: 'École (optionnel)'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Aucune école (concours général)'),
                            ),
                            ...schools.map((school) => DropdownMenuItem<String>(
                                  value: school.id,
                                  child: Text(school.name, overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSchoolId = value;
                            });
                          },
                          validator: (value) => null, // Optional field
                        ),
                      )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: selectedVille,
                      decoration: const InputDecoration(labelText: 'Ville (optionnel)'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Sélectionner une ville'),
                        ),
                        ...villesCameroun.map((ville) => DropdownMenuItem<String>(
                              value: ville,
                              child: Text(ville),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedVille = value;
                        });
                      },
                      validator: (value) => null, // Optional field
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        startDate != null
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: startDate != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de fin *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        endDate != null
                            ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: endDate != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          applicationDeadline = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date limite d\'inscription (optionnel)',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        applicationDeadline != null
                            ? '${applicationDeadline!.day}/${applicationDeadline!.month}/${applicationDeadline!.year}'
                            : 'Optionnel',
                        style: TextStyle(
                          color: applicationDeadline != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: feesController,
                    decoration: const InputDecoration(labelText: 'Frais d\'inscription (€)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ageLimitController,
                    decoration: const InputDecoration(labelText: 'Limite d\'âge (ans)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: sessionCategoryController.text.isNotEmpty ? sessionCategoryController.text : null,
                    decoration: const InputDecoration(labelText: 'Catégorie (optionnel)'),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Ingénierie',
                        child: Text('Ingénierie'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Gestion et Management',
                        child: Text('Gestion et Management'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Médécine/Santé',
                        child: Text('Médécine/Santé'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Administration',
                        child: Text('Administration'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Enseignement',
                        child: Text('Enseignement'),
                      ),
                    ],
                    onChanged: (value) {
                      sessionCategoryController.text = value ?? '';
                    },
                    validator: (value) => null, // Optional field
                  ),
                  const SizedBox(height: 16),
                  const Text('Fichiers du concours', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      // Cover (Image)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.image, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Cover (Image)', style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (photoFile != null)
                                          Text(
                                            photoFile!.path.split('/').last,
                                            style: const TextStyle(fontSize: 12, color: Colors.green),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else
                                          const Text('Aucun fichier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (photoFile != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          photoFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Supprimer'),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(type: FileType.image);
                                      if (result != null) {
                                        setState(() {
                                          photoFile = File(result.files.single.path!);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: Text(photoFile == null ? 'Ajouter' : 'Changer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Document
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Document', style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (docFile != null)
                                          Text(
                                            docFile!.path.split('/').last,
                                            style: const TextStyle(fontSize: 12, color: Colors.green),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else
                                          const Text('Aucun fichier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (docFile != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          docFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Supprimer'),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                                      );
                                      if (result != null) {
                                        setState(() {
                                          docFile = File(result.files.single.path!);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: Text(docFile == null ? 'Ajouter' : 'Changer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // PDF Supplémentaire
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('PDF Supplémentaire', style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (pdfFile != null)
                                          Text(
                                            pdfFile!.path.split('/').last,
                                            style: const TextStyle(fontSize: 12, color: Colors.green),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else
                                          const Text('Aucun fichier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (pdfFile != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          pdfFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Supprimer'),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf'],
                                      );
                                      if (result != null) {
                                        setState(() {
                                          pdfFile = File(result.files.single.path!);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: Text(pdfFile == null ? 'Ajouter' : 'Changer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (startDate == null || endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez sélectionner les dates de début et fin')),
                          );
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          isLoading.value = true;
                          await controller.addConcours(
                            title: titleController.text,
                            description: descriptionController.text,
                            schoolId: selectedSchoolId ?? '',
                            startDate: startDate!,
                            endDate: endDate!,
                            applicationDeadline: applicationDeadline,
                            applicationFees: feesController.text.isNotEmpty
                                ? double.parse(feesController.text)
                                : null,
                            ageLimit: ageLimitController.text.isNotEmpty
                                ? int.parse(ageLimitController.text)
                                : null,
                            sessionCategory: sessionCategoryController.text.isNotEmpty
                                ? sessionCategoryController.text
                                : null,
                            photoFile: photoFile,
                            docFile: docFile,
                            pdfFile: pdfFile,
                            ville: selectedVille,
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

  void _showEditConcoursDialog(BuildContext context, dynamic concours) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: concours.title);
    final descriptionController = TextEditingController(text: concours.description);
    String? selectedSchoolId = concours.schoolId.isNotEmpty ? concours.schoolId : '';
    String? selectedVille = concours.ville;
    DateTime? startDate = concours.startDate;
    DateTime? endDate = concours.endDate;
    DateTime? applicationDeadline = concours.applicationDeadline;
    final feesController = TextEditingController(
      text: concours.applicationFees?.toString() ?? '',
    );
    final ageLimitController = TextEditingController(
      text: concours.ageLimit?.toString() ?? '',
    );
    final sessionCategoryController = TextEditingController(
      text: concours.sessionCategory ?? '',
    );
    final isLoading = false.obs;
    final schools = <School>[].obs;
    final isLoadingSchools = true.obs;
    File? photoFile;
    File? docFile;
    File? pdfFile;

    // Load schools
    controller.getSchools().then((loadedSchools) {
      schools.assignAll(loadedSchools);
      isLoadingSchools.value = false;
    }).catchError((e) {
      print('Error loading schools: $e');
      isLoadingSchools.value = false;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le concours'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titre *'),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description *'),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => isLoadingSchools.value
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          value: selectedSchoolId,
                          decoration: const InputDecoration(labelText: 'École (optionnel)'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Aucune école (concours général)'),
                            ),
                            ...schools.map((school) => DropdownMenuItem<String>(
                                  value: school.id,
                                  child: Text(school.name, overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSchoolId = value;
                            });
                          },
                          validator: (value) => null, // Optional field
                        ),
                      )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: selectedVille,
                      decoration: const InputDecoration(labelText: 'Ville (optionnel)'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Sélectionner une ville'),
                        ),
                        ...villesCameroun.map((ville) => DropdownMenuItem<String>(
                              value: ville,
                              child: Text(ville),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedVille = value;
                        });
                      },
                      validator: (value) => null, // Optional field
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        startDate != null
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: startDate != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de fin *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        endDate != null
                            ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: endDate != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: applicationDeadline ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          applicationDeadline = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date limite d\'inscription (optionnel)',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        applicationDeadline != null
                            ? '${applicationDeadline!.day}/${applicationDeadline!.month}/${applicationDeadline!.year}'
                            : 'Optionnel',
                        style: TextStyle(
                          color: applicationDeadline != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: feesController,
                    decoration: const InputDecoration(labelText: 'Frais d\'inscription (€)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ageLimitController,
                    decoration: const InputDecoration(labelText: 'Limite d\'âge (ans)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: sessionCategoryController.text.isNotEmpty ? sessionCategoryController.text : null,
                    decoration: const InputDecoration(labelText: 'Catégorie (optionnel)'),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Ingénierie',
                        child: Text('Ingénierie'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Gestion et Management',
                        child: Text('Gestion et Management'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Médécine/Santé',
                        child: Text('Médécine/Santé'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Administration',
                        child: Text('Administration'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Enseignement',
                        child: Text('Enseignement'),
                      ),
                    ],
                    onChanged: (value) {
                      sessionCategoryController.text = value ?? '';
                    },
                    validator: (value) => null, // Optional field
                  ),
                  const SizedBox(height: 16),
                  const Text('Fichiers du concours', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      // Cover (Image)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.image, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Cover (Image)', style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (photoFile != null)
                                          Text(
                                            photoFile!.path.split('/').last,
                                            style: const TextStyle(fontSize: 12, color: Colors.green),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else if (concours.photoUrl != null)
                                          Text(
                                            'Existant',
                                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                                          )
                                        else
                                          const Text('Aucun fichier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (photoFile != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          photoFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Supprimer'),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(type: FileType.image);
                                      if (result != null) {
                                        setState(() {
                                          photoFile = File(result.files.single.path!);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: Text(photoFile == null ? 'Ajouter' : 'Changer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Document
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Document', style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (docFile != null)
                                          Text(
                                            docFile!.path.split('/').last,
                                            style: const TextStyle(fontSize: 12, color: Colors.green),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else if (concours.docUrl != null)
                                          Text(
                                            'Existant',
                                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                                          )
                                        else
                                          const Text('Aucun fichier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (docFile != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          docFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Supprimer'),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                                      );
                                      if (result != null) {
                                        setState(() {
                                          docFile = File(result.files.single.path!);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: Text(docFile == null ? 'Ajouter' : 'Changer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // PDF Supplémentaire
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('PDF Supplémentaire', style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (pdfFile != null)
                                          Text(
                                            pdfFile!.path.split('/').last,
                                            style: const TextStyle(fontSize: 12, color: Colors.green),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else if (concours.pdfUrl != null)
                                          Text(
                                            'Existant',
                                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                                          )
                                        else
                                          const Text('Aucun fichier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (pdfFile != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          pdfFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Supprimer'),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf'],
                                      );
                                      if (result != null) {
                                        setState(() {
                                          pdfFile = File(result.files.single.path!);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: Text(pdfFile == null ? 'Ajouter' : 'Changer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (startDate == null || endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez sélectionner les dates de début et fin')),
                          );
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          isLoading.value = true;
                          await controller.updateConcours(
                            id: concours.id,
                            title: titleController.text,
                            description: descriptionController.text,
                            schoolId: selectedSchoolId ?? '',
                            startDate: startDate!,
                            endDate: endDate!,
                            applicationDeadline: applicationDeadline,
                            applicationFees: feesController.text.isNotEmpty
                                ? double.parse(feesController.text)
                                : null,
                            ageLimit: ageLimitController.text.isNotEmpty
                                ? int.parse(ageLimitController.text)
                                : null,
                            sessionCategory: sessionCategoryController.text.isNotEmpty
                                ? sessionCategoryController.text
                                : null,
                            photoFile: photoFile,
                            docFile: docFile,
                            pdfFile: pdfFile,
                            ville: selectedVille,
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

  void _confirmDelete(BuildContext context, String concoursId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce concours ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteConcours(concoursId);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
