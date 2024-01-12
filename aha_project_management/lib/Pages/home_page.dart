import 'package:aha_project_management/Model/MyUser.dart';
import 'package:aha_project_management/Model/Task.dart';
import 'package:aha_project_management/Services/project_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aha_project_management/Model/Project.dart';
import 'package:intl/intl.dart';
import 'package:aha_project_management/Component/navbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Project> projects = [];
  List<String> projectNamesList = [];
  List<MyUser> userNamesList = [];
  DateTime? pickedStartDate;
  DateTime? pickedEndDate;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadUsers();
  }

  Future<void> _loadProjects() async {
    QuerySnapshot<Map<String, dynamic>> projectsSnapshot =
        await FirebaseFirestore.instance.collection('projects').get();

    setState(() {
      projects = projectsSnapshot.docs
          .map((doc) => Project(
                id: doc.id,
                name: doc['name'],
                startDate: (doc['startDate'] as Timestamp).toDate(),
                endDate: (doc['endDate'] as Timestamp).toDate(),
                budget: doc['budget'],
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(projects[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProjectDialog(context);
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CustomNavBar(
        onTabTapped: (index) {
          // Handle tab changes here
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _showAddProjectDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController budgetController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Nouveau Projet'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom du Projet'),
                ),
                TextField(
                  onTap: () async {
                    DateTime? newStartDate = await _pickDateTime(context);
                    if (newStartDate != null) {
                      setState(() {
                        pickedStartDate = newStartDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date de Début',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: pickedStartDate != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(pickedStartDate!)
                        : "Sélectionner une date",
                  ),
                ),
                TextField(
                  onTap: () async {
                    DateTime? newEndDate = await _pickDateTime(context);
                    if (newEndDate != null) {
                      setState(() {
                        pickedEndDate = newEndDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date de Fin',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: pickedEndDate != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(pickedEndDate!)
                        : "Sélectionner une date",
                  ),
                ),
                TextField(
                  controller: budgetController,
                  decoration: InputDecoration(labelText: 'Budget'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                Project newProject = Project(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  startDate: pickedStartDate != null
                      ? pickedStartDate!
                          .toUtc() // Utilisez UTC pour stocker en Firestore
                      : DateTime.now()
                          .toUtc(), // Utilisez UTC pour stocker en Firestore
                  endDate: pickedEndDate != null
                      ? pickedEndDate!
                          .toUtc() // Utilisez UTC pour stocker en Firestore
                      : DateTime.now()
                          .toUtc(), // Utilisez UTC pour stocker en Firestore
                  budget: budgetController.text,
                );

                await FirebaseFirestore.instance
                    .collection('projects')
                    .add(newProject.toMap());

                setState(() {
                  projects.add(newProject);
                });
                // Show a Snackbar for successful project addition
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Projet ajouté avec succès'),
                  ),
                );

                pickedStartDate = null;
                pickedEndDate = null;

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return ListTile(
      title: Text(project.name),
      subtitle: Text(
        'Du ${DateFormat('dd/MM/yyyy HH:mm').format(project.startDate)} au ${DateFormat('dd/MM/yyyy HH:mm').format(project.endDate)}',
      ),
      onTap: () {
        // Ajoutez ici la logique pour naviguer vers la page détaillée du projet
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.task),
            onPressed: () {
              _addTask(project.id);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _editProject(project);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteProject(project.id);
            },
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        pickedDateTime = DateTime(
          pickedDateTime.year,
          pickedDateTime.month,
          pickedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return pickedDateTime;
  }

  Future<void> _editProject(Project project) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController budgetController = TextEditingController();

    nameController.text = project.name;
    pickedStartDate = project.startDate;
    pickedEndDate = project.endDate;
    budgetController.text = project.budget;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le Projet'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom du Projet'),
                ),
                TextField(
                  onTap: () async {
                    DateTime? newStartDate = await _pickDateTime(context);
                    if (newStartDate != null) {
                      setState(() {
                        pickedStartDate = newStartDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date de Début',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: pickedStartDate != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(pickedStartDate!)
                        : "Sélectionner une date",
                  ),
                ),
                TextField(
                  onTap: () async {
                    DateTime? newEndDate = await _pickDateTime(context);
                    if (newEndDate != null) {
                      setState(() {
                        pickedEndDate = newEndDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date de Fin',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: pickedEndDate != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(pickedEndDate!)
                        : "Sélectionner une date",
                  ),
                ),
                TextField(
                  controller: budgetController,
                  decoration: InputDecoration(labelText: 'Budget'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                // Mettez à jour le projet dans Firestore
                project.name = nameController.text;
                project.startDate = pickedStartDate ?? DateTime.now();
                project.endDate = pickedEndDate ?? DateTime.now();
                project.budget = budgetController.text;

                await ProjectService().updateProject(project);
                // Show a Snackbar for successful project update
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Projet mis à jour avec succès'),
                  ),
                );

                // Mettez à jour la liste des projets
                _loadProjects();

                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProject(String projectId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce projet?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await ProjectService().deleteProject(projectId);
                _loadProjects(); // Rechargez la liste des projets après la suppression.
                // Show a Snackbar for successful project deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Projet supprimé avec succès'),
                  ),
                );
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUsers() async {
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      userNamesList = usersSnapshot.docs.map((doc) {
        if (doc.data()!.containsKey('password')) {
          // Vérifier si le champ 'password' existe dans le document
          return MyUser(
            id: doc.id,
            firstname: doc['firstname'],
            lastname: doc['lastname'],
            email: doc['email'],
            password: doc['password'],
          );
        } else {
          // Gérer le cas où le champ 'password' est absent
          return MyUser(
            id: doc.id,
            firstname: doc['firstname'],
            lastname: doc['lastname'],
            email: doc['email'],
            password: 'Mot de passe non disponible',
          );
        }
      }).toList();
    });
  }

  Future<void> _addTask(String projectId) async {
    if (userNamesList.isEmpty) {
      await _loadUsers();
    }
    TextEditingController nameController = TextEditingController();
    TextEditingController deadlineController = TextEditingController();
    String selectedPriority = 'Haute';
    String selectedUserId =
        userNamesList.isNotEmpty ? userNamesList.first.id : 'defaultId';

    // Capture the context before entering the asynchronous part
    BuildContext dialogContext = context;
    await showDialog(
      context: dialogContext,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une tâche'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: 4, // Number of items in the list
              itemBuilder: (BuildContext context, int index) {
                // Use switch case to build different widgets based on the index
                switch (index) {
                  case 0:
                    return TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nom de la tâche'),
                    );
                  case 1:
                    return TextField(
                      controller: deadlineController,
                      decoration: InputDecoration(labelText: 'Date limite'),
                    );
                  case 2:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Priorité'),
                        DropdownButton<String>(
                          value: selectedPriority,
                          items: ['Haute', 'Moyenne', 'Basse']
                              .map((String priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPriority = newValue ?? 'Haute';
                            });
                          },
                        ),
                      ],
                    );
                  case 3:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Responsable'),
                        DropdownButton<String>(
                          value: selectedUserId,
                          items: userNamesList.map((MyUser user) {
                            return DropdownMenuItem<String>(
                              value: user.id,
                              child: Text('${user.firstname} ${user.lastname}'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedUserId = newValue ?? 'defaultId';
                            });
                          },
                        ),
                      ],
                    );
                  default:
                    return SizedBox
                        .shrink(); // Return an empty widget if index is out of bounds
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                // Add the task to the project with the entered data
                TaskModel newTask = TaskModel(
                  id: DateTime.now().toString(),
                  project: projectId,
                  name: nameController.text,
                  deadline: deadlineController.text,
                  priority: selectedPriority,
                  assignedTo: selectedUserId,
                  status: 'En cours',
                );

                // Add the task to Firestore
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .add(newTask.toMap());

                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
