import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CreatorService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static Future<void> saveProject({
    required String type,
    required String prompt,
    String? mediaUrl,
    bool published = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Usuário não autenticado.');

    await _db.collection('projects').add({
      'uid': user.uid,
      'authorName': user.displayName?.trim().isNotEmpty == true ? user.displayName : 'Criador',
      'type': type,
      'prompt': prompt,
      'mediaUrl': mediaUrl,
      'published': published,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> uploadMedia(XFile file, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Faça login para publicar.');

    final extension = file.path.contains('.') ? file.path.split('.').last.toLowerCase() : (type == 'Vídeo' ? 'mp4' : 'jpg');
    final ref = _storage.ref('users/${user.uid}/posts/${DateTime.now().millisecondsSinceEpoch}.$extension');
    final metadata = SettableMetadata(
      contentType: type == 'Vídeo' ? 'video/mp4' : 'image/jpeg',
      cacheControl: 'public,max-age=31536000',
    );
    await ref.putFile(File(file.path), metadata);
    return ref.getDownloadURL();
  }

  static Future<void> publishFile({required XFile file, required String type, String prompt = ''}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Faça login para publicar.');
    final url = await uploadMedia(file, type);
    await saveProject(type: type, prompt: prompt.isEmpty ? 'Criação publicada por ${user.displayName ?? 'Criador'}' : prompt, mediaUrl: url, published: true);
  }

  static Future<void> publishExisting(String projectId) async {
    await _db.collection('projects').doc(projectId).update({'published': true});
  }

  static Future<void> unpublish(String projectId) async {
    await _db.collection('projects').doc(projectId).update({'published': false});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> myProjects() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('projects').where('uid', isEqualTo: user.uid).orderBy('createdAt', descending: true).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> publicFeed() {
    return _db.collection('projects').where('published', isEqualTo: true).orderBy('createdAt', descending: true).limit(50).snapshots();
  }

  static Future<void> toggleLike(String projectId, bool currentlyLiked) async {
    final ref = _db.collection('projects').doc(projectId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['likes'] ?? 0) as num;
      tx.update(ref, {'likes': (current.toInt() + (currentlyLiked ? -1 : 1)).clamp(0, 1000000)});
    });
  }
}
