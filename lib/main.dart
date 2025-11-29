import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        home: Welcome(),
      ),
    );
  }
}
