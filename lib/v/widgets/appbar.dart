import 'package:flutter/material.dart';
import 'package:hub/v/drawer_view.dart';
import 'package:hub/vm/all_vms.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final VoidCallback? onDrawerToggle;

  const MyAppBar({
    super.key,
    this.title,
    this.actions,
    this.onDrawerToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: (() {
      //   if (onDrawerToggle != null) {
      //     return IconButton(
      //       icon: const Icon(Icons.menu),
      //       color: Colors.white,
      //       onPressed: onDrawerToggle,
      //     );
      //   }
      // }()),
      leading: IconButton(
        onPressed: drawerController.toggle,
        icon: const Icon(Icons.menu, color: Colors.white),
      ),
      title: Image.asset('assets/new icons/Logo Beyaz 2.png', height: 50),
      centerTitle: true,
      backgroundColor: themeNotifier.isDarkMode ? Colors.black : themeNotifier.iconColor,
    );
  }
}
