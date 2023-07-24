import 'package:desafio_dti/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('myTasks');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        unselectedWidgetColor: Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          indicatorShape: null,
          indicatorColor: Colors.transparent,
          labelTextStyle: MaterialStateProperty.resolveWith((state) {
            if (state.contains(MaterialState.selected)) {
              return const TextStyle(
                color: Color(0xff00C969),
                fontWeight: FontWeight.w500,
              );
            }
            return const TextStyle(color: Colors.white);
          }),
        ),
      ),
      home: const HomePage(),
    );
  }
}
