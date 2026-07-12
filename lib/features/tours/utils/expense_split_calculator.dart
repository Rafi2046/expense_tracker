import 'package:expense_tracker/core/models/tour_participant.dart';

class SplitParticipantInput {
  final String id;
  final double value;
  final bool edited;

  const SplitParticipantInput({
    required this.id,
    required this.value,
    required this.edited,
  });
}

class ExpenseSplitCalculator {
  static List<({String id, double value})> redistributeExactSplit({
    required double totalAmount,
    required List<SplitParticipantInput> participants,
  }) {
    if (participants.isEmpty) return [];

    double editedSum = 0;
    for (final p in participants) {
      if (p.edited) editedSum += p.value;
    }

    final remaining = totalAmount - editedSum;
    final unedited = participants.where((p) => !p.edited).toList();
    if (unedited.isEmpty) return [];

    final totalCents = (remaining * 100).round();
    final baseCents = totalCents ~/ unedited.length;
    final remainderCents = totalCents - (baseCents * unedited.length);

    final results = <String, double>{};
    for (var i = 0; i < unedited.length; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      results[unedited[i].id] = cents / 100.0;
    }

    return participants.map((p) {
      if (results.containsKey(p.id)) {
        return (id: p.id, value: results[p.id]!);
      }
      return (id: p.id, value: p.edited ? p.value : 0.0);
    }).toList();
  }

  static List<({String id, double value})> resetExactSplit({
    required double totalAmount,
    required List<String> participantIds,
  }) {
    if (participantIds.isEmpty) return [];

    final totalCents = (totalAmount * 100).round();
    final baseCents = totalCents ~/ participantIds.length;
    final remainderCents = totalCents - (baseCents * participantIds.length);

    return List.generate(participantIds.length, (i) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      return (
        id: participantIds[i],
        value: cents / 100.0,
      );
    });
  }

  static List<({String id, double value})> redistributePercentSplit({
    required List<SplitParticipantInput> participants,
  }) {
    if (participants.isEmpty) return [];

    double editedSum = 0;
    for (final p in participants) {
      if (p.edited) editedSum += p.value;
    }

    if (editedSum >= 100) {
      return participants.map((p) => (id: p.id, value: p.value)).toList();
    }

    final remaining = 100 - editedSum;
    final unedited = participants.where((p) => !p.edited).toList();
    if (unedited.isEmpty) return [];

    final totalCents = (remaining * 100).round();
    final baseCents = totalCents ~/ unedited.length;
    final remainderCents = totalCents - (baseCents * unedited.length);

    final results = <String, double>{};
    for (var i = 0; i < unedited.length; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      results[unedited[i].id] = cents / 100.0;
    }

    return participants.map((p) {
      if (results.containsKey(p.id)) {
        return (id: p.id, value: results[p.id]!);
      }
      return (id: p.id, value: p.value);
    }).toList();
  }

  static List<({String id, double value})> resetPercentSplit({
    required List<String> participantIds,
  }) {
    if (participantIds.isEmpty) return [];

    const totalCents = 10000;
    final baseCents = totalCents ~/ participantIds.length;
    final remainderCents = totalCents - (baseCents * participantIds.length);

    return List.generate(participantIds.length, (i) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      return (
        id: participantIds[i],
        value: cents / 100.0,
      );
    });
  }

  static bool hadNotJoinedYet({
    required TourParticipant participant,
    required DateTime selectedDate,
  }) {
    final endOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23, 59, 59,
    );
    return participant.joinedAt.isAfter(endOfDay);
  }

  static List<TourParticipant> filterLateJoiners({
    required List<TourParticipant> participants,
    required DateTime selectedDate,
  }) {
    return participants.where((p) => hadNotJoinedYet(
      participant: p,
      selectedDate: selectedDate,
    )).toList();
  }

  static List<String> findExcludedLateJoiners({
    required List<TourParticipant> participants,
    required DateTime selectedDate,
  }) {
    final excluded = <String>[];
    for (final p in participants) {
      if (hadNotJoinedYet(participant: p, selectedDate: selectedDate)) {
        excluded.add(p.id);
      }
    }
    return excluded;
  }

  static double percentageTotal({
    required List<TourParticipant> participants,
    required Set<String> excludedIds,
    required Map<String, double> customValues,
  }) {
    double total = 0;
    for (final p in participants) {
      if (!excludedIds.contains(p.id)) {
        total += customValues[p.id] ?? 0;
      }
    }
    return total;
  }

  static bool exactAmountsExceed({
    required double totalAmount,
    required List<TourParticipant> participants,
    required Set<String> excludedIds,
    required Map<String, double> customValues,
  }) {
    if (totalAmount <= 0) return false;
    double sum = 0;
    for (final p in participants) {
      if (!excludedIds.contains(p.id)) {
        sum += customValues[p.id] ?? 0;
      }
    }
    return (sum * 100).round() > (totalAmount * 100).round();
  }

  static int includedCount({
    required List<TourParticipant> participants,
    required Set<String> excludedIds,
  }) {
    return participants.where((p) => !excludedIds.contains(p.id)).length;
  }

  static String? previewAmount({
    required String participantId,
    required double totalAmount,
    required List<TourParticipant> participants,
    required Set<String> excludedIds,
    required Map<String, double> customValues,
    required String splitType,
    required String currencySymbol,
  }) {
    if (totalAmount <= 0) return null;
    final count = includedCount(participants: participants, excludedIds: excludedIds);
    if (count == 0) return null;
    final excluded = excludedIds.contains(participantId);

    switch (splitType) {
      case 'equal':
      case 'exclusion':
        if (excluded) return '${currencySymbol}0';
        final included = participants.where((p) => !excludedIds.contains(p.id)).toList();
        final idx = included.indexWhere((p) => p.id == participantId);
        if (idx == -1) return null;
        final totalCents = (totalAmount * 100).round();
        final baseCents = totalCents ~/ count;
        final remainderCents = totalCents - (baseCents * count);
        final cents = baseCents + (idx < remainderCents ? 1 : 0);
        final share = cents / 100.0;
        return '$currencySymbol${share.toStringAsFixed(share == share.roundToDouble() ? 0 : 2)}';
      case 'percentage':
        if (excluded) return null;
        final pct = customValues[participantId] ?? 0;
        final share = totalAmount * pct / 100;
        return '$currencySymbol${share.toStringAsFixed(share == share.roundToDouble() ? 0 : 2)}';
      case 'exact':
        if (excluded) return null;
        final val = customValues[participantId];
        if (val == null) return null;
        return '$currencySymbol${val.toStringAsFixed(val == val.roundToDouble() ? 0 : 2)}';
      default:
        return null;
    }
  }

  static String? validate({
    required double amount,
    required String paidById,
    required List<TourParticipant> participants,
    required Set<String> excludedIds,
    required Map<String, double> customValues,
    required String splitType,
    required String currencySymbol,
  }) {
    if (amount <= 0) return 'Enter a valid amount';
    if (paidById.isEmpty) return 'Select who paid';

    if (splitType == 'exact') {
      final total = participants
          .where((p) => !excludedIds.contains(p.id))
          .fold(0.0, (s, p) => s + (customValues[p.id] ?? 0));
      if ((total * 100).round() != (amount * 100).round()) {
        return 'Exact amounts must total $currencySymbol${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
      }
    }

    if (splitType == 'percentage') {
      final total = participants
          .where((p) => !excludedIds.contains(p.id))
          .fold(0.0, (s, p) => s + (customValues[p.id] ?? 0));
      if ((total * 100).round() != 10000) return 'Percentages must total 100%';
    }

    if (splitType != 'exact' && splitType != 'percentage') {
      if (includedCount(participants: participants, excludedIds: excludedIds) == 0) {
        return 'At least one person must be included';
      }
    }

    return null;
  }

  static Map<String, double> extractCustomValues({
    required List<TourParticipant> participants,
    required Map<String, String> textValues,
  }) {
    final result = <String, double>{};
    for (final p in participants) {
      final v = double.tryParse(textValues[p.id] ?? '');
      if (v != null) result[p.id] = v;
    }
    return result;
  }

  static Map<String, String> computePreviews({
    required List<TourParticipant> participants,
    required double totalAmount,
    required Set<String> excludedIds,
    required Map<String, double> customValues,
    required String splitType,
    required String currencySymbol,
  }) {
    final previews = <String, String>{};
    for (final p in participants) {
      final result = previewAmount(
        participantId: p.id,
        totalAmount: totalAmount,
        participants: participants,
        excludedIds: excludedIds,
        customValues: customValues,
        splitType: splitType,
        currencySymbol: currencySymbol,
      );
      if (result != null) {
        previews[p.id] = result;
      }
    }
    return previews;
  }
}
