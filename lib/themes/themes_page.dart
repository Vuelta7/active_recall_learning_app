import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(Color color) {
    _themeData = ThemeData(primaryColor: color);
    notifyListeners();
  }
}

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  _ThemesPageState createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  Color selectedColor = Colors.blue;

  void onColorChanged(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  Color getShade(Color color, int shade) {
    assert(shade >= 100 && shade <= 900 && shade % 100 == 0);
    final int r = color.red;
    final int g = color.green;
    final int b = color.blue;
    final double factor = (shade / 1000).clamp(0.0, 1.0);
    return Color.fromRGBO(
      (r * factor).toInt(),
      (g * factor).toInt(),
      (b * factor).toInt(),
      1,
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme Color'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ColorPicker(
              pickersEnabled: const {
                ColorPickerType.wheel: true,
              },
              color: selectedColor,
              onColorChanged: onColorChanged,
              heading: const Text('Select color'),
              subheading: const Text('Select a different shade'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Use the provider to change the theme of the app
                Provider.of<ThemeNotifier>(context, listen: false)
                    .setTheme(selectedColor);
              },
              child: const Text('Change Theme Color'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: List.generate(9, (index) {
                  final shade = (index + 1) * 100;
                  final color = getShade(selectedColor, shade);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                    ),
                    title: Text('Shade $shade'),
                    subtitle: Text(
                      'Text color: ${_getTextColorForBackground(color) == Colors.black ? 'Black' : 'White'}',
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
