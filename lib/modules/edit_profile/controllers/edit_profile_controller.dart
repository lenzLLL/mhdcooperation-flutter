import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhdcooperation/data/services/auth_service.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class EditProfileController extends GetxController {
  final sessionService = Get.find<SessionService>();

  // États de chargement
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Contrôleurs de formulaire
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  // Image de profil
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString currentImageUrl = ''.obs;

  // Clé du formulaire
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.onClose();
  }

  void _loadCurrentUserData() {
    final user = sessionService.currentUser.value;
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email ?? '';
      phoneController.text = user.phoneNumber;
      cityController.text = user.city ?? '';
      currentImageUrl.value = user.pictureUrl ?? '';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Impossible de sélectionner l\'image',
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Changer la photo de profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Caméra',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedImage.value != null || currentImageUrl.isNotEmpty)
              TextButton(
                onPressed: () {
                  Get.back();
                  selectedImage.value = null;
                  currentImageUrl.value = '';
                },
                child: const Text(
                  'Supprimer la photo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: Get.theme.primaryColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSaving.value = true;

    try {
      final authService = Get.find<AuthService>();
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final city = cityController.text.trim();
      final pictureUrl = selectedImage.value != null
          ? selectedImage.value!.path
          : currentImageUrl.value.isNotEmpty
          ? currentImageUrl.value
          : null;

      await authService.updateProfile(
        name: name,
        email: email,
        phoneNumber: phone,
        city: city,
        pictureUrl: pictureUrl,
      );

      Get.showSnackbar(
        const GetSnackBar(
          title: 'Succès',
          message: 'Profil mis à jour avec succès',
          duration: Duration(seconds: 2),
        ),
      );

      Get.back();
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Erreur lors de la sauvegarde du profil : $e',
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      isSaving.value = false;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }
}
