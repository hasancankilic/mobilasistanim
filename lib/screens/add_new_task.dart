import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proje_ilk/constants/task_type.dart';
import 'package:proje_ilk/model/task.dart';
import 'package:proje_ilk/database_helper.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({Key? key, required this.username, required this.addNewTask}) : super(key: key);

  final String username;
  final void Function(Task newTask) addNewTask;

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  TaskType? taskType = TaskType.not;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Görev Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate != null ? DateFormat('d MMMM yyyy').format(selectedDate!) : 'Tarih Seç'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _selectTime(context),
              child: Text(selectedTime != null ? selectedTime!.format(context) : 'Saat Seç'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<TaskType>(
              value: taskType,
              onChanged: (value) {
                setState(() {
                  taskType = value;
                });
              },
              items: TaskType.values.map((type) {
                return DropdownMenuItem<TaskType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Görev Tipi',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final newTask = Task(
                    username: widget.username,
                    title: title,
                    description: descriptionController.text,
                    type: taskType ?? TaskType.not,
                    dateTime: selectedDate != null && selectedTime != null
                        ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute)
                        : null,
                    isCompleted: false,
                  );

                  try {
                    await DatabaseHelper.instance.insertTask(newTask);
                    widget.addNewTask(newTask); // Hemen ana ekrana eklemek için
                    Navigator.pop(context, newTask); // Ana ekrana dön ve yeni görevi geri gönder
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hata'),
                        content: Text('Görev eklenirken bir hata oluştu.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Boş Başlık'),
                      content: Text('Lütfen bir görev başlığı girin.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
