class GenUIWidgetData {
  final String id;
  final String type;
  final Map<String, dynamic> data;

  const GenUIWidgetData({
    required this.id,
    required this.type,
    required this.data,
  });

  factory GenUIWidgetData.fromJson(String id, Map<String, dynamic> json) {
    return GenUIWidgetData(
      id: id,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
    };
  }
}
