import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aha_project_management/Model/Task.dart';
import 'package:aha_project_management/Services/task_service.dart';
import 'package:aha_project_management/Pages/home_page.dart';
import 'package:aha_project_management/Pages/login_page.dart';
import 'package:aha_project_management/Component/navbar.dart';
import 'package:aha_project_management/Services/auth_service.dart';

class TaskPage extends StatefulWidget {
  // Add the userId parameter

  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    String? userId = AuthService().getCurrentUserId();

    if (userId != null) {
      List<TaskModel> userTasks = await TaskService.getTasksForUser(userId);

      setState(() {
        tasks = userTasks;
      });
    }
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    return userDoc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Tâches'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          TaskModel task = tasks[index];
          return ListTile(
            title: Text(task.name),
            subtitle:
                Text('Deadline: ${task.deadline} - Priorité: ${task.priority}'),
          );
        },
      ),
      bottomNavigationBar: CustomNavBar(
        onTabTapped: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              String? userId = AuthService().getCurrentUserId();
              print('Current user ID: $userId');

              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskPage(),
                  ),
                );
              }
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
