import 'package:flutter/material.dart';
import 'package:mathfinity/others/states.dart';
import 'package:mathfinity/others/utils.dart';
import 'package:mathfinity/routes/home_route.dart';
import 'package:one_context/one_context.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:dynamic_color/dynamic_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Utils.getSavedSettings();
  runApp(const MyApp());
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.danger,
  });

  final Color? danger;

  @override
  CustomColors copyWith({Color? danger}) {
    return CustomColors(
      danger: danger ?? this.danger,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      danger: Color.lerp(danger, other.danger, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(danger: danger!.harmonizeWith(dynamic.primary));
  }
}

const _brandBlue = Colors.blue;

CustomColors lightCustomColors = const CustomColors(danger: Color(0xFFE53935));
CustomColors darkCustomColors = const CustomColors(danger: Color(0xFFEF9A9A));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            if (lightDynamic != null && darkDynamic != null) {
              lightColorScheme = lightDynamic.harmonized();
              lightColorScheme =
                  lightColorScheme.copyWith(secondary: _brandBlue);
              lightCustomColors =
                  lightCustomColors.harmonized(lightColorScheme);
              darkColorScheme = darkDynamic.harmonized();
              darkColorScheme = darkColorScheme.copyWith(secondary: _brandBlue);
              darkCustomColors = darkCustomColors.harmonized(darkColorScheme);
            } else {
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: _brandBlue,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: _brandBlue,
                brightness: Brightness.dark,
              );
            }

            return MaterialApp(
              title: 'MathFinity',
              theme: ThemeData(
                colorScheme: lightColorScheme,
                extensions: [lightCustomColors],
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                extensions: [darkCustomColors],
              ),
              home: HomeRoute(),
              builder: OneContext().builder,
              navigatorKey: OneContext().key,
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
            );
          },
        );
      },
    );
  }
}
