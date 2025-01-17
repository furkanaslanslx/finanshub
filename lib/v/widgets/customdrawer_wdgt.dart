import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hub/services/responsive.dart';
import 'package:hub/v/webview/gizlilik.dart';
import 'package:hub/v/webview/iletisim.dart';
import 'package:hub/v/webview/kunye.dart';
import 'package:hub/vm/all_vms.dart';
import 'package:tinycolor2/tinycolor2.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final List<String> themeModes = ['Açık Tema', 'Koyu Tema', 'Sistem Teması'];
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeNotifier.isDarkMode;

    return Material(
      color: isDarkMode ? Colors.grey[900] : Colors.grey[400],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: ResponsiveSize.getHeight(context, 8)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ayarlar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Divider(
            color: isDarkMode ? Colors.white54 : Colors.black54,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tema Modu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButton<String>(
                    value: _themeModeToString(themeNotifier.themeMode),
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    items: themeModes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ThemeMode newMode;
                        switch (newValue) {
                          case 'Açık Tema':
                            newMode = ThemeMode.light;
                            break;
                          case 'Koyu Tema':
                            newMode = ThemeMode.dark;
                            break;
                          case 'Sistem Teması':
                            newMode = ThemeMode.system;
                            break;
                          default:
                            newMode = ThemeMode.system;
                            break;
                        }
                        themeNotifier.setThemeMode(newMode);
                      }
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tema Rengi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ColorPicker(
                    pickerColor: themeNotifier.iconColor,
                    onColorChanged: (Color color) {
                      double luminance = color.computeLuminance();
                      if (luminance >= 0.2) {
                        TinyColor tinyColor = TinyColor.fromColor(color);
                        Color adjustedColor = tinyColor.darken(1).color;

                        while (adjustedColor.computeLuminance() >= 0.2) {
                          tinyColor = TinyColor.fromColor(adjustedColor);
                          adjustedColor = tinyColor.darken(1).color;
                        }

                        themeNotifier.setIconColor(adjustedColor);
                      } else {
                        themeNotifier.setIconColor(color);
                      }
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    labelTypes: const [],
                    pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
                    pickerAreaHeightPercent: 0.5,
                  ),
                ),
                const Divider(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Icon(Icons.warning_amber_rounded, color: themeNotifier.iconColor, size: 30),
                //     const SizedBox(width: 10),
                //     const Expanded(
                //       child: Text('Açık renkler seçmeniz engellenmiştir.'),
                //     ),
                //   ],
                // ),
                // const Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const WebPageViewerIletisim();
                            },
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 30),
                        child: Text(
                          'İletişim',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const WebPageViewerKunye();
                            },
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 30),
                        child: Text(
                          'Künye',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const WebPageViewerGizlilik();
                            },
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 30),
                        child: Text(
                          'Gizlilik Sözleşmesi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Koyu Tema';
      case ThemeMode.system:
        return 'Sistem Teması';
      default:
        return 'Sistem Teması';
    }
  }
}
