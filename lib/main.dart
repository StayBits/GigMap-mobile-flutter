import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/views/HomeShell.dart';
import 'package:gigmap_mobile_flutter/views/Welcome.dart';
import 'package:gigmap_mobile_flutter/bloc/auth/AuthBloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Gigmap',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/welcome',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/welcome':
              return MaterialPageRoute(
                builder: (_) => const Welcome(),
                settings: settings,
              );
            case '/home':
              final args = settings.arguments;
              int initialIndex = 0;
              int? selectedConcertId;

              if (args is Map<String, dynamic>) {
                initialIndex = args['initialIndex'] ?? 0;
                selectedConcertId = args['selectedConcertId'];
              } else if (args is int) {
                initialIndex = args;
              }

              return MaterialPageRoute(
                builder: (_) => HomeShell(
                  initialIndex: initialIndex,
                  selectedConcertId: selectedConcertId,
                ),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
