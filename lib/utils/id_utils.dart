
import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:snowflaker/snowflaker.dart';
import 'package:fixnum/fixnum.dart';
class IdUtils {
    // 单例 UUID 生成器
    static final Uuid _uuid = Uuid();

    // 单例雪花 ID 生成器
    static final SafeSnowflake _generator = SafeSnowflake(nodeId: 1, workerId: 7);

    /// 生成 UUID v4（随机）
    static String buildUuid() {
        return _uuid.v4().replaceAll("-", "");
    }

    /// 生成雪花 ID（53-bit 有序唯一 ID）
    static int buildSnowflake() {
        return _generator.generate();
    }
}


class SafeSnowflake {
    static const int _maxSequence = 0x03; // 2 bits
    static const int _maxNodeId = 0x1F;   // 5 bits
    static const int _maxWorkerId = 0x1F; // 5 bits

    final int nodeId;
    final int workerId;

    int _sequence = 0;
    int _lastTimestamp = 0;

    SafeSnowflake({
        required int nodeId,
        required int workerId,
    })  : nodeId = nodeId & _maxNodeId,
            workerId = workerId & _maxWorkerId;

    /// 获取当前毫秒 UTC 时间
    int _currentTimestamp() => DateTime.now().toUtc().millisecondsSinceEpoch;

    /// 生成唯一 ID（53 位以内）
    int generate() {
        int timestamp = _currentTimestamp();

        if (timestamp == _lastTimestamp) {
            _sequence = (_sequence + 1) & _maxSequence;
            if (_sequence == 0) {
                // 同一毫秒内序列号溢出，等待下一毫秒
                while (timestamp <= _lastTimestamp) {
                    timestamp = _currentTimestamp();
                }
            }
        } else {
            _sequence = 0;
        }

        _lastTimestamp = timestamp;

        // 生成结构：
        // 41 bits timestamp | 5 bits nodeId | 5 bits workerId | 2 bits sequence
        final id = ((timestamp & 0x1FFFFFFFFFF) << 12) |
        ((nodeId & 0x1F) << 7) |
        ((workerId & 0x1F) << 2) |
        (_sequence & 0x03);

        return id;
    }
}
