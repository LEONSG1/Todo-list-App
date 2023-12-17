import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  Future<void> addNoteWithTitle(
      String note, String subtitle, DateTime timestamp) {
    return notes.add({
      'note': note,
      'subtitle': subtitle,
      'createdAt': timestamp, // Ganti kunci 'createdAt' sesuai kebutuhan Anda
    });
  }

  Stream<QuerySnapshot> getNotesStream() {
    final noteStream = notes
        .orderBy('createdAt', descending: true)
        .snapshots(); // Ganti kunci 'createdAt' sesuai kebutuhan Anda
    return noteStream;
  }

  Future<void> updateNote(String docID, String newNote, String newSubtitle) {
    return notes.doc(docID).update({
      'note': newNote,
      'subtitle': newSubtitle,
      'updatedAt':
          DateTime.now(), // Ganti kunci 'updatedAt' sesuai kebutuhan Anda
    });
  }

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  Future<List<DocumentSnapshot>> searchNotes(String query) async {
    final snapshot = await notes
        .where('note', isGreaterThanOrEqualTo: query)
        .where('note', isLessThan: '${query}z')
        .get();

    final subtitleSnapshot = await notes
        .where('subtitle', isGreaterThanOrEqualTo: query)
        .where('subtitle', isLessThan: '${query}z')
        .get();

    List<DocumentSnapshot> results = [];
    results.addAll(snapshot.docs);
    results.addAll(subtitleSnapshot.docs);

    return results;
  }
}
