import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_offline/features/tasks/presentation/pages/task_page.dart';
import 'package:todo_offline/features/tasks/presentation/providers/task_provider.dart';

import 'package:todo_offline/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:todo_offline/features/tasks/domain/repositories/task_repository.dart';

import 'package:todo_offline/features/tasks/data/local/task_db.dart';
import 'package:todo_offline/features/tasks/data/local/task_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar base de datos SQLite
  final db = TaskDb.instance;
  await db.database;

  // Crear datasource local
  final localDataSource = TaskLocalDatasource(db: db);

  // Crear repositorio
  final TaskRepository taskRepository = TaskRepositoryImpl(
    localDataSource: localDataSource,
    // remoteDataSource: RemoteDataSource (si lo agregas después)
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(repository: taskRepository)..loadTasks(),
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6C63FF),
          primaryContainer: const Color(0xFF6C63FF).withOpacity(0.1),
          secondary: const Color(0xFFFF6584),
          surface: Colors.white,
          background: Colors.grey[50],
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7C73FF),
          primaryContainer: const Color(0xFF7C73FF).withOpacity(0.2),
          secondary: const Color(0xFFFF6584),
          surface: const Color(0xFF1E1E2E),
          background: const Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: const Color(0xFF1E1E2E),
          surfaceTintColor: const Color(0xFF1E1E2E),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const TaskPage(),
    );
  }
}
