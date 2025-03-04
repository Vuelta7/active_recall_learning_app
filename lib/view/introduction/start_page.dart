import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/color_utils.dart';
import 'package:learn_n/core/utils/start_page_utils.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/view/auth/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorString =
        prefs.getString('selectedColor') ?? rgbToHex(Colors.blue);
    setState(() {
      selectedColor = hexToColor(colorString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildLogo(),
              buildTitleText('Learn-N'),
              const SizedBox(height: 40),
              buildRetroButton(
                'Register',
                getShade(selectedColor, 300),
                () {
                  Navigator.push(context, AuthScreen.route(isLogin: false));
                },
              ),
              const SizedBox(height: 20),
              buildRetroButton(
                'Log In',
                getShade(selectedColor, 300),
                () {
                  Navigator.push(context, AuthScreen.route(isLogin: true));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
