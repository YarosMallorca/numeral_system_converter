import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:numeral_systems/providers/locale_provider.dart';
import 'package:numeral_systems/providers/theme_provider.dart';
import 'package:numeral_systems/utils/preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:units_converter/units_converter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum TargetLanguage { auto, en, es, ca }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TextEditingController> controllers = List.generate(4, (index) => TextEditingController());
  List<String> textHints = ["Binary", "Octal", "Hexadecimal", "Decimal"];
  List<NUMERAL_SYSTEMS> numeralSystems = [
    NUMERAL_SYSTEMS.binary,
    NUMERAL_SYSTEMS.octal,
    NUMERAL_SYSTEMS.hexadecimal,
    NUMERAL_SYSTEMS.decimal
  ];
  List<RegExp> regexes = [
    RegExp(r'^[01]*'),
    RegExp(r'^[0-7]*'),
    RegExp(r'^(0x)?[0-9A-Fa-f]+'),
    RegExp(r'^\d+(\.\d+)?')
  ];

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  List<String> languagesList = ["Auto", "English", "Español", "Català"];
  TargetLanguage? language = TargetLanguage.auto;

  void changeLanguage(TargetLanguage selectedLanguage) {
    Locale targetLanguage;
    if (selectedLanguage == TargetLanguage.auto) {
      context.read<LocaleProvider>().clearLocale();
      PreferencesManager.setLanguage("auto");
    } else {
      targetLanguage = Locale(selectedLanguage.name);
      context.read<LocaleProvider>().setLocale(targetLanguage);
      PreferencesManager.setLanguage(targetLanguage.languageCode.toString());
    }
  }

  void getLanguage() {
    final currentLanguage = PreferencesManager.getLanguage();
    if (currentLanguage == "auto") {
      language = TargetLanguage.auto;
    } else {
      language = TargetLanguage.values.firstWhere((e) => e.toString() == 'TargetLanguage.$currentLanguage');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb) {
      _loadAd();
    }
    getLanguage();

    textHints = [
      AppLocalizations.of(context)!.binary,
      AppLocalizations.of(context)!.octal,
      AppLocalizations.of(context)!.hexadecimal,
      AppLocalizations.of(context)!.decimal
    ];
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: 'ca-app-pub-8909072039965812/5375126970',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  void convert({required String unit, required String value, required int index}) {
    // Initialization of the object
    NumeralSystems numeralSystem = NumeralSystems();
    numeralSystem.convert(numeralSystems[index], value);

    for (int i = 0; i < controllers.length; i++) {
      if (unit != textHints[i]) {
        controllers[i].text = numeralSystem.getUnit(numeralSystems[i]).stringValue!;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.appName),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      // Show popup to change language
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.changeLanguage),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: List<Widget>.generate(
                                          TargetLanguage.values.length,
                                          (index) => ListTile(
                                            title: Text(languagesList[index]),
                                            leading: Radio<TargetLanguage>(
                                              value: TargetLanguage.values[index],
                                              groupValue: language,
                                              onChanged: (TargetLanguage? value) {
                                                setState(() {
                                                  language = value;
                                                });
                                              },
                                            ),
                                            onTap: () {
                                              setState(() {
                                                language = TargetLanguage.values[index];
                                              });
                                            },
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              // Action Buttons
                              actions: <Widget>[
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    getLanguage();
                                  },
                                ),
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.apply),
                                  onPressed: () {
                                    changeLanguage(language!);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.language)),
                IconButton(
                    onPressed: () {
                      // Switch from light to dark
                      if (Theme.of(context).brightness == Brightness.light) {
                        Provider.of<ThemeProvider>(context, listen: false).setSelectedThemeMode(ThemeMode.dark);
                      }

                      // Switch from dark to light
                      else {
                        Provider.of<ThemeProvider>(context, listen: false).setSelectedThemeMode(ThemeMode.light);
                      }
                    },
                    icon: Icon(Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode))
              ],
            )
          ],
        ),
        body: Stack(children: [
          Align(alignment: Alignment.topCenter, child: Text(AppLocalizations.of(context)!.appDeveloper)),
          if (_anchoredAdaptiveAd != null && _isLoaded) ...[
            Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _anchoredAdaptiveAd!.size.width.toDouble(),
                  height: _anchoredAdaptiveAd!.size.height.toDouble(),
                  child: AdWidget(ad: _anchoredAdaptiveAd!),
                )),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: TextFormField(
                  enableSuggestions: false,
                  controller: controllers[index],
                  keyboardType: index == 2
                      ? TextInputType.text
                      : const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(regexes[index])],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: textHints[index],
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: controllers[index].text));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text("Copied Text"),
                            ));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                  ),
                  onChanged: (text) => convert(unit: textHints[index], value: text, index: index),
                ),
              ),
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.clear),
          onPressed: () {
            for (int i = 0; i < controllers.length; i++) {
              controllers[i].text = "";
            }
          },
        ),
      ),
    );
  }
}
