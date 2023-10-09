import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:numeral_systems/home_screen.dart';
import 'package:numeral_systems/providers/locale_provider.dart';
import 'package:numeral_systems/providers/theme_provider.dart';
import 'package:numeral_systems/utils/preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    String selectedLanguage = PreferencesManager.getLanguage();

    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(selectedThemeMode: selectedThemeMode),
          ),
          ChangeNotifierProvider(
            create: (context) => LocaleProvider(clocale: selectedLanguage),
          )
        ],
        child: Consumer<ThemeProvider>(builder: (c, themeProvider, child) {
          return Consumer<LocaleProvider>(builder: (context, provider, child) {
            return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
              return MaterialApp(
                title: 'Numeral System Converter',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.selectedThemeMode,
                home: const HomeScreen(),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: provider.locale,
                theme: ThemeData(
                    useMaterial3: true,
                    brightness: Brightness.light,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    colorSchemeSeed: lightColorScheme == null ? Colors.blue : null,
                    colorScheme: lightColorScheme),
                darkTheme: ThemeData(
                    useMaterial3: true,
                    brightness: Brightness.dark,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    colorSchemeSeed: darkColorScheme == null ? Colors.blue : null,
                    colorScheme: darkColorScheme),
              );
            });
          });
        }));
  }
}
