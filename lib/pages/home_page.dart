import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_weather_cubit/constant/constants.dart';
import 'package:open_weather_cubit/cubits/temp_settings/temp_settings_cubit.dart';
import 'package:open_weather_cubit/cubits/weather/weather_cubit.dart';
import 'package:open_weather_cubit/pages/search_page.dart';
import 'package:open_weather_cubit/pages/settins_page.dart';
import 'package:open_weather_cubit/widgets/error_dialog.dart';
import 'package:recase/recase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchWeather();
  // }
  //
  // _fetchWeather() {
  //   context.read<WeatherCubit>().fetchWeather('london');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        actions: [
          IconButton(
            onPressed: () async {
              _city = await Navigator.push(context,
                  CupertinoPageRoute(builder: (context) {
                return SearchPage();
              }));
              print('city: $_city');
              if (_city != null) {
                context.read<WeatherCubit>().fetchWeather(_city!);
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) {
                    return const SettingsPage();
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: _showWeather(),
    );
  }

  String showTemperature(double temperature) {
    final tempUnit = context.watch<TempSettingsCubit>().state.tempUnit;

    if (tempUnit == TempUnit.fahrenheit) {
      return ((temperature * 9 / 5) + 32).toStringAsFixed(2) + '℉';
    }

    return temperature.toStringAsFixed(2) + '℃';
  }

  Widget showIcon(String icon) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif',
      image: 'http://$kIconHost/img/wn/$icon@4x.png',
      width: 96,
      height: 96,
    );
  }

  Widget formatText(String description) {
    final formattedString = description.titleCase;
    return Text(
      formattedString,
      style: const TextStyle(fontSize: 24.0),
      textAlign: TextAlign.center,
    );
  }

  Widget _showWeather() {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        final status = state.status;
        if (status == WeatherStatus.error) {
          errorDialog(context, state.error.errMsg);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case WeatherStatus.initial:
            return const Center(
              child: Text(
                'Select a City',
                style: TextStyle(fontSize: 20),
              ),
            );
          case WeatherStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case WeatherStatus.loaded:
            final weather = state.weather;
            return ListView(
              children: [
                SizedBox(
                  height: 16.h,
                ),
                Text(
                  weather.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TimeOfDay.fromDateTime(weather.lastUpdated)
                          .format(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '(${weather.country})',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showTemperature(weather.temp),
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Column(
                      children: [
                        Text(
                          showTemperature(weather.tempMax),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          showTemperature(weather.tempMin),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    showIcon(state.weather.icon),
                    Expanded(
                      flex: 3,
                      child: formatText(state.weather.description),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            );
          case WeatherStatus.error:
            return const Center(
              child: Text(
                'Select a City',
                style: TextStyle(fontSize: 20),
              ),
            );
        }
      },
    );
  }
}
