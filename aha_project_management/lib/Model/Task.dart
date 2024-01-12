import 'package:aha_project_management/Model/MyUser.dart';
import 'package:aha_project_management/Model/Project.dart';

class TaskModel {
  String id;
  String project;
  String name;
  String deadline;
  String priority;
  String assignedTo;
  String status;

  TaskModel(
      {required this.id,
      required this.project,
      required this.name,
      required this.deadline,
      required this.priority,
      required this.assignedTo,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project': project,
      'name': name,
      'deadline': deadline,
      'priority': priority,
      'assignedTo': assignedTo,
      'status': status,
    };
  }
}
