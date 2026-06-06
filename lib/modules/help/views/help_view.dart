import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/help/controllers/help_controller.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide & Support'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section FAQ
            _buildSectionTitle('Questions Fréquentes'),
            const SizedBox(height: 16),
            _buildFaqItem(
              question: 'Comment créer un compte ?',
              answer:
                  'Pour créer un compte, cliquez sur "S\'inscrire" et remplissez le formulaire avec vos informations personnelles.',
            ),
            _buildFaqItem(
              question: 'Comment rechercher un concours ?',
              answer:
                  'Utilisez la barre de recherche dans la section "Concours" ou naviguez dans les différentes catégories.',
            ),
            _buildFaqItem(
              question: 'Comment contacter le support ?',
              answer:
                  'Vous pouvez nous contacter via l\'email support@mhdcooperation.com, par téléphone au +237658639119 ou utiliser le formulaire de contact ci-dessous.',
            ),

            const SizedBox(height: 32),

            // Section Contact
            _buildSectionTitle('Nous Contacter'),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@mhdcooperation.com',
            ),
            _buildContactItem(
              icon: Icons.phone,
              title: 'Téléphone',
              subtitle: '+237658639119',
            ),
            _buildContactItem(
              icon: Icons.location_on,
              title: 'Adresse',
              subtitle: 'Yaoundé, Cameroun',
            ),

            const SizedBox(height: 32),

            // Formulaire de contact
            _buildSectionTitle('Envoyer un Message'),
            const SizedBox(height: 16),
            _buildContactForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(Get.context!).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
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
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
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
      child: ListTile(
        leading: Icon(icon, color: Theme.of(Get.context!).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Votre nom',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Votre email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Votre message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Logique d'envoi du message
                Get.showSnackbar(
                  const GetSnackBar(
                    title: 'Message envoyé',
                    message: 'Nous vous répondrons dans les plus brefs délais.',
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Envoyer'),
            ),
          ),
        ],
      ),
    );
  }
}
