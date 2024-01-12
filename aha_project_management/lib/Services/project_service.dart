import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aha_project_management/Model/Project.dart';

class ProjectService {
  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');

  Future<void> updateProject(Project project) async {
    await _projectsCollection.doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }
}
