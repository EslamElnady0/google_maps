import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/map_cubit.dart';
import 'location_screen.dart';
import 'repo/map_repo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const orsApiKey =
        '5b3ce3597851110001cf6248b9608669b259480a99bcc69f2180c468';
    return MaterialApp(
      home: RepositoryProvider(
        create: (context) => MapRepo(orsApiKey: orsApiKey),
        child: BlocProvider(
          create: (context) => MapCubit(context.read<MapRepo>())..init(),
          child: const LocationScreen(),
        ),
      ),
    );
  }
}
