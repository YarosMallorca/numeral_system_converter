import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numeral_systems/home_screen.dart';
import 'package:numeral_systems/providers/theme_provider.dart';
import 'package:numeral_systems/utils/preferences_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager.init();
  runApp(const NumeralSystems());
}

class NumeralSystems extends StatelessWidget {
  const NumeralSystems({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode selectedThemeMode = PreferencesManager.getTheme();

    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(selectedThemeMode: selectedThemeMode),
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Numeral Systems',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
          darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.blue),
              useMaterial3: true),
          home: const HomeScreen(),
          themeMode: themeProvider.selectedThemeMode,
        );
      }),
    );
  }
}
