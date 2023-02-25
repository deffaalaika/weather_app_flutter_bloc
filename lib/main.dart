// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// Project imports:
import 'package:open_weather_cubit/repositories/weather_repository.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'imports.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => WeatherRepository(
          weatherApiServices: WeatherApiServices(httpClient: http.Client())),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherBloc>(
            create: (context) => WeatherBloc(
              weatherRepository: context.read<WeatherRepository>(),
            ),
          ),
          BlocProvider<TempSettingsBloc>(
              create: (context) => TempSettingsBloc()),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(
              weatherBloc: context.read<WeatherBloc>(),
            ),
          ),
        ],
        child: ResponsiveSizer(
          builder: (context, orientation, screenType) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return MaterialApp(
                  title: 'Weather App',
                  debugShowCheckedModeBanner: false,
                  theme: state.appTheme == AppTheme.light
                      ? ThemeData.light()
                      : ThemeData.dark(),
                  home: const HomePage(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
