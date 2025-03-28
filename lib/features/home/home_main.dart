import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/features/home/activity%20page/activity_page.dart';
import 'package:learn_n/features/home/folder%20page/folder_page.dart';
import 'package:learn_n/features/home/folder%20page/widget/add_folder_page.dart';
import 'package:learn_n/features/home/setting%20page/setting_page.dart';
import 'package:lottie/lottie.dart';

class HomeMain extends ConsumerStatefulWidget {
  const HomeMain({super.key});

  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends ConsumerState<HomeMain>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

  @override
  void initState() {
    super.initState();

    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(milliseconds: 100),
      () => _borderRadiusAnimationController.forward(),
    );

    _checkStreakWarning();
  }

  Future<void> _checkStreakWarning() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data()!;
      final streakPoints = data['streakPoints'] ?? 0;
      final warning = data['warning'] ?? false;

      if (warning) {
        _showWarningDialog(context, ref.read(userColorProvider));
        if (streakPoints >= 2) {
          await userDoc.update({'warning': false});
        }
      }
    }
  }

  void _showWarningDialog(context, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: color,
          title: const Text(
            'Warning',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'press',
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/sadstar.json'),
              const Text(
                'You missed a day! If you miss another day, your streak points will reset to 0.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'press',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'press',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _borderRadiusAnimationController.dispose();
    _hideBottomBarAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);

    Widget body;
    if (_selectedIndex == 0) {
      body = const ActivtyPage();
    } else if (_selectedIndex == 1) {
      body = const FolderPage();
    } else if (_selectedIndex == 2) {
      body = const SettingPage();
    } else {
      body = const FolderPage();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: body,
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddFolderPage()),
                  );
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.add_rounded,
                  color: getShade(userColor, 800),
                  size: 30,
                ),
              )
            : null,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: 3,
          tabBuilder: (int index, bool isActive) {
            const color = Colors.white;
            final showLabel = isActive || _selectedIndex == index;

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  index == 0
                      ? Icons.school_rounded
                      : index == 1
                          ? Icons.folder_rounded
                          : Icons.attractions_rounded,
                  size: 55,
                  color: color,
                ),
                if (showLabel)
                  Text(
                    index == 0
                        ? 'Activity'
                        : index == 1
                            ? 'Library'
                            : 'Options',
                    style: const TextStyle(
                      color: color,
                      fontSize: 8,
                      fontFamily: 'PressStart2P',
                    ),
                  )
              ],
            );
          },
          backgroundColor: userColor,
          height: 70,
          activeIndex: _selectedIndex,
          splashColor: Colors.black,
          notchAndCornersAnimation: borderRadiusAnimation,
          splashSpeedInMilliseconds: 100,
          notchSmoothness: NotchSmoothness.defaultEdge,
          gapLocation: GapLocation.none,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: _onItemTapped,
          hideAnimationController: _hideBottomBarAnimationController,
        ),
      ),
    );
  }
}
