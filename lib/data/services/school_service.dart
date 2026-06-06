import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class SchoolService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all schools
  Future<List<School>> getAllSchools() async {
    try {
      final snapshot = await _firestore.collection('schools').get();
      return snapshot.docs
          .map((doc) => School.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching schools: $e');
      rethrow;
    }
  }

  // Get single school
  Future<School?> getSchool(String id) async {
    try {
      final doc = await _firestore.collection('schools').doc(id).get();
      if (doc.exists) {
        return School.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching school: $e');
      rethrow;
    }
  }

  // Upload logo file separately
  Future<String> uploadLogoFile(File file) async {
    return _uploadLogoFile(file);
  }

  // Add new school
  Future<String> addSchool({
    required String name,
    required String description,
    required String category,
    String? address,
    String? logoUrl,
    File? logoFile,
    List<String> filieres = const [],
    Map<String, double> prixParNiveau = const {},
  }) async {
    try {
      if (logoFile != null) {
        logoUrl = await _uploadLogoFile(logoFile);
      }

      final school = School(
        id: '',
        name: name,
        address: address,
        description: description,
        logoUrl: logoUrl,
        category: category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        filieres: filieres,
        prixParNiveau: prixParNiveau,
      );

      final docRef = await _firestore.collection('schools').add(school.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding school: $e');
      rethrow;
    }
  }

  // Update school
  Future<void> updateSchool({
    required String id,
    required String name,
    required String description,
    required String category,
    String? address,
    String? logoUrl,
    File? logoFile,
    bool clearLogo = false,
    List<String> filieres = const [],
    Map<String, double> prixParNiveau = const {},
  }) async {
    try {
      if (logoFile != null) {
        logoUrl = await _uploadLogoFile(logoFile);
      }

      final updateData = <String, dynamic>{
        'name': name,
        'address': address,
        'description': description,
        'category': category,
        'updated_at': DateTime.now().toIso8601String(),
        'filieres': filieres,
        'prix_par_niveau': prixParNiveau,
      };

      if (logoFile != null || logoUrl != null) {
        updateData['logo_url'] = logoUrl;
      } else if (clearLogo) {
        updateData['logo_url'] = null;
      }

      await _firestore.collection('schools').doc(id).update(updateData);
    } catch (e) {
      print('Error updating school: $e');
      rethrow;
    }
  }

  // Delete school
  Future<void> deleteSchool(String id) async {
    try {
      await _firestore.collection('schools').doc(id).delete();
    } catch (e) {
      print('Error deleting school: $e');
      rethrow;
    }
  }

  // Get concours linked to a school
  Future<List<Concours>> getConcoursBySchool(String schoolId) async {
    try {
      final snapshot = await _firestore
          .collection('concours')
          .where('school_id', isEqualTo: schoolId)
          .orderBy('start_date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Concours.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching concours for school: $e');
      rethrow;
    }
  }

  // Upload logo file
  Future<String> _uploadLogoFile(File file) async {
    try {
      final fileName =
          'schools/${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final reference = _storage.ref(fileName);
      await reference.putFile(file);
      return await reference.getDownloadURL();
    } catch (e) {
      print('Error uploading logo: $e');
      rethrow;
    }
  }
}
