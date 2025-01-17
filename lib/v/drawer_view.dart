import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hub/v/navigation_view.dart';
import 'package:hub/v/widgets/customdrawer_wdgt.dart';
import 'package:hub/vm/all_vms.dart';

final ZoomDrawerController drawerController = ZoomDrawerController();

class DrawerView extends GetView<DrawerController> {
  final bool isFirstLaunch;
  const DrawerView({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeNotifier.isDarkMode;
    return GetBuilder<DrawerController>(
      builder: (controller) {
        return ZoomDrawer(
          controller: drawerController,
          style: DrawerStyle.defaultStyle,
          menuScreen: const CustomDrawer(),
          mainScreen: Navigation(isFirstLaunch: isFirstLaunch),
          borderRadius: 0.0,
          showShadow: false,
          angle: 0.0,
          slideWidth: MediaQuery.of(context).size.width * 0.8,
          menuBackgroundColor: isDarkMode ? (Colors.grey[900] ?? Colors.black) : (Colors.grey[400] ?? Colors.white),
          duration: const Duration(milliseconds: 350),
          mainScreenScale: 0.2,
        );
      },
    );
  }
}

class DrawerController extends GetxController {
  void toggleDrawer() {
    debugPrint("Toggle drawer");
    drawerController.toggle?.call();
    update();
  }
}
