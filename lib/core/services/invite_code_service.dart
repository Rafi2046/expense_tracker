import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/models/tour.dart';

class InviteCodeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _sharedTours =>
      _firestore.collection(AppConstants.toursCollection);

  Future<String> generateUniqueCode() async {
    final random = Random();
    final chars = AppConstants.inviteCodeChars;
    final length = AppConstants.inviteCodeLength;

    while (true) {
      final code = List.generate(
        length,
        (_) => chars[random.nextInt(chars.length)],
      ).join();

      final existing = await _sharedTours
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) return code;
    }
  }

  Future<Tour?> getTourByCode(String code) async {
    final snapshot = await _sharedTours
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return Tour.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
