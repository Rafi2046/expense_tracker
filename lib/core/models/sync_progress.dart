class SyncProgress {
  final String currentTable;
  final int documentsFetched;
  final bool isComplete;
  final String? error;

  const SyncProgress({
    this.currentTable = '',
    this.documentsFetched = 0,
    this.isComplete = false,
    this.error,
  });

  SyncProgress copyWith({
    String? currentTable,
    int? documentsFetched,
    bool? isComplete,
    String? error,
  }) {
    return SyncProgress(
      currentTable: currentTable ?? this.currentTable,
      documentsFetched: documentsFetched ?? this.documentsFetched,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}
