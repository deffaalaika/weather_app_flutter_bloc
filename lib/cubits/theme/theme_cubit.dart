import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:open_weather_cubit/constant/constants.dart';
import 'package:open_weather_cubit/cubits/cubits.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  late final StreamSubscription weatherSubsCription;
  final WeatherCubit weatherCubit;
  ThemeCubit({required this.weatherCubit}) : super(ThemeState.initial()) {
    weatherSubsCription =
        weatherCubit.stream.listen((WeatherState weatherState) {
      print('weatherState: $weatherState');

      if (weatherState.weather.temp > kWarmOrNot) {
        emit(state.copyWith(appTheme: AppTheme.light));
      } else {
        emit(state.copyWith(appTheme: AppTheme.dark));
      }
    });
  }
  @override
  Future<void> close() {
    weatherSubsCription.cancel();
    return super.close();
  }
}
