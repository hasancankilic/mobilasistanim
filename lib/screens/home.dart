import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proje_ilk/database_helper.dart';
import 'package:proje_ilk/model/task.dart';
import 'package:proje_ilk/screens/add_new_task.dart';
import 'package:proje_ilk/todoitem.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({Key? key, required this.name}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> todo = [];
  List<Task> completed = [];

  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initDatabaseAndLoadTasks();
  }

  Future<void> _initDatabaseAndLoadTasks() async {
    try {
      await DatabaseHelper.instance.initDatabase();
      _loadTasks();
    } catch (e) {
      print("Veritabanı başlatılırken bir hata oluştu: $e");
    }
  }

  Future<void> _loadTasks() async {
    try {
      List<Task> allTasks = await DatabaseHelper.instance.getAllTasks();
      todo = allTasks.where((task) => !task.isCompleted).toList();
      completed = allTasks.where((task) => task.isCompleted).toList();
      setState(() {});
    } catch (e) {
      print("Görevler yüklenirken bir hata oluştu: $e");
    }
  }

  void _addNewTask(Task newTask) {
    setState(() => todo.add(newTask));
  }

  void _completeTask(Task task) async {
    setState(() {
      task.isCompleted = true;
      todo.remove(task);
      completed.add(task);
    });
    await DatabaseHelper.instance.updateTask(task);
    _showCongratulationsSnackBar();
  }

  void _deleteTask(Task task) async {
    setState(() {
      completed.remove(task);
    });
    await DatabaseHelper.instance.deleteTask(task.id!);
    _loadTasks();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
        color: Colors.purple,
        image: DecorationImage(
          image: AssetImage("lib/assets/images/headerr.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getCurrentDate(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Merhaba, ${widget.name}!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final formattedDate = DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now());
    return formattedDate;
  }

  Widget _buildTaskList(List<Task> tasks, Function(Task) onTaskComplete) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'Henüz göreviniz yok.',
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TodoItem(
            task: tasks[index],
            onTaskComplete: () => onTaskComplete(tasks[index]),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTasks() {
    if (completed.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          "Tamamlanan Görevler",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        Column(
          children: completed.map((task) {
            return ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _deleteTask(task),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCongratulationsSnackBar() {
    final snackBar = SnackBar(
      content: Text('Tebrikler, ödülünüz başarınızdır!'),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Görevler",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildTaskList(todo, _completeTask),
                      _buildCompletedTasks(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newTask = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddNewTaskScreen(
                addNewTask: _addNewTask,
                username: widget.name,
              ),
            ));
            if (newTask != null) {
              _loadTasks();
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
