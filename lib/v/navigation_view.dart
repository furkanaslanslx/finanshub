import 'dart:io' show Platform;
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hub/services/token_service.dart';
import 'package:hub/services/variables.dart';
import 'package:hub/v/category_view.dart';
import 'package:hub/v/favourites_view.dart';
import 'package:hub/v/main_view.dart';
import 'package:hub/v/widgets/appbar.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key, required this.isFirstLaunch});

  final bool isFirstLaunch;

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<MainPageState> mainPageKey = GlobalKey<MainPageState>();

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MainPage(key: mainPageKey),
      const CategoryView(),
      const FavouritesView(),
    ];
    if (widget.isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
    loadOrFetchTokenAndSet();
  }

  Future<void> loadOrFetchTokenAndSet() async {
    await loadOrFetchToken();
    setState(() {});
  }

  Future<void> _showWelcomeDialog() async {
    await Future.delayed(const Duration(seconds: 20));
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hoş Geldiniz!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Uygulamamıza hoş geldiniz. Bildirim almak için izin vermeniz gerekiyor.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _askNotificationPermission();
                      },
                      child: const Text('İzin Ver', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.red;
                          }
                          return Colors.pink;
                        }),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Daha sonra sor', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    await prefs.setBool(isFirstLaunchKey, false);
  }

  Future<void> _askNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      messaging.subscribeToTopic("allDevices");
      debugPrint('Bildirim izni verildi (${Platform.isIOS ? 'iOS' : 'Android'})');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Bildirim izni reddedildi (${Platform.isIOS ? 'iOS' : 'Android'})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: MyAppBar(),
      // drawer: const CustomDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode ? Colors.black.withOpacity(0.6) : themeNotifier.iconColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(50.0),
                      // boxShadow: const [
                      //   BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 5),
                      // ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_selectedIndex == 0) {
                              mainPageKey.currentState?.scrollToTop();
                            } else {
                              setState(() => _selectedIndex = 0);
                            }
                          },
                          child: Opacity(
                            opacity: _selectedIndex == 0 ? 1.0 : 0.6,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Image.asset(
                                  'assets/new icons/Finans Hub beyaz Logo.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.list,
                              size: 32,
                              color: _selectedIndex == 1 ? Colors.white : Colors.white.withOpacity(0.4),
                            ),
                            onPressed: () {
                              setState(() => _selectedIndex = 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 40),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.favorite,
                              size: 32,
                              color: _selectedIndex == 2 ? Colors.white : Colors.white.withOpacity(0.4),
                            ),
                            onPressed: () {
                              setState(() => _selectedIndex = 2);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
