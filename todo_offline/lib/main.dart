import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_offline/features/tasks/presentation/pages/task_page.dart';
import 'package:todo_offline/features/tasks/presentation/providers/task_provider.dart';
import 'package:todo_offline/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:todo_offline/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_offline/features/tasks/data/local/task_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database using the singleton instance
  final database = TaskDb.instance;
  await database
      .database; // This will initialize the database if not already initialized

  // Initialize repository
  final TaskRepository taskRepository = TaskRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              TaskProvider(repository: taskRepository)..loadTasks(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Offline',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TaskPage(),
    );
  }
}
