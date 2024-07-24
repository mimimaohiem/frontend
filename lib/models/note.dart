class Note {
  String? id;
  String? note;
  List<Map<String, dynamic>>? processedData;
  String? timestamp;

  Note({
    this.id,
    this.note,
    this.processedData,
    this.timestamp,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String?,
      note: json['note'] as String?,
      processedData: (json['processed_data'] as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList(),
      timestamp: json['timestamp'] as String?,
    );
  }
}
