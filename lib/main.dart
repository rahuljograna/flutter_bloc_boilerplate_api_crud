import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_boilerplate/app/core/observer.dart';
import 'package:flutter_bloc_boilerplate/app/env.dart';
import 'package:flutter_bloc_boilerplate/app/presentation/styles/theme.dart';
import 'package:flutter_bloc_boilerplate/app/presentation/styles/theme_bloc/theme_bloc.dart';
import 'package:flutter_bloc_boilerplate/app/router/app_route_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()..add(ThemeInitialEvent())),
        ],
        child: Builder(builder: (context) {
          final isDarkTheme = context.watch<ThemeBloc>().state.isDarkTheme;
          return MaterialApp(
            title: Environments.appName,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRouted,
            debugShowCheckedModeBanner: false,
            theme: isDarkTheme
                ? appThemeData[AppTheme.dark]
                : appThemeData[AppTheme.light],
          );
        }));
  }
}
