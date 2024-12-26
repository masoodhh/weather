import 'package:flutter/material.dart';
import 'package:weather/core/widgets/main_wrapper.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';
import 'package:weather/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //init locator
  await setup();

  runApp(
    MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => locator<HomeBloc>()),
          BlocProvider(create: (context) => locator<BookmarkBloc>()),
        ],
        child: MainWrapper(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
