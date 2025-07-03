import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../config/app_config.dart';
import '../models/login_response.dart';
import '../models/system_config.dart';
import '../utils/time_util.dart';
import 'api_service.dart';
import 'app_config_service.dart';

class UserService {
  static AppConfigService get _config => Get.find<AppConfigService>();

  static Future<LoginResponse> loginAndSave({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.post<LoginResponse>(
      path: '/user/login',
      data: {
        'username': username,
        'password': password,
        "deviceType": "Desktop",
        'appKey': AppConfig.appKey,
      },
      fromJsonT: (json) => LoginResponse.fromJson(json),
    );

    final login = response.data;
    if (response.success==false|| login == null) {
      throw Exception('登录失败：${response.message}');
    }

    await _persistLoginState(login, username);
    return login;
  }

  static Future<bool> isLoggedIn() async {
    final status = await _config.getString(ConfigTypeEnum.LOGIN_STATUS);
    return status == 'true';
  }

  static Future<void> logout() async {
    await _config.clearLoginInfo();
  }

  static Future<String?> getToken() async {
    return _config.getString(ConfigTypeEnum.TOKEN);
  }

  static Future<void> _persistLoginState(LoginResponse login, String username) async {
    await _config.setString(ConfigTypeEnum.LOGIN_STATUS, "true");
    await _config.setString(ConfigTypeEnum.USER_NAME, username);
    await _config.setString(ConfigTypeEnum.TOKEN, login.token);
    await _config.setString(
      ConfigTypeEnum.TOKEN_CTEATE_TIME,
      TimeUtil.currentTimeMillis().toString(),
    );
  }
}
