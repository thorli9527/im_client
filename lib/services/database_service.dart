import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/system_config.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxService {
  late Isar isar;

  Future<DatabaseService> init() async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory('${dir.path}/isar');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    isar = await Isar.open(
      [SystemConfigSchema],
      directory: dbDir.path,
      name: 'im_client',
    );

    return this;
  }

  /// ✅ 确保这个 getter 存在
  Isar get db => isar;
}
