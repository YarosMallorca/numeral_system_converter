import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numeral_systems/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:units_converter/units_converter.dart';

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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Numeral System Converter"),
          actions: [
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
        ),
        body: Stack(children: [
          const Align(alignment: Alignment.topCenter, child: Text("By Yaros")),
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
