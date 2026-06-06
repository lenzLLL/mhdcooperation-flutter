import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'dart:io';

class ConcoursService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all schools for dropdown
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

  // Get all concours with school information
  Future<List<Concours>> getAllConcours() async {
    try {
      final concoursSnapshot = await _firestore.collection('concours').get();
      final schools = await getAllSchools();
      final schoolsMap = {for (var school in schools) school.id: school};

      return concoursSnapshot.docs.map((doc) {
        final data = doc.data();
        final schoolId = data['school_id'] ?? '';
        final school = schoolsMap[schoolId];

        return Concours.fromJson({
          ...data,
          'id': doc.id,
          'school_name': school?.name,
          'school_logo_url': school?.logoUrl,
        });
      }).toList();
    } catch (e) {
      print('Error fetching concours: $e');
      rethrow;
    }
  }

  // Get single concours with school information
  Future<Concours?> getConcours(String id) async {
    try {
      final doc = await _firestore.collection('concours').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final schoolId = data['school_id'] ?? '';

        if (schoolId.isNotEmpty) {
          final schoolDoc = await _firestore
              .collection('schools')
              .doc(schoolId)
              .get();
          if (schoolDoc.exists) {
            final schoolData = schoolDoc.data()!;
            return Concours.fromJson({
              ...data,
              'id': doc.id,
              'school_name': schoolData['name'],
              'school_logo_url': schoolData['logo_url'],
            });
          }
        }

        return Concours.fromJson({...data, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching concours: $e');
      rethrow;
    }
  }

  // Add new concours
  Future<String> addConcours({
    required String title,
    required String description,
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? applicationDeadline,
    String? status,
    double? applicationFees,
    String? sessionCategory,
    int? ageLimit,
    File? photoFile,
    File? docFile,
    File? pdfFile,
    String? ville,
  }) async {
    try {
      String? photoUrl;
      String? docUrl;
      String? pdfUrl;

      // Upload media files if provided
      if (photoFile != null) {
        photoUrl = await _uploadMediaFile(photoFile, 'photos');
      }
      if (docFile != null) {
        docUrl = await _uploadMediaFile(docFile, 'documents');
      }
      if (pdfFile != null) {
        pdfUrl = await _uploadMediaFile(pdfFile, 'pdfs');
      }

      final concours = Concours(
        id: '',
        title: title,
        description: description,
        schoolId: schoolId,
        startDate: startDate,
        endDate: endDate,
        applicationDeadline: applicationDeadline,
        status: status ?? 'active',
        applicationFees: applicationFees,
        sessionCategory: sessionCategory,
        photoUrl: photoUrl,
        docUrl: docUrl,
        ageLimit: ageLimit,
        pdfUrl: pdfUrl,
        ville: ville,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('concours')
          .add(concours.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding concours: $e');
      rethrow;
    }
  }

  // Update concours
  Future<void> updateConcours({
    required String id,
    required String title,
    required String description,
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? applicationDeadline,
    String? status,
    double? applicationFees,
    String? sessionCategory,
    int? ageLimit,
    File? photoFile,
    File? docFile,
    File? pdfFile,
    String? ville,
  }) async {
    try {
      String? photoUrl;
      String? docUrl;
      String? pdfUrl;

      // Upload new media files if provided
      if (photoFile != null) {
        photoUrl = await _uploadMediaFile(photoFile, 'photos');
      }
      if (docFile != null) {
        docUrl = await _uploadMediaFile(docFile, 'documents');
      }
      if (pdfFile != null) {
        pdfUrl = await _uploadMediaFile(pdfFile, 'pdfs');
      }

      final updateData = {
        'title': title,
        'description': description,
        'school_id': schoolId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'application_deadline': applicationDeadline?.toIso8601String(),
        'status': status,
        'application_fees': applicationFees,
        'session_category': sessionCategory,
        'age_limit': ageLimit,
        'ville': ville,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (photoUrl != null) {
        updateData['photo_url'] = photoUrl;
      }
      if (docUrl != null) {
        updateData['doc_url'] = docUrl;
      }
      if (pdfUrl != null) {
        updateData['pdf_url'] = pdfUrl;
      }

      await _firestore.collection('concours').doc(id).update(updateData);
    } catch (e) {
      print('Error updating concours: $e');
      rethrow;
    }
  }

  // Delete concours
  Future<void> deleteConcours(String id) async {
    try {
      await _firestore.collection('concours').doc(id).delete();
    } catch (e) {
      print('Error deleting concours: $e');
      rethrow;
    }
  }

  // Upload media file
  Future<String> _uploadMediaFile(File file, String folder) async {
    try {
      final fileName =
          'concours/$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final reference = _storage.ref(fileName);
      await reference.putFile(file);
      return await reference.getDownloadURL();
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }
}
