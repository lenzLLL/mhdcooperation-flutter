import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        elevation: 0,
        actions: [
          Obx(
            () => controller.isSaving.value
                ? Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : TextButton(
                    onPressed: controller.saveProfile,
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo de profil
                _buildProfileImage(),

                const SizedBox(height: 32),

                // Champs du formulaire
                _buildFormFields(),

                const SizedBox(height: 32),

                // Bouton de sauvegarde
                _buildSaveButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Get.theme.primaryColor.withAlpha(51),
                  width: 3,
                ),
              ),
              child: Obx(() {
                if (controller.selectedImage.value != null) {
                  // Nouvelle image sélectionnée
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.file(
                      controller.selectedImage.value!,
                      fit: BoxFit.cover,
                    ),
                  );
                } else if (controller.currentImageUrl.isNotEmpty) {
                  // Image actuelle depuis l'URL
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      imageUrl: controller.currentImageUrl.value,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Pas d'image
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                }
              }),
            ),

            // Bouton d'édition
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.showImagePickerDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: controller.showImagePickerDialog,
          child: Text(
            'Changer la photo',
            style: TextStyle(
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Champ Nom
        _buildTextField(
          controller: controller.nameController,
          label: 'Nom complet',
          hint: 'Entrez votre nom complet',
          icon: Icons.person,
          validator: controller.validateName,
        ),

        const SizedBox(height: 16),

        // Champ Email
        _buildTextField(
          controller: controller.emailController,
          label: 'Email',
          hint: 'Entrez votre email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
        ),

        const SizedBox(height: 16),

        // Champ Téléphone
        _buildTextField(
          controller: controller.phoneController,
          label: 'Téléphone',
          hint: 'Entrez votre numéro de téléphone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
        ),

        const SizedBox(height: 16),

        // Champ Ville
        _buildTextField(
          controller: controller.cityController,
          label: 'Ville',
          hint: 'Entrez votre ville',
          icon: Icons.location_city,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Get.theme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Get.theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isSaving.value ? null : controller.saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: controller.isSaving.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
