import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_client/services/app_config_service.dart';
import 'package:im_client/services/database_service.dart';
import 'package:im_client/views/splash_page.dart';
import 'package:im_client/routes/app_routes.dart';

import '../models/system_config.dart';
class IMClientApp extends StatelessWidget {
  const IMClientApp({super.key});

  static Future<void> run() async {
    // 初始化数据库服务
    final dbService = DatabaseService();
    await dbService.init();

    // 初始化配置服务
    final appConfig = AppConfigService();
    await appConfig.init(dbService.db);

    // 提前加载主题模式
    final modeStr = await appConfig.getString(ConfigTypeEnum.THEME_MODE);
    appConfig.themeMode.value = _parseThemeMode(modeStr);

    // 注入全局服务
    Get.put(dbService);
    Get.put(appConfig);

    runApp(const IMClientApp());
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = Get.find<AppConfigService>();
    return Obx(() => GetMaterialApp(
      title: 'IM Client',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: appConfig.themeMode.value,
      initialRoute: '/',
      getPages: AppRoutes.pages,
      home: const SplashPage(),
    ));
  }

  static ThemeMode _parseThemeMode(String? modeStr) {
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}
