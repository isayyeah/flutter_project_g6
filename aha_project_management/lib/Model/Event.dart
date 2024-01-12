class Event {
  String id;
  String name;
  String projectId;

  Event({
    required this.id,
    required this.name,
    required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'projectId': projectId,
    };
  }
}
