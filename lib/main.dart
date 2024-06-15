import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proje_ilk/screens/login_screen.dart';
import 'package:proje_ilk/database_helper.dart'; // DatabaseHelper'a erişim

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Kullanıcı adı
  String username = await _getUsername();

  // Görevleri yükleme işlemi
  await _loadTasks(username);

  runApp(MyApp());
}

// Kullanıcı adını alacak fonksiyon
Future<String> _getUsername() async {
  // Burada kullanıcı adını alacak bir işlem yapılabilir,
  // örneğin shared preferences veya kullanıcı girişi
  return "kullanici"; // Örnek olarak sabit bir kullanıcı adı döndürüyoruz
}

// Görevleri yükleyen fonksiyon
Future<void> _loadTasks(String username) async {
  try {
    await DatabaseHelper.instance.getAllTasksForUser(username); // Kullanıcı adına göre görevleri yükle
  } catch (e) {
    print("Görevler yüklenirken bir hata oluştu: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistan Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LoginScreen(),
    );
  }
}
