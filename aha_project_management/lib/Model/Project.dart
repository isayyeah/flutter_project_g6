import 'package:aha_project_management/Model/MyUser.dart';

class Project {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  String budget;

  Project({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.budget,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toUtc(),
      'endDate': endDate.toUtc(),
      'budget': budget,
    };
  }
}
